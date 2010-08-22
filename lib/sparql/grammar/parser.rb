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

    # `[1] Query`
    def query
      # TODO
    end

    # `[2] Prologue`
    def prologue
      # TODO
    end

    # `[3] BaseDecl`
    def base_decl
      # TODO
    end

    # `[4] PrefixDecl`
    def prefix_decl
      # TODO
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

    # `[9] DatasetClause`
    def dataset_clause
      # TODO
    end

    # `[10] DefaultGraphClause`
    def default_graph_clause
      # TODO
    end

    # `[11] NamedGraphClause`
    def named_graph_clause
      # TODO
    end

    # `[12] SourceSelector`
    def source_selector
      # TODO
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

    # `[18] LimitClause`
    def limit_clause
      # TODO
    end

    # `[19] OffsetClause`
    def offset_clause
      # TODO
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
      (token = accept(:Var)) ? RDF::Query::Variable.new(token.value) : false
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
      (token = accept(:NumericLiteral)) ? RDF::Literal(token.value) : false
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
      (token = accept(:BooleanLiteral)) ? RDF::Literal(token.value) : false
    end

    # `[66] String ::= STRING_LITERAL1 | STRING_LITERAL2 | STRING_LITERAL_LONG1 | STRING_LITERAL_LONG2`
    def string
      (token = accept(:String)) ? RDF::Literal(token.value) : false
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
      (token = accept(:BlankNode)) ? RDF::Node(token.value) : false
    end

    # `[70] IRI_REF ::= '<' ([^<>"{}|^\`\]-[#x00-#x20])* '>'`
    def iri_ref
      (token = accept(:IRI_REF)) ? RDF::URI(token.value) : false # TODO: handle relative URLs here?
    end

    # `[71] PNAME_NS ::= PN_PREFIX? ':'`
    def pname_ns
      (token = accept(:PNAME_NS)) ? token.value : false # FIXME
    end

    # `[72] PNAME_LN ::= PNAME_NS PN_LOCAL`
    def pname_ln
      (token = accept(:PNAME_LN)) ? token.value : false # FIXME
    end

    # `[76] LANGTAG ::= '@' [a-zA-Z]+ ('-' [a-zA-Z0-9]+)*`
    def langtag
      (token = accept(:LANGTAG)) ? token.value : false
    end

    # `[92] NIL ::= '(' WS* ')'`
    def nil()
      (token = accept(:NIL)) ? RDF.nil : false
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

    instance_methods.each { |method| public method } # DEBUG
  end # class Parser
end; end # module SPARQL::Grammar
