module SPARQL; module Grammar
  ##
  # A parser for the SPARQL 1.0 grammar.
  #
  # @see http://www.w3.org/TR/rdf-sparql-query/#grammar
  # @see http://en.wikipedia.org/wiki/LR_parser
  # @see http://www.w3.org/2000/10/swap/grammar/predictiveParser.py
  # @see http://www.w3.org/2001/sw/DataAccess/rq23/parsers/sparql.ttl
  class Parser
    include SPARQL::Grammar::Meta

    START = SPARQL_GRAMMAR.Query

    ##
    # Initializes a new parser instance.
    #
    # @param  [String, #to_s]          input
    # @param  [Hash{Symbol => Object}] options
    # @option options [Boolean] :progress
    #   Debug output for parser progress
    # @option options [Hash]     :prefixes     (Hash.new)
    #   the prefix mappings to use (for acessing intermediate parser productions)
    # @option options [#to_s]    :base_uri     (nil)
    #   the base URI to use when resolving relative URIs (for acessing intermediate parser productions)
    # @option options [#to_s]    :anon_base     ("gen0000")
    #   Basis for generating anonymous Nodes
    def initialize(input = nil, options = {})
      @options = {:anon_base => "gen0000"}.merge(options)
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

    ##
    # Returns `true` if the input string is syntactically valid.
    #
    # @return [Boolean]
    def valid?
      parse
    rescue Error
      false
    end

    # Parse query
    #
    # The result is a SPARQL Algebra S-List. Productions return an array such as the following:
    #
    #   [:prefix, :foo, <http://example.com>]
    #   [:prologue, [:prefix, :foo, <http://example.com>]]
    #   [:prologue, [:base, <http://example.com>], [:prefix :foo <http://example.com>]]
    #
    # Algebra is based on the SPARQL Algebra notes
    # @param [Symbol, #to_s] prod The starting production for the parser.
    #   It may be a URI from the grammar, or a symbol representing the local_name portion of the grammar URI.
    # @result [Array]
    # @see http://www.w3.org/2001/sw/DataAccess/rq23/rq24-algebra.html
    # @see http://axel.deri.ie/sparqltutorial/ESWC2007_SPARQL_Tutorial_unit2b.pdf
    def parse(prod = START)
      @prod_data = [{}]
      prod = prod.to_s.split("#").last.to_sym unless prod.is_a?(Symbol)
      todo_stack = [{:prod => prod, :terms => nil}]

      while !todo_stack.empty?
        pushed = false
        if todo_stack.last[:terms].nil?
          todo_stack.last[:terms] = []
          token = tokens.first
          @lineno = token.lineno if token
          debug("parse(token)", "#{token.inspect}, prod #{todo_stack.last[:prod]}, depth #{todo_stack.length}")
          
          # Got an opened production
          onStart(abbr(todo_stack.last[:prod]))
          break if token.nil?
          
          cur_prod = todo_stack.last[:prod]
          prod_branch = BRANCHES[cur_prod.to_sym]
          error("parse", "No branches found for '#{abbr(cur_prod)}'",
            :production => cur_prod, :token => token) if prod_branch.nil?
          sequence = prod_branch[token.representation]
          if sequence.nil?
            expected = prod_branch.values.uniq.map {|u| u.map {|v| abbr(v).inspect}.join(",")}
            error("parse", "Found '#{token.inspect}' when parsing a #{abbr(cur_prod)}. expected #{expected.join(' | ')}",
              :production => cur_prod, :token => token)
          end
          todo_stack.last[:terms] += sequence
        end
        
        debug("parse(terms)", "stack #{todo_stack.last.inspect}, depth #{todo_stack.length}")
        while !todo_stack.last[:terms].to_a.empty?
          term = todo_stack.last[:terms].shift
          debug("parse tokens", tokens.inspect)
          if tokens.map(&:representation).include?(term)
            token = accept(term)
            @lineno = token.lineno if token
            debug("parse", "term(#{token.inspect}): #{term}")
            if token
              onToken(abbr(term), token.value)
            else
              error("parse", "Found '#{word}...'; #{term} expected",
                :production => todo_stack.last[:prod], :token => tokens.first)
            end
          else
            todo_stack << {:prod => term, :terms => nil}
            debug("parse(push)", "stack #{term}, depth #{todo_stack.length}")
            pushed = true
            break
          end
        end
        
        while !pushed && !todo_stack.empty? && todo_stack.last[:terms].to_a.empty?
          debug("parse(pop)", "stack #{todo_stack.last.inspect}, depth #{todo_stack.length}")
          todo_stack.pop
          self.onFinish
        end
      end
      while !todo_stack.empty?
        debug("parse(pop)", "stack #{todo_stack.last.inspect}, depth #{todo_stack.length}")
        todo_stack.pop
        self.onFinish
      end
      
      # The last thing on the @prod_data stack is the result
      result = prod_data
      if result.is_a?(Hash) && !result.empty?
        key = result.keys.first
        [key] + result[key]  # Creates [:BGP, [:triple], ...]
      end
    end
    
    ##
    # Returns the URI prefixes currently defined for this parser.
    #
    # @example
    #   parser.prefixes[:dc]  #=> RDF::URI('http://purl.org/dc/terms/')
    #
    # @return [Hash{Symbol => RDF::URI}]
    # @since  0.3.0
    def prefixes
      @options[:prefixes] ||= {}
    end

    ##
    # Defines the given URI prefixes for this parser.
    #
    # @example
    #   parser.prefixes = {
    #     :dc => RDF::URI('http://purl.org/dc/terms/'),
    #   }
    #
    # @param  [Hash{Symbol => RDF::URI}] prefixes
    # @return [Hash{Symbol => RDF::URI}]
    # @since  0.3.0
    def prefixes=(prefixes)
      @options[:prefixes] = prefixes
    end

    ##
    # Defines the given named URI prefix for this parser.
    #
    # @example Defining a URI prefix
    #   parser.prefix :dc, RDF::URI('http://purl.org/dc/terms/')
    #
    # @example Returning a URI prefix
    #   parser.prefix(:dc)    #=> RDF::URI('http://purl.org/dc/terms/')
    #
    # @overload prefix(name, uri)
    #   @param  [Symbol, #to_s]   name
    #   @param  [RDF::URI, #to_s] uri
    #
    # @overload prefix(name)
    #   @param  [Symbol, #to_s]   name
    #
    # @return [RDF::URI]
    def prefix(name, uri = nil)
      name = name.to_s.empty? ? nil : (name.respond_to?(:to_sym) ? name.to_sym : name.to_s.to_sym)
      uri.nil? ? prefixes[name] : prefixes[name] = uri
    end

    ##
    # Returns the Base URI defined for the parser,
    # as specified or when parsing a BASE prologue element.
    #
    # @example
    #   parser.base  #=> RDF::URI('http://example.com/')
    #
    # @return [HRDF::URI]
    def base_uri
      @options[:base_uri]
    end

    ##
    # Set the Base URI to use for this parser.
    #
    # @param  [RDF::URI, #to_s] uri
    #
    # @example
    #   parser.base_uri = RDF::URI('http://purl.org/dc/terms/')
    #
    # @return [RDF::URI]
    def base_uri=(uri)
      @options[:base_uri] = uri
    end

  protected

    # Handlers used to define actions for each productions.
    # If a context is defined, create a producation data element and add to the @prod_data stack
    # If entries are defined, pass production data to :start and/or :finish handlers
    def contexts(production)
      case production
      when :PrefixDecl
        # [4] PrefixDecl := 'PREFIX' PNAME_NS IRI_REF";
        {
          :finish => lambda { |data| self.prefix(data[:prefix], data[:iri]) if data[:iri] }
        }
      when :TriplesBlock
        # [21]    TriplesBlock ::= TriplesSameSubject ( '.' TriplesBlock? )?
        {
          :finish => lambda { |data|
            if data[:triple]
              triples = data[:triple].map {|v| [:triple, v[:subject], v[:predicate], v[:object]]}
              add_prod_data(:BGP, triples)
            end
        
            # Append triples from ('.' TriplesBlock? )? 
            if data[:BGP]
              add_prod_data(:BGP, data[:BGP])
            end
          }
        }
      when :TriplesSameSubject
        # [32]    TriplesSameSubject ::= VarOrTerm PropertyListNotEmpty | TriplesNode PropertyList
        {
          :finish => lambda { |data| add_prod_data(:triple, data[:triple]) }
        }
      when :PropertyListNotEmpty
        # [33]    PropertyListNotEmpty ::= Verb ObjectList ( ';' ( Verb ObjectList )? )*
        {
          :start => lambda {|data|
            subject = prod_data[:VarOrTerm] || prod_data[:TriplesNode] || prod_data[:GraphNode]
            error(nil, "Expected VarOrTerm or TriplesNode or GraphNode", :production => :PropertyListNotEmpty) unless subject
            data[:Subject] = subject
          },
          :finish => lambda {|data| add_prod_data(:triple, data[:triple])}
        }
      when :ObjectList
        # [35]    ObjectList ::= Object ( ',' Object )*
        {
          :start => lambda { |data|
            # Called after Verb. The prod_data stack should have Subject and Verb elements
            error(nil, "Expected Subject", :production => :ObjectList) unless prod_data.has_key?(:Subject)
            error(nil, "Expected Verb", :production => :ObjectList) unless prod_data.has_key?(:Verb)
            data[:Subject] = prod_data[:Subject]
            data[:Verb] = prod_data[:Verb].last
          },
          :finish => lambda { |data| add_prod_data(:triple, data[:triple]) }
        }
      when :Object
        # [36]    Object ::= GraphNode
        {
          :finish => lambda { |data|
            object = data[:VarOrTerm] || data[:TriplesNode] || data[:GraphNode]
            add_triple(:Object, :subject => prod_data[:Subject], :predicate => prod_data[:Verb], :object => object)
            add_prod_data(:triple, data[:triple])
          }
        }
      when :Verb
        {
          :finish => lambda { |data| data.values.each {|v| add_prod_data(:Verb, v)} }
        }
      when :TriplesNode
        # [38]    TriplesNode ::= Collection | BlankNodePropertyList
        #
        # Allocate Blank Node for () or []
        {
          :start => lambda { |data| data[:TriplesNode] = gen_node() },
          :finish => lambda { |data| 
            add_prod_data(:triple, data[:triple])
            add_prod_data(:TriplesNode, data[:TriplesNode])
          }
        }
      when :Collection
        # [40]    Collection ::= '(' GraphNode+ ')'
        {
          :start => lambda { |data| data[:Collection] = prod_data[:TriplesNode]},
          :finish => lambda { |data| expand_collection(data) }
        }
      when :GraphNode
        # [41]    GraphNode ::= VarOrTerm | TriplesNode
        {
          :finish => lambda { |data|
            term = data[:VarOrTerm] || data[:TriplesNode]
            add_prod_data(:triple, data[:triple])
            add_prod_data(:GraphNode, term)
          }
        }
      when :VarOrTerm
        # [42]    VarOrTerm ::= Var | GraphTerm
        {
          :finish => lambda { |data| data.values.each {|v| add_prod_data(:VarOrTerm, v)} }
        }
      when :GraphTerm
        # [45]    GraphTerm ::= IRIref | RDFLiteral | NumericLiteral | BooleanLiteral | BlankNode | NIL
        {
          :finish => lambda { |data| data.values.each {|v| add_prod_data(:GraphTerm, v)} }
        }
      when :RDFLiteral
        # [60]    RDFLiteral ::= String ( LANGTAG | ( '^^' IRIref ) )?
        {
          :finish => lambda { |data|
            lit = data.dup
            str = lit.delete(:string)
            lit[:datatype] = lit.delete(:iri) if lit[:iri]
            add_prod_data(:literal, RDF::Literal.new(str, lit))
          }
        }
      when :NumericLiteralNegative
        # [64]    NumericLiteralNegative ::= INTEGER_NEGATIVE | DECIMAL_NEGATIVE | DOUBLE_NEGATIVE
        {
          :finish => lambda { |data| add_prod_data(:literal, -data.values.flatten.last) }
        }
      when :IRIref
        # [67]    IRIref ::= IRI_REF | PrefixedName
        {
          :finish => lambda { |data| add_prod_data(:IRIref, data[:iri]) if data.has_key?(:iri) }
        }
      when :PrefixedName
        # [68]    PrefixedName ::= PNAME_LN | PNAME_NS
        {
          :finish => lambda { |data| add_prod_data(:iri, data[:PrefixedName]) }
        }
      end
    end

    # Start for production
    def onStart(prod)
      context = contexts(prod.to_sym)
      @productions << prod
      if context
        # Create a new production data element, potentially allowing handler to customize before pushing on the @prod_data stack
        progress("#{prod}(:start):#{@prod_data.length}", ($verbose ? prod_data.inspect : prod_data.keys.inspect))
        data = {}
        context[:start].call(data) if context.has_key?(:start)
        @prod_data << data
      else
        progress("#{prod}(:start, skip):#{@prod_data.length}", '')
      end
      #puts @prod_data.inspect
    end

    # Finish of production
    def onFinish
      prod = @productions.pop()
      context = contexts(prod.to_sym)
      if context
        # Pop production data element from stack, potentially allowing handler to use it
        data = @prod_data.pop
        progress("#{prod}(:finish):#{@prod_data.length}", ($verbose ? prod_data.inspect : prod_data.keys.inspect))
        context[:finish].call(data) if context.has_key?(:finish)
      else
        progress("#{prod}(:finish, skip):#{@prod_data.length}", '')
      end
    end

    # Handlers for individual tokens based on production
    def token_productions(parent_production, production)
      case parent_production
        # [3] BaseDecl ::= 'BASE' IRI_REF`
      when :BaseDecl
        case production
        when :IRI_REF
          lambda { |token| self.base_uri = uri(token) }
        end
      when :PrefixDecl
        # [4] PrefixDecl := 'PREFIX' PNAME_NS IRI_REF";
        case production
        when :IRI_REF
          lambda { |token| prod_data[:iri] = uri(self.base_uri, token) }
        when :PNAME_NS
          lambda { |token| prod_data[:prefix] = uri(token && token.to_sym) }
        end
      else
        case production
        when :a
          # [37]    Verb ::= VarOrIRIref | 'a'
          lambda { |token| add_prod_data(:Verb, RDF.type) }
        when :VAR1, :VAR2
          # [44]    Var ::= VAR1 | VAR2
          lambda { |token| add_prod_data(:Var, RDF::Query::Variable.new(token)) }
        when :BooleanLiteral
          # [45]    GraphTerm ::= IRIref | RDFLiteral | NumericLiteral | BooleanLiteral | BlankNode | NIL
          lambda { |token|
            add_prod_data(:literal, RDF::Literal.new(token, :datatype => RDF::XSD.boolean))
          }
        when :LANGTAG
          # [60]    RDFLiteral ::= String ( LANGTAG | ( '^^' IRIref ) )?
          lambda { |token| add_prod_data(:language, token) }
        when :INTEGER
          # [62]    NumericLiteralUnsigned ::= INTEGER | DECIMAL | DOUBLE
          lambda { |token| add_prod_data(:literal, RDF::Literal.new(token, :datatype => RDF::XSD.integer)) }
        when :DECIMAL
          # [62]    NumericLiteralUnsigned ::= INTEGER | DECIMAL | DOUBLE
          lambda { |token| add_prod_data(:literal, RDF::Literal.new(token, :datatype => RDF::XSD.decimal)) }
        when :DOUBLE
          # [62]    NumericLiteralUnsigned ::= INTEGER | DECIMAL | DOUBLE
          lambda { |token| add_prod_data(:literal, RDF::Literal.new(token, :datatype => RDF::XSD.double)) }
        when :STRING_LITERAL1, :STRING_LITERAL2, :STRING_LITERAL_LONG1, :STRING_LITERAL_LONG2
          # [66]    String ::= STRING_LITERAL1 | STRING_LITERAL2 | STRING_LITERAL_LONG1 | STRING_LITERAL_LONG2
          lambda { |token| add_prod_data(:string, token) }
        when :IRI_REF
          # [67]    IRIref ::= IRI_REF | PrefixedName
          lambda { |token| add_prod_data(:iri, uri(self.base_uri, token)) }
        when :PNAME_NS
          # [68]    PrefixedName ::= PNAME_LN | PNAME_NS
          lambda { |token| add_prod_data(:PrefixedName, ns(nil, token)) }
        when :PNAME_LN
          # [68]    PrefixedName ::= PNAME_LN | PNAME_NS
          lambda { |token| add_prod_data(:PrefixedName, ns(*token)) }
        when :BLANK_NODE_LABEL
          # [69]    BlankNode ::= BLANK_NODE_LABEL | ANON
          lambda { |token| add_prod_data(:BlankNode, gen_node(token)) }
        when :ANON
          # [69]    BlankNode ::= BLANK_NODE_LABEL | ANON
          lambda { |token| add_prod_data(:BlankNode, gen_node()) }
        end
      end
    end
    
    # A token
    def onToken(prod, token)
      unless @productions.empty?
        parentProd = @productions.last
        token_production = token_productions(parentProd.to_sym, prod.to_sym)
        if token_production
          progress("#{parentProd}(:token)", "#{token}: #{$verbose ? prod_data.inspect : prod_data.keys.inspect}")
          token_production.call(token)
        else
          progress("#{parentProd}(:token, skip)", token)
        end
      else
        error("#{parentProd}(:token)", "Token has no parent production", :production => prod)
      end
    end

    # Current ProdData element
    def prod_data; @prod_data.last; end
    
    # @param [String] str Error string
    # @param [Hash] options
    # @option options [URI, #to_s] :production
    # @option options [Token] :token
    def error(node, message, options = {})
      node ||= options[:production]
      $stderr.puts("[#{@lineno}]#{' ' * @productions.length}#{node}: #{message}")
      raise Error.new("Error on production #{options[:production].inspect}#{' with input ' + options[:token].inspect if options[:token]} at line #{@lineno}: #{message}", options)
    end

    ##
    # Progress output when parsing
    # @param [String] str
    def progress(node, message, options = {})
      $stderr.puts("[#{@lineno}]#{' ' * @productions.length}#{node}: #{message}") if @options[:progress]
    end

    ##
    # Progress output when debugging
    # @param [String] str
    def debug(node, message, options = {})
      $stderr.puts("[#{@lineno}]#{' ' * @productions.length}#{node}: #{message}") if $verbose
    end

    # [5] SelectQuery ::= 'SELECT' ( 'DISTINCT' | 'REDUCED' )? ( Var+ | '*' ) DatasetClause* WhereClause
    # [6] ConstructQuery ::= 'CONSTRUCT' ConstructTemplate DatasetClause* WhereClause SolutionModifier
    # [7] DescribeQuery ::= 'DESCRIBE' ( VarOrIRIref+ | '*' ) DatasetClause* WhereClause? SolutionModifier
    # `[8 AskQuery ::= 'ASK' DatasetClause* WhereClause
    # [9] DatasetClause ::= 'FROM' (DefaultGraphClause | NamedGraphClause)
    # [10] DefaultGraphClause ::= SourceSelector
    # [11] NamedGraphClause ::= 'NAMED' SourceSelector`
    # [12]    SourceSelector ::= IRIref
    # [13]    WhereClause ::= 'WHERE'? GroupGraphPattern
    # [14]    SolutionModifier ::= OrderClause? LimitOffsetClauses?
    # [15]    LimitOffsetClauses ::= ( LimitClause OffsetClause? | OffsetClause LimitClause? )
    # [16]    OrderClause ::= 'ORDER' 'BY' OrderCondition+
    # [17]    OrderCondition ::= ( ( ASC' | 'DESC' ) BrackettedExpression )
    #                          | ( Constraint | Var )
    # [18]    LimitClause ::= 'LIMIT' INTEGER
    # [19]    OffsetClause ::= 'OFFSET' INTEGER
    # [20]    GroupGraphPattern ::= '{' TriplesBlock? ( ( GraphPatternNotTriples | Filter ) '.'? TriplesBlock? )* '}'
    # [21]    TriplesBlock ::= TriplesSameSubject ( '.' TriplesBlock? )?
    # [22]    GraphPatternNotTriples ::= OptionalGraphPattern | GroupOrUnionGraphPattern | GraphGraphPattern
    # [23]    OptionalGraphPattern ::= 'OPTIONAL' GroupGraphPattern
    # [24]    GraphGraphPattern ::= 'GRAPH' VarOrIRIref GroupGraphPattern
    # [25]    GroupOrUnionGraphPattern ::= GroupGraphPattern ( 'UNION' GroupGraphPattern )*
    # [26]    Filter ::= 'FILTER' Constraint
    # [27]    Constraint ::= BrackettedExpression | BuiltInCall | FunctionCall
    # [28]    FunctionCall ::= IRIref ArgList
    # [29]    ArgList ::= ( NIL | '(' Expression ( ',' Expression )* ')' )
    # [30]    ConstructTemplate ::= '{' ConstructTriples? '}'
    # [31]    ConstructTriples ::= TriplesSameSubject ( '.' ConstructTriples? )?
    # [32]    TriplesSameSubject ::= VarOrTerm PropertyListNotEmpty | TriplesNode PropertyList
    # [33]    PropertyListNotEmpty ::= Verb ObjectList ( ';' ( Verb ObjectList )? )*
    # [34]    PropertyList ::= PropertyListNotEmpty?
    # [35]    ObjectList ::= Object ( ',' Object )*
    # [36]    Object ::= GraphNode
    # [37]    Verb ::= VarOrIRIref | 'a'
    # [38]    TriplesNode ::= Collection | BlankNodePropertyList
    # [39]    BlankNodePropertyList ::= '[' PropertyListNotEmpty ']'
    # [40]    Collection ::= '(' GraphNode+ ')'
    #
    # Take collection of objects and create RDF Collection using rdf:first, rdf:rest and rdf:nil
    def expand_collection(data)
      # Add any triples generated from deeper productions
      add_prod_data(:triple, data[:triple])
      
      # Create list items for each element in data[:GraphNode]
      first = col = data[:Collection]
      list = data[:GraphNode].flatten.compact
      last = list.pop

      list.each do |r|
        add_triple(:Collection, :subject => first, :predicate => RDF["first"], :object => r)
        rest = gen_node()
        add_triple(:Collection, :subject => first, :predicate => RDF["rest"], :object => rest)
        first = rest
      end
      
      if last
        add_triple(:Collection, :subject => first, :predicate => RDF["first"], :object => last)
      end
      add_triple(:Collection, :subject => first, :predicate => RDF["rest"], :object => RDF["nil"])
    end

    # [41]    GraphNode ::= VarOrTerm | TriplesNode
    # [42]    VarOrTerm ::= Var | GraphTerm
    # [43]    VarOrIRIref ::= Var | IRIref
    # [44]    Var ::= VAR1 | VAR2
    # [46]    Expression ::= ConditionalOrExpression
    # [47]    ConditionalOrExpression ::= ConditionalAndExpression ( '||' ConditionalAndExpression )*
    # [48]    ConditionalAndExpression ::= ValueLogical ( '&&' ValueLogical )*
    # [49]    ValueLogical ::= RelationalExpression
    # [50]    RelationalExpression ::= NumericExpression ( '=' NumericExpression | '!=' NumericExpression | '<' NumericExpression | '>' NumericExpression | '<=' NumericExpression | '>=' NumericExpression )?
    # [51]    NumericExpression ::= AdditiveExpression
    # [52]    AdditiveExpression ::= MultiplicativeExpression ( '+' MultiplicativeExpression | '-' MultiplicativeExpression | NumericLiteralPositive | NumericLiteralNegative )*
    # [53]    MultiplicativeExpression ::= UnaryExpression ( '*' UnaryExpression | '/' UnaryExpression )*
    # [54]    UnaryExpression ::= '!' PrimaryExpression
    #                           | '+' PrimaryExpression
    #                           | '-' PrimaryExpression
    #                           | PrimaryExpression
    # [55]    PrimaryExpression ::= BrackettedExpression | BuiltInCall | IRIrefOrFunction | RDFLiteral | NumericLiteral | BooleanLiteral | Var
    # [56]    BrackettedExpression ::= '(' Expression ')'
    # [57]    BuiltInCall ::= 'STR' '(' Expression ')'
    #                       | 'LANG' '(' Expression ')'
    #                       | 'LANGMATCHES' '(' Expression ',' Expression ')'
    #                       | 'DATATYPE' '(' Expression ')'
    #                       | 'BOUND' '(' Var ')'
    #                       | 'sameTerm' '(' Expression ',' Expression ')'
    #                       | 'isIRI' '(' Expression ')'
    #                       | 'isURI' '(' Expression ')'
    #                       | 'isBLANK' '(' Expression ')'
    #                       | 'isLITERAL' '(' Expression ')'
    #                       | RegexExpression
    # [58]    RegexExpression ::= 'REGEX' '(' Expression ',' Expression ( ',' Expression )? ')'
    # [59]    IRIrefOrFunction ::= IRIref ArgList?
    # [61]    NumericLiteral ::= NumericLiteralUnsigned | NumericLiteralPositive | NumericLiteralNegative
    # [63]    NumericLiteralPositive ::= INTEGER_POSITIVE | DECIMAL_POSITIVE | DOUBLE_POSITIVE
    # [64]    NumericLiteralNegative ::= INTEGER_NEGATIVE | DECIMAL_NEGATIVE | DOUBLE_NEGATIVE
    # [65]    BooleanLiteral ::= 'true' | 'false'
    # [70]    IRI_REF  ::= '<' ([^<>"{}|^`\]-[#x00-#x20])* '>'
    # [71]    PNAME_NS ::= PN_PREFIX? ':'
    # [72]    PNAME_LN ::= PNAME_NS PN_LOCAL
    # [73]    BLANK_NODE_LABEL ::= '_:' PN_LOCAL
    # [74]    VAR1 ::= '?' VARNAME
    # [75]    VAR2 ::= '$' VARNAME
    # [76]    LANGTAG ::= '@' [a-zA-Z]+ ('-' [a-zA-Z0-9]+)*
    # [77]    INTEGER ::= [0-9]+
    # [78]    DECIMAL ::= [0-9]+ '.' [0-9]* | '.' [0-9]+
    # [79]    DOUBLE ::= [0-9]+ '.' [0-9]* EXPONENT | '.' ([0-9])+ EXPONENT | ([0-9])+ EXPONENT
    # [80]    INTEGER_POSITIVE ::= '+' INTEGER
    # [81]    DECIMAL_POSITIVE ::= '+' DECIMAL
    # [82]    DOUBLE_POSITIVE ::= +' DOUBLE
    # [83]    INTEGER_NEGATIVE ::= '-' INTEGER
    # [84]    DECIMAL_NEGATIVE ::= '-' DECIMAL
    # [85]    DOUBLE_NEGATIVE ::= '-' DOUBLE
    # [86]    EXPONENT ::= [eE] [+-]? [0-9]+
    # [87]    STRING_LITERAL1 ::= "'" ( ([^#x27#x5C#xA#xD]) | ECHAR )* "'"
    # [88]    STRING_LITERAL2 ::= '"' ( ([^#x22#x5C#xA#xD]) | ECHAR )* '"'
    # [89]    STRING_LITERAL_LONG1 ::= "'''" ( ( "'" | "''" )? ( [^'\] | ECHAR ) )* "'''"
    # [90]    STRING_LITERAL_LONG2 ::= '"""' ( ( '"' | '""' )? ( [^"\] | ECHAR ) )* '"""'
    # [91]    ECHAR ::= '\' [tbnrf\"']
    # [92]    NIL ::= '(' WS* ')'
    # [93]    WS ::= #x20 | #x9 | #xD | #xA
    # [94]    ANON ::= '[' WS* ']'
    # [95]    PN_CHARS_BASE ::= [A-Z] | [a-z] | [#x00C0-#x00D6] | [#x00D8-#x00F6] | [#x00F8-#x02FF] | [#x0370-#x037D] | [#x037F-#x1FFF] | [#x200C-#x200D] | [#x2070-#x218F] | [#x2C00-#x2FEF] | [#x3001-#xD7FF] | [#xF900-#xFDCF] | [#xFDF0-#xFFFD] | [#x10000-#xEFFFF]
    # [96]    PN_CHARS_U ::= PN_CHARS_BASE | '_'
    # [97]    VARNAME ::= ( PN_CHARS_U | [0-9] ) ( PN_CHARS_U | [0-9] | #x00B7 | [#x0300-#x036F] | [#x203F-#x2040] )*
    # [98]    PN_CHARS ::= PN_CHARS_U | '-' | [0-9] | #x00B7 | [#x0300-#x036F] | [#x203F-#x2040]
    # [99]    PN_PREFIX ::= PN_CHARS_BASE ((PN_CHARS|'.')* PN_CHARS)?
    # [100]   PN_LOCAL ::= ( PN_CHARS_U | [0-9] ) ((PN_CHARS|'.')* PN_CHARS)?

  private

    def abbr(prodURI)
      prodURI.to_s.split('#').last
    end
  
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

    # Add values to production data, values aranged as an array
    def add_prod_data(sym, values)
      case values
      when Array
        debug "add_prod_data(#{sym})", "#{prod_data[sym].inspect} += #{values.inspect}"
        prod_data[sym] ||= []
        prod_data[sym] += values
      when nil
        return
      else
        debug "add_prod_data(#{sym})", "#{prod_data[sym].inspect} << #{values.inspect}"
        prod_data[sym] ||= []
        prod_data[sym] << values
      end
    end
    
    # Generate a BNode identifier
    def gen_node(id = nil)
      unless id
        id = @options[:anon_base] = @options[:anon_base].succ
      end
      RDF::Node.new(id)
    end
    
    # Create URIs
    def uri(value, append = nil)
      value = RDF::URI.new(value)
      value = value.join(append) if append
      #value.validate! if validate? && value.respond_to?(:validate)
      #value.canonicalize! if canonicalize?
      #value = RDF::URI.intern(value) if intern?
      value
    end
    
    def ns(prefix, suffix)
      base = prefix(prefix).to_s
      suffix = suffix.to_s.sub(/^\#/, "") if base.index("#")
      debug("ns", "base: '#{base}', suffix: '#{suffix}'")
      uri(base + suffix.to_s)
    end
    
    # add a statement
    #
    # @param [String] production:: Production generating triple
    # @param [RDF::Term] subject:: the subject of the statement
    # @param [RDF::Term] predicate:: the predicate of the statement
    # @param [RDF::Term, Node, Literal] object:: the object of the statement
    def add_triple(production, options)
      progress(production, "[:triple, #{options[:subject]}, #{options[:predicate]}, #{options[:object]}]")
      triples = {}
      options.each_pair do |r, v|
        if v.is_a?(Array) && v.flatten.length == 1
          v = v.flatten.first
        end
        unless v.is_a?(RDF::Term)
          error("add_triple", "Expected #{r} to be a resource, but it was #{v.inspect}",
            :production => production) 
        end
        triples[r] = v
      end
      add_prod_data(:triple, triples)
    end

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
