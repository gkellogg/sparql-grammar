module SPARQL; module Grammar
  ##
  # A parser for the SPARQL 1.0 grammar.
  #
  # @see http://www.w3.org/TR/rdf-sparql-query/#grammar
  # @see http://en.wikipedia.org/wiki/Parsing
  # @see http://en.wikipedia.org/wiki/Recursive_descent_parser
  class Parser
    ##
    # Initializes a new parser instance.
    #
    # @param  [String, #to_s]          input
    # @param  [Hash{Symbol => Object}] options
    def initialize(input = nil, options = {})
      @options = options.dup
      self.input = input if input
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

    ##
    # Returns `true` if the input string is syntactically valid.
    #
    # @return [Boolean]
    def valid?
      nil # TODO
    end

  protected

    # `[1] Query ::= Prologue (SelectQuery | ConstructQuery | DescribeQuery | AskQuery)`
    def query
      result = [:query]
      if (decls = prologue) && decls.size > 1
        result += decls[1..-1]
      end
      result << (select_query || construct_query || describe_query || ask_query)
      result.compact!
      result.size > 1 ? result : false
    end

    # `[2] Prologue ::= BaseDecl? PrefixDecl*`
    def prologue
      result = [:prologue, base_decl || nil, *prefix_decls]
      result.compact!
      result.size > 1 ? result : false
    end

    # `[3] BaseDecl ::= 'BASE' IRI_REF`
    def base_decl
      accept('BASE') ? [:base, iri_ref] : fail
    end

    # `[4] PrefixDecl*`
    def prefix_decls
      result = []
      while decl = prefix_decl
        result << decl
      end
      result
    end

    # `[4] PrefixDecl ::= 'PREFIX' PNAME_NS IRI_REF`
    def prefix_decl
      accept('PREFIX') ? [:prefix, pname_ns, iri_ref] : fail
    end

    # `[5] SelectQuery`
    def select_query
      # TODO
    end

    # `[6] ConstructQuery`
    def construct_query
      # TODO
    end

    # `[7] DescribeQuery`
    def describe_query
      # TODO
    end

    # `[8] AskQuery`
    def ask_query
      # TODO
    end

    # `[9] DatasetClause ::= 'FROM' (DefaultGraphClause | NamedGraphClause)`
    def dataset_clause
      accept('FROM') ? (default_graph_clause || named_graph_clause) : fail # FIXME
    end

    # `[10] DefaultGraphClause ::= SourceSelector`
    def default_graph_clause
      (iri = source_selector) ? [:default, iri] : fail # FIXME
    end

    # `[11] NamedGraphClause ::= 'NAMED' SourceSelector`
    def named_graph_clause
      accept('NAMED') ? [:named, source_selector] : fail # FIXME
    end

    # `[12] SourceSelector ::= IRIref`
    def source_selector
      iriref
    end

    # `[13] WhereClause`
    def where_clause
      # TODO
    end

    # `[14] SolutionModifier`
    def solution_modifier
      # TODO
    end

    # `[15] LimitOffsetClauses`
    def limit_offset_clauses
      # TODO
    end

    # `[16] OrderClause`
    def order_clause
      # TODO
    end

    # `[17] OrderCondition`
    def order_condition
      # TODO
    end

    # `[18] LimitClause ::= 'LIMIT' INTEGER`
    def limit_clause
      case
        when accept('LIMIT') && token = accept(:NumericLiteral)
          [:limit, token.value] # TODO: enforce the integer constraint
        else fail
      end
    end

    # `[19] OffsetClause ::= 'OFFSET' INTEGER`
    def offset_clause
      case
        when accept('OFFSET') && token = accept(:NumericLiteral)
          [:offset, token.value] # TODO: enforce the integer constraint
        else fail
      end
    end

    # `[20] GroupGraphPattern`
    def group_graph_pattern
      # TODO
    end

    # `[21] TriplesBlock`
    def triples_block
      # TODO
    end

    # `[22] GraphPatternNotTriples`
    def graph_pattern_not_triples
      # TODO
    end

    # `[23] OptionalGraphPattern`
    def optional_graph_pattern
      # TODO
    end

    # `[24] GraphGraphPattern`
    def graph_graph_pattern
      # TODO
    end

    # `[25] GroupOrUnionGraphPattern`
    def group_or_union_graph_pattern
      # TODO
    end

    # `[26] Filter`
    def filter
      # TODO
    end

    # `[27] Constraint`
    def constraint
      # TODO
    end

    # `[28] FunctionCall`
    def function_call
      # TODO
    end

    # `[29] ArgList`
    def arg_list
      # TODO
    end

    # `[30] ConstructTemplate`
    def construct_template
      # TODO
    end

    # `[31] ConstructTriples`
    def construct_triples
      # TODO
    end

    # `[32] TriplesSameSubject`
    def triples_same_subject
      # TODO
    end

    # `[33] PropertyListNotEmpty`
    def property_list_not_empty
      # TODO
    end

    # `[34] PropertyList`
    def property_list
      # TODO
    end

    # `[35] ObjectList`
    def object_list
      # TODO
    end

    # `[36] Object`
    def object
      # TODO
    end

    # `[37] Verb`
    def verb
      # TODO
    end

    # `[38] TriplesNode`
    def triples_node
      # TODO
    end

    # `[39] BlankNodePropertyList`
    def blank_node_property_list
      # TODO
    end

    # `[40] Collection`
    def collection
      # TODO
    end

    # `[41] GraphNode`
    def graph_node
      # TODO
    end

    # `[42] VarOrTerm`
    def var_or_term
      # TODO
    end

    # `[43] VarOrIRIref`
    def var_or_iriref
      # TODO
    end

    # `[44] Var ::= VAR1 | VAR2`
    def var
      (token = accept(:Var)) ? RDF::Query::Variable.new(token.value) : fail
    end

    # `[45] GraphTerm`
    def graph_term
      # TODO
    end

    # `[46] Expression`
    def expression
      # TODO
    end

    # `[47] ConditionalOrExpression`
    def conditional_or_expression
      # TODO
    end

    # `[48] ConditionalAndExpression`
    def conditional_and_expression
      # TODO
    end

    # `[49] ValueLogical`
    def value_logical
      # TODO
    end

    # `[50] RelationalExpression`
    def relational_expression
      # TODO
    end

    # `[51] NumericExpression`
    def numeric_expression
      # TODO
    end

    # `[52] AdditiveExpression`
    def additive_expression
      # TODO
    end

    # `[53] MultiplicativeExpression`
    def multiplicative_expression
      # TODO
    end

    # `[54] UnaryExpression`
    def unary_expression
      # TODO
    end

    # `[55] PrimaryExpression`
    def primary_expression
      # TODO
    end

    # `[56] BrackettedExpression`
    def bracketted_expression
      # TODO
    end

    # `[57] BuiltInCall`
    def built_in_call
      # TODO
    end

    # `[58] RegexExpression`
    def regex_expression
      # TODO
    end

    # `[59] IRIrefOrFunction`
    def iriref_or_function
      # TODO
    end

    # `[60] RDFLiteral`
    def rdf_literal
      # TODO
    end

    # `[61] NumericLiteral ::= NumericLiteralUnsigned | NumericLiteralPositive | NumericLiteralNegative`
    def numeric_literal
      (token = accept(:NumericLiteral)) ? RDF::Literal(token.value) : fail
    end

    # `[62] NumericLiteralUnsigned ::= INTEGER | DECIMAL | DOUBLE`
    def numeric_literal_unsigned
      numeric_literal
    end

    # `[63] NumericLiteralPositive ::= INTEGER_POSITIVE | DECIMAL_POSITIVE | DOUBLE_POSITIVE`
    def numeric_literal_positive
      numeric_literal # TODO: enforce the sign constraint
    end

    # `[64] NumericLiteralNegative ::= INTEGER_NEGATIVE | DECIMAL_NEGATIVE | DOUBLE_NEGATIVE`
    def numeric_literal_negative
      numeric_literal # TODO: enforce the sign constraint
    end

    # `[65] BooleanLiteral ::= 'true' | 'false'`
    def boolean_literal
      (token = accept(:BooleanLiteral)) ? RDF::Literal(token.value) : fail
    end

    # `[66] String ::= STRING_LITERAL1 | STRING_LITERAL2 | STRING_LITERAL_LONG1 | STRING_LITERAL_LONG2`
    def string
      (token = accept(:String)) ? RDF::Literal(token.value) : fail
    end

    # `[67] IRIref ::= IRI_REF | PrefixedName`
    def iriref
      iri_ref || prefixed_name
    end

    # `[68] PrefixedName ::= PNAME_LN | PNAME_NS`
    def prefixed_name
      pname_ln || pname_ns
    end

    # `[69] BlankNode ::= BLANK_NODE_LABEL | ANON`
    def blank_node
      (token = accept(:BlankNode)) ? RDF::Node(token.value) : fail
    end

    # `[70] IRI_REF ::= '<' ([^<>"{}|^\`\]-[#x00-#x20])* '>'`
    def iri_ref
      (token = accept(:IRI_REF)) ? RDF::URI(token.value) : fail # TODO: handle relative URLs here?
    end

    # `[71] PNAME_NS ::= PN_PREFIX? ':'`
    def pname_ns
      (token = accept(:PNAME_NS)) ? token.value : fail # FIXME
    end

    # `[72] PNAME_LN ::= PNAME_NS PN_LOCAL`
    def pname_ln
      (token = accept(:PNAME_LN)) ? token.value : fail # FIXME
    end

    # `[76] LANGTAG ::= '@' [a-zA-Z]+ ('-' [a-zA-Z0-9]+)*`
    def langtag
      (token = accept(:LANGTAG)) ? token.value : fail
    end

    # `[92] NIL ::= '(' WS* ')'`
    def nil()
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
  end # class Parser
end; end # module SPARQL::Grammar
