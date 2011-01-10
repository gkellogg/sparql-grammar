module SPARQL; module Grammar
  ##
  # A parser for the SPARQL 1.0 grammar.
  #
  # @see http://www.w3.org/TR/rdf-sparql-query/#grammar
  # @see http://en.wikipedia.org/wiki/Parsing
  # @see http://en.wikipedia.org/wiki/Recursive_descent_parser
  class Parser
    include SPARQL::Grammar::Meta

    START = 'http://www.w3.org/2000/10/swap/grammar/sparql#Query'

    ##
    # Initializes a new parser instance.
    #
    # @param  [String, #to_s]          input
    # @param  [Hash{Symbol => Object}] options
    # @option option [Boolean] :progress Output parser progress
    def initialize(input = nil, options = {})
      @options = options.dup
      self.input = input if input
      @productions = []
    end

    ##
    # Any additional options for the parser.
    #
    # @return [Hash]
    attr_reader   :options

    ##
    # The current input string being processed.
    #
    # @return [String]
    attr_accessor :input

    ##
    # The current input tokens being processed.
    #
    # @return [Array<Token>]
    attr_reader   :tokens

    ##
    # @param  [String, #to_s] input
    # @return [void]
    def input=(input)
      case input
        when Array
          @input  = nil # FIXME
          @tokens = input
        else
          lexer   = input.is_a?(Lexer) ? input : Lexer.new(input, @options)
          @input  = lexer.input
          @tokens = lexer.to_a
      end
    end

    # Parse query
    def parse(prod = START)
      prod = prod.to_s.to_sym unless prod.is_a?(Symbol)
      todo_stack = [{:prod => prod, :terms => nil}]
      while !todo_stack.empty?
        pushed = false
        if todo_stack.last[:terms].nil?
          todo_stack.last[:terms] = []
          token = tokens.first
          debug "parse token: #{token.inspect}, prod #{todo_stack.last[:prod]}"
          
          # Got an opened production
          onStart(abbr(todo_stack.last[:prod]))
          break if token.nil?
          
          cur_prod = todo_stack.last[:prod]
          prod_branch = BRANCHES[cur_prod.to_sym]
          error("No branches found for '#{abbr(cur_prod)}'",
            :production => cur_prod, :token => token) if prod_branch.nil?
          sequence = prod_branch[token.representation]
          if sequence.nil?
            expected = prod_branch.values.uniq.map {|u| u.map {|v| abbr(v).inspect}.join(",")}
            error("Found '#{token.inspect}' when parsing a #{abbr(cur_prod)}. expected #{expected.join(' | ')}",
              :production => cur_prod, :token => token)
          end
          todo_stack.last[:terms] += sequence
        end
        
        debug "parse: #{todo_stack.last.inspect}"
        while !todo_stack.last[:terms].to_a.empty?
          term = todo_stack.last[:terms].shift
          debug "parse tokens: #{tokens.inspect}"
          if tokens.map(&:representation).include?(term)
            token = accept(term)
            debug "parse term(#{token.inspect}): #{term}"
            if token
              onToken(abbr(term), token.value)
            else
              error("Found '#{word}...'; #{term} expected",
                :production => todo_stack.last[:prod], :token => tokens.first)
            end
          else
            debug "parse term(push): #{term}"
            todo_stack << {:prod => term, :terms => nil}
            pushed = true
            break
          end
        end
        
        while !pushed && todo_stack.last[:terms].to_a.empty?
          todo_stack.pop
          self.onFinish
        end
      end
      while !todo_stack.empty?
        todo_stack.pop
        self.onFinish
      end
    end
    
    def abbr(prodURI)
      prodURI.to_s.split('#').last
    end
    
    # Start for production
    def onStart(prod)
      progress ' ' * @productions.length + prod
      @productions << prod
    end

    # Finish of production
    def onFinish
      prod = @productions.pop()
      progress ' ' * @productions.length + '/' + prod
    end

    # A token
    def onToken(prod, token)
      progress ' ' * @productions.length + "#{prod}(#{token.inspect})"
    end

    ##
    # Returns `true` if the input string is syntactically valid.
    #
    # @return [Boolean]
    def valid?
      nil # TODO
    end

  protected

    # @param [String] str Error string
    # @param [Hash] options
    # @option options [URI, #to_s] :production
    # @option options [Token] :token
    def error(str, options = {})
      $stderr.puts str
      raise Error.new("Error on production #{options[:production]} with input #{options[:token].inspect} at line #{options[:token].lineno}: #{str}", options)
    end

    ##
    # Progress output when parsing
    # @param [String] str
    def progress(str)
      $stderr.puts(str) if @options[:progress]
    end

    ##
    # Progress output when debugging
    # @param [String] str
    def debug(str)
      $stderr.puts(str) if $verbose
    end

    # XXX -- Following are for previous recursive-descent attempt
    # `[1] Query ::= Prologue (SelectQuery | ConstructQuery | DescribeQuery | AskQuery)`
    def parse_query
      result = [:query]
      if (decls = parse_prologue) && decls.size > 1
        result += decls[1..-1]
      end
      result << (parse_select_query || parse_construct_query || parse_describe_query || parse_ask_query)
      result.compact!
      result.size > 1 ? result : false
    end

    # `[2] Prologue ::= BaseDecl? PrefixDecl*`
    def parse_prologue
      result = [:prologue, parse_base_decl || nil, *parse_prefix_decls]
      result.compact!
      result.size > 1 ? result : false
    end

    # `[3] BaseDecl ::= 'BASE' IRI_REF`
    def parse_base_decl
      accept('BASE') ? [:base, parse_iri_ref] : fail
    end

    # `[4] PrefixDecl*`
    def parse_prefix_decls
      result = []
      while decl = parse_prefix_decl
        result << decl
      end
      result
    end

    # `[4] PrefixDecl ::= 'PREFIX' PNAME_NS IRI_REF`
    def parse_prefix_decl
      accept('PREFIX') ? [:prefix, parse_pname_ns, parse_iri_ref] : fail
    end

    # `[5] SelectQuery`
    def parse_select_query
      # TODO
    end

    # `[6] ConstructQuery`
    def parse_construct_query
      # TODO
    end

    # `[7] DescribeQuery`
    def parse_describe_query
      # TODO
    end

    # `[8] AskQuery`
    def parse_ask_query
      # TODO
    end

    # `[9] DatasetClause ::= 'FROM' (DefaultGraphClause | NamedGraphClause)`
    def parse_dataset_clause
      accept('FROM') ? (parse_default_graph_clause || parse_named_graph_clause) : fail # FIXME
    end

    # `[10] DefaultGraphClause ::= SourceSelector`
    def parse_default_graph_clause
      (iri = parse_source_selector) ? [:default, iri] : fail # FIXME
    end

    # `[11] NamedGraphClause ::= 'NAMED' SourceSelector`
    def parse_named_graph_clause
      accept('NAMED') ? [:named, parse_source_selector] : fail # FIXME
    end

    # `[12] SourceSelector ::= IRIref`
    def parse_source_selector
      parse_iriref
    end

    # `[13] WhereClause`
    def parse_where_clause
      # TODO
    end

    # `[14] SolutionModifier`
    def parse_solution_modifier
      # TODO
    end

    # `[15] LimitOffsetClauses`
    def parse_limit_offset_clauses
      # TODO
    end

    # `[16] OrderClause`
    def parse_order_clause
      # TODO
    end

    # `[17] OrderCondition`
    def parse_order_condition
      # TODO
    end

    # `[18] LimitClause ::= 'LIMIT' INTEGER`
    def parse_limit_clause
      case
        when accept('LIMIT') && token = accept(:NumericLiteral)
          [:limit, token.value] # TODO: enforce the integer constraint
        else fail
      end
    end

    # `[19] OffsetClause ::= 'OFFSET' INTEGER`
    def parse_offset_clause
      case
        when accept('OFFSET') && token = accept(:NumericLiteral)
          [:offset, token.value] # TODO: enforce the integer constraint
        else fail
      end
    end

    # `[20] GroupGraphPattern`
    def parse_group_graph_pattern
      # TODO
    end

    # `[21] TriplesBlock`
    def parse_triples_block
      # TODO
    end

    # `[22] GraphPatternNotTriples`
    def parse_graph_pattern_not_triples
      # TODO
    end

    # `[23] OptionalGraphPattern`
    def parse_optional_graph_pattern
      # TODO
    end

    # `[24] GraphGraphPattern`
    def parse_graph_graph_pattern
      # TODO
    end

    # `[25] GroupOrUnionGraphPattern`
    def parse_group_or_union_graph_pattern
      # TODO
    end

    # `[26] Filter`
    def parse_filter
      # TODO
    end

    # `[27] Constraint`
    def parse_constraint
      # TODO
    end

    # `[28] FunctionCall`
    def parse_function_call
      # TODO
    end

    # `[29] ArgList`
    def parse_arg_list
      # TODO
    end

    # `[30] ConstructTemplate`
    def parse_construct_template
      # TODO
    end

    # `[31] ConstructTriples`
    def parse_construct_triples
      # TODO
    end

    # `[32] TriplesSameSubject`
    def parse_triples_same_subject
      # TODO
    end

    # `[33] PropertyListNotEmpty`
    def parse_property_list_not_empty
      # TODO
    end

    # `[34] PropertyList`
    def parse_property_list
      # TODO
    end

    # `[35] ObjectList`
    def parse_object_list
      # TODO
    end

    # `[36] Object`
    def parse_object
      # TODO
    end

    # `[37] Verb`
    def parse_verb
      # TODO
    end

    # `[38] TriplesNode`
    def parse_triples_node
      # TODO
    end

    # `[39] BlankNodePropertyList`
    def parse_blank_node_property_list
      # TODO
    end

    # `[40] Collection`
    def parse_collection
      # TODO
    end

    # `[41] GraphNode`
    def parse_graph_node
      # TODO
    end

    # `[42] VarOrTerm`
    def parse_var_or_term
      # TODO
    end

    # `[43] VarOrIRIref`
    def parse_var_or_iriref
      # TODO
    end

    # `[44] Var ::= VAR1 | VAR2`
    def parse_var
      (token = accept(:Var)) ? RDF::Query::Variable.new(token.value) : fail
    end

    # `[45] GraphTerm`
    def parse_graph_term
      # TODO
    end

    # `[46] Expression`
    def parse_expression
      # TODO
    end

    # `[47] ConditionalOrExpression`
    def parse_conditional_or_expression
      # TODO
    end

    # `[48] ConditionalAndExpression`
    def parse_conditional_and_expression
      # TODO
    end

    # `[49] ValueLogical`
    def parse_value_logical
      # TODO
    end

    # `[50] RelationalExpression`
    def parse_relational_expression
      # TODO
    end

    # `[51] NumericExpression`
    def parse_numeric_expression
      # TODO
    end

    # `[52] AdditiveExpression`
    def parse_additive_expression
      # TODO
    end

    # `[53] MultiplicativeExpression`
    def parse_multiplicative_expression
      # TODO
    end

    # `[54] UnaryExpression`
    def parse_unary_expression
      # TODO
    end

    # `[55] PrimaryExpression`
    def parse_primary_expression
      # TODO
    end

    # `[56] BrackettedExpression`
    def parse_bracketted_expression
      # TODO
    end

    # `[57] BuiltInCall`
    def parse_built_in_call
      # TODO
    end

    # `[58] RegexExpression`
    def parse_regex_expression
      # TODO
    end

    # `[59] IRIrefOrFunction`
    def parse_iriref_or_function
      # TODO
    end

    # `[60] RDFLiteral`
    def parse_rdf_literal
      # TODO
    end

    # `[61] NumericLiteral ::= NumericLiteralUnsigned | NumericLiteralPositive | NumericLiteralNegative`
    def parse_numeric_literal
      (token = accept(:NumericLiteral)) ? RDF::Literal(token.value) : fail
    end

    # `[62] NumericLiteralUnsigned ::= INTEGER | DECIMAL | DOUBLE`
    def parse_numeric_literal_unsigned
      parse_numeric_literal
    end

    # `[63] NumericLiteralPositive ::= INTEGER_POSITIVE | DECIMAL_POSITIVE | DOUBLE_POSITIVE`
    def parse_numeric_literal_positive
      parse_numeric_literal # TODO: enforce the sign constraint
    end

    # `[64] NumericLiteralNegative ::= INTEGER_NEGATIVE | DECIMAL_NEGATIVE | DOUBLE_NEGATIVE`
    def parse_numeric_literal_negative
      parse_numeric_literal # TODO: enforce the sign constraint
    end

    # `[65] BooleanLiteral ::= 'true' | 'false'`
    def parse_boolean_literal
      (token = accept(:BooleanLiteral)) ? RDF::Literal(token.value) : fail
    end

    # `[66] String ::= STRING_LITERAL1 | STRING_LITERAL2 | STRING_LITERAL_LONG1 | STRING_LITERAL_LONG2`
    def parse_string
      (token = accept(:String)) ? RDF::Literal(token.value) : fail
    end

    # `[67] IRIref ::= IRI_REF | PrefixedName`
    def parse_iriref
      parse_iri_ref || parse_prefixed_name
    end

    # `[68] PrefixedName ::= PNAME_LN | PNAME_NS`
    def parse_prefixed_name
      parse_pname_ln || parse_pname_ns
    end

    # `[69] BlankNode ::= BLANK_NODE_LABEL | ANON`
    def parse_blank_node
      (token = accept(:BlankNode)) ? RDF::Node(token.value) : fail
    end

    # `[70] IRI_REF ::= '<' ([^<>"{}|^\`\]-[#x00-#x20])* '>'`
    def parse_iri_ref
      (token = accept(:IRI_REF)) ? RDF::URI(token.value) : fail # TODO: handle relative URLs here?
    end

    # `[71] PNAME_NS ::= PN_PREFIX? ':'`
    def parse_pname_ns
      (token = accept(:PNAME_NS)) ? token.value : fail # FIXME
    end

    # `[72] PNAME_LN ::= PNAME_NS PN_LOCAL`
    def parse_pname_ln
      (token = accept(:PNAME_LN)) ? token.value : fail # FIXME
    end

    # `[76] LANGTAG ::= '@' [a-zA-Z]+ ('-' [a-zA-Z0-9]+)*`
    def parse_langtag
      (token = accept(:LANGTAG)) ? token.value : fail
    end

    # `[92] NIL ::= '(' WS* ')'`
    def parse_nil()
      (token = accept(:NIL)) ? RDF.nil : fail
    end

  private

    ##
    # @param  [Symbol, String] type_or_value
    # @return [Token]
    def accept(type_or_value)
      if (token = tokens.first) && token === type_or_value
        tokens.shift
      end
    end

    ##
    # @return [void]
    def fail
      false
    end
    alias_method :fail!, :fail

    instance_methods.each { |method| public method } # DEBUG

  public
    ##
    # Raised for errors during parsing.
    #
    # @example Raising a parser error
    #   raise SPARQL::Grammar::Parser::Error.new(
    #     "FIXME on line 10",
    #     :input => query, :production => '%', :lineno => 9)
    #
    # @see http://ruby-doc.org/core/classes/StandardError.html
    class Error < StandardError
      ##
      # The input string associated with the error.
      #
      # @return [String]
      attr_reader :input

      ##
      # The grammar production where the error was found.
      #
      # @return [String]
      attr_reader :production

      ##
      # The line number where the error occurred.
      #
      # @return [Integer]
      attr_reader :lineno

      ##
      # Position within line of error.
      #
      # @return [Integer]
      attr_reader :position

      ##
      # Initializes a new lexer error instance.
      #
      # @param  [String, #to_s]          message
      # @param  [Hash{Symbol => Object}] options
      # @option options [String]         :input  (nil)
      # @option options [String]         :production  (nil)
      # @option options [Integer]        :lineno (nil)
      # @option options [Integer]        :position (nil)
      def initialize(message, options = {})
        @input  = options[:input]
        @production  = options[:production]
        @lineno = options[:lineno]
        @position = options[:position]
        super(message.to_s)
      end
    end # class Error
  end # class Parser
end; end # module SPARQL::Grammar
