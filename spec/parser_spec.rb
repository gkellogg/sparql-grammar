require File.join(File.dirname(__FILE__), 'spec_helper')

module ProductionRequirements
  def with_method(method, &block)
    block.call(method)
  end

  def it_rejects_empty_input_using(method)
    it "rejects empty input" do
      parser(method).call(%q()).should be_false
    end
  end

  # [44] Var
  def it_recognizes_var_using(method)
    it "recognizes the Var nonterminal" do
      it_recognizes_var1(method)
      it_recognizes_var2(method)
    end
  end

  # [45] GraphTerm
  def it_recognizes_graph_term_using(method)
    it "recognizes the GraphTerm nonterminal" do
      # TODO
    end
  end

  # [60] RDFLiteral
  def it_recognizes_rdf_literal_using(method)
    it "recognizes the Var nonterminal" do
      it_recognizes_rdf_literal_without_language_or_datatype(method)
      it_recognizes_rdf_literal_with_language(method)
      it_recognizes_rdf_literal_with_datatype(method)
    end
  end

  # [61] NumericLiteral
  def it_recognizes_numeric_literal_using(method)
    it "recognizes the NumericLiteral nonterminal" do
      # FIXME
      parser(method).call(%q(123)).should     == RDF::Literal::Integer.new(123)
      parser(method).call(%q(+3.1415)).should == RDF::Literal::Decimal.new(3.1415)
      parser(method).call(%q(-1e6)).should    == RDF::Literal::Double.new(-1e6)
    end
  end

  # [65] BooleanLiteral
  def it_recognizes_boolean_literal_using(method)
    it "recognizes the BooleanLiteral nonterminal" do
      # FIXME
      parser(method).call(%q(true)).should == RDF::Literal(true)
      parser(method).call(%q(false)).should == RDF::Literal(false)
    end
  end

  # [67] IRIref
  def it_recognizes_iriref_using(method)
    it "recognizes the IRIref nonterminal" do
      parser(method).call(%q(<http://example.org/>)).should == RDF::URI('http://example.org/')
      # TODO: test prefixed names
    end
  end

  # [69] BlankNode
  def it_recognizes_blank_node_using(method)
    it "recognizes the BlankNode nonterminal" do
      # FIXME
      parser(method).call(%q(_:foobar)).should == RDF::Node(:foobar)
      parser(method).call(%q([])).should be_an(RDF::Node)
    end
  end

  # [92] NIL
  def it_recognizes_nil_using(method)
    it "recognizes the NIL terminal" do
      it_recognizes_nil(method)
    end
  end
end

module ProductionExamples
  # [60] RDFLiteral
  def it_recognizes_rdf_literal_without_language_or_datatype(method)
    parser(method).call(%q("")).should == RDF::Literal.new("")
    parser(method).call(%q("foobar")).should == RDF::Literal.new("foobar")
  end

  # [60] RDFLiteral
  def it_recognizes_rdf_literal_with_language(method)
    parser(method).call(%q(""@en)).should == RDF::Literal.new("", :language => :en)
    parser(method).call(%q("foobar"@en-US)).should == RDF::Literal.new("foobar", :language => :'en-US')
  end

  # [60] RDFLiteral
  def it_recognizes_rdf_literal_with_datatype(method)
    parser(method).call(%q(""^^<http://www.w3.org/2001/XMLSchema#string>)).should == RDF::Literal.new("", :datatype => RDF::XSD.string)
    parser(method).call(%q("foobar"^^<http://www.w3.org/2001/XMLSchema#string>)).should == RDF::Literal.new("foobar", :datatype => RDF::XSD.string)
  end

  # [74] VAR1
  def it_recognizes_var1(method)
    %w(foo bar).each do |input|
      parser(method).call("?#{input}").should == RDF::Query::Variable.new(input.to_sym)
    end
  end

  # [75] VAR2
  def it_recognizes_var2(method)
    %w(foo bar).each do |input|
      parser(method).call("$#{input}").should == RDF::Query::Variable.new(input.to_sym)
    end
  end

  # [92] NIL
  def it_recognizes_nil(method)
    parser(method).call(%q(())).should == RDF.nil
  end
end

describe SPARQL::Grammar::Parser do
  extend  ProductionRequirements
  extend  ProductionExamples
  include ProductionRequirements
  include ProductionExamples

  describe "when matching the [1] Query production rule" do
    with_method(:parse_query) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [2] Prologue production rule" do
    with_method(:parse_prologue) do |method|
      it_rejects_empty_input_using method

      it "recognizes a BaseDecl nonterminal" do
        parser(method).call(%q(BASE <http://example.org/>)).should == [:prologue, [:base, RDF::URI('http://example.org/')]]
      end

      it "recognizes a PrefixDecl nonterminal" do
        parser(method).call(%q(PREFIX : <foobar>)).should == [:prologue, [:prefix, nil, RDF::URI('foobar')]]
        parser(method).call(%q(PREFIX foo: <bar>)).should == [:prologue, [:prefix, :foo, RDF::URI('bar')]]
      end

      it "recognizes a sequence of PrefixDecl nonterminals" do
        input = %Q(PREFIX : <foobar>\nPREFIX foo: <bar>)
        parser(method).call(input).should == [:prologue, [:prefix, nil, RDF::URI('foobar')], [:prefix, :foo, RDF::URI('bar')]]
      end

      it "recognizes a BaseDecl nonterminal followed by a PrefixDecl nonterminal" do
        input = %Q(BASE <http://example.org/>\nPREFIX foo: <bar>)
        parser(method).call(input).should == [:prologue, [:base, RDF::URI('http://example.org/')], [:prefix, :foo, RDF::URI('bar')]]
      end
    end
  end

  describe "when matching the [3] BaseDecl production rule" do
    with_method(:parse_base_decl) do |method|
      it_rejects_empty_input_using method

      it "recognizes BASE declarations" do
        parser(method).call(%q(BASE <http://example.org/>)).should == [:base, RDF::URI('http://example.org/')]
      end
    end
  end

  describe "when matching the [4] PrefixDecl production rule" do
    with_method(:parse_prefix_decl) do |method|
      it_rejects_empty_input_using method

      it "recognizes PREFIX declarations" do
        parser(method).call(%q(PREFIX : <http://example.org/>)).should    == [:prefix, nil, RDF::URI('http://example.org/')]
        parser(method).call(%q(PREFIX foo: <http://example.org/>)).should == [:prefix, :foo, RDF::URI('http://example.org/')]
      end
    end
  end

  describe "when matching the [5] SelectQuery production rule" do
    with_method(:parse_select_query) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [6] ConstructQuery production rule" do
    with_method(:parse_construct_query) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [7] DescribeQuery production rule" do
    with_method(:parse_describe_query) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [8] AskQuery production rule" do
    with_method(:parse_ask_query) do |method|
      it_rejects_empty_input_using method

      it "recognizes a DatasetClause nonterminal" do
        parser(method).call(%q(ASK FROM <http://example.org/>)) #.should == [:prologue, [:base, RDF::URI('http://example.org/')]] # FIXME
      end

      it "recognizes a WhereClause nonterminal" do
        # TODO
      end
    end
  end

  describe "when matching the [9] DatasetClause production rule" do
    with_method(:parse_dataset_clause) do |method|
      it_rejects_empty_input_using method

      it "recognizes the 'FROM' lexeme" do
        # TODO
      end

      it "recognizes the DefaultGraphClause nonterminal" do
        parser(method).call(%q(FROM <http://example.org/foaf/aliceFoaf>)) # TODO
      end

      it "recognizes the NamedGraphClause nonterminal" do
        parser(method).call(%q(FROM NAMED <http://example.org/alice>)) # TODO
      end
    end
  end

  describe "when matching the [10] DefaultGraphClause production rule" do
    with_method(:parse_default_graph_clause) do |method|
      it_rejects_empty_input_using method

      it "recognizes default graph clauses" do
        parser(method).call(%q(<http://example.org/foaf/aliceFoaf>)).should == [:default, RDF::URI('http://example.org/foaf/aliceFoaf')]
      end
    end
  end

  describe "when matching the [11] NamedGraphClause production rule" do
    with_method(:parse_named_graph_clause) do |method|
      it_rejects_empty_input_using method

      it "recognizes the 'NAMED' lexeme" do
        # TODO
      end

      it "recognizes named graph clauses" do
        parser(method).call(%q(NAMED <http://example.org/alice>)).should == [:named, RDF::URI('http://example.org/alice')]
      end
    end
  end

  describe "when matching the [12] SourceSelector production rule" do
    with_method(:parse_source_selector) do |method|
      it_rejects_empty_input_using method
      it_recognizes_iriref_using method
    end
  end

  describe "when matching the [13] WhereClause production rule" do
    with_method(:parse_where_clause) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [14] SolutionModifier production rule" do
    with_method(:parse_solution_modifier) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [15] LimitOffsetClauses production rule" do
    with_method(:parse_limit_offset_clauses) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [16] OrderClause production rule" do
    with_method(:parse_order_clause) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [17] OrderCondition production rule" do
    with_method(:parse_order_condition) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [18] LimitClause production rule" do
    with_method(:parse_limit_clause) do |method|
      it_rejects_empty_input_using method

      it "recognizes LIMIT clauses" do
        parser(method).call(%q(LIMIT 10)).should == [:limit, 10]
      end
    end
  end

  describe "when matching the [19] OffsetClause production rule" do
    with_method(:parse_offset_clause) do |method|
      it_rejects_empty_input_using method

      it "recognizes OFFSET clauses" do
        parser(method).call(%q(OFFSET 10)).should == [:offset, 10]
      end
    end
  end

  describe "when matching the [20] GroupGraphPattern production rule" do
    with_method(:parse_group_graph_pattern) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [21] TriplesBlock production rule" do
    with_method(:parse_triples_block) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [22] GraphPatternNotTriples production rule" do
    with_method(:parse_graph_pattern_not_triples) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [23] OptionalGraphPattern production rule" do
    with_method(:parse_optional_graph_pattern) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [24] GraphGraphPattern production rule" do
    with_method(:parse_graph_graph_pattern) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [25] GroupOrUnionGraphPattern production rule" do
    with_method(:parse_group_or_union_graph_pattern) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [26] Filter production rule" do
    with_method(:parse_filter) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [27] Constraint production rule" do
    with_method(:parse_constraint) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [28] FunctionCall production rule" do
    with_method(:parse_function_call) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [29] ArgList production rule" do
    with_method(:parse_arg_list) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [30] ConstructTemplate production rule" do
    with_method(:parse_construct_template) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [31] ConstructTriples production rule" do
    with_method(:parse_construct_triples) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [32] TriplesSameSubject production rule" do
    with_method(:parse_triples_same_subject) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [33] PropertyListNotEmpty production rule" do
    with_method(:parse_property_list_not_empty) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [34] PropertyList production rule" do
    with_method(:parse_property_list) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [35] ObjectList production rule" do
    with_method(:parse_object_list) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [36] Object production rule" do
    with_method(:parse_object) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [37] Verb production rule" do
    with_method(:parse_verb) do |method|
      it_rejects_empty_input_using method

      it "recognizes the VarOrIRIref nonterminal" do
        # TODO
      end

      it "recognizes the 'a' lexeme" do
        parser(method).call(%q(a)).should == RDF.type
      end
    end
  end

  describe "when matching the [38] TriplesNode production rule" do
    with_method(:parse_triples_node) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [39] BlankNodePropertyList production rule" do
    with_method(:parse_blank_node_property_list) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [40] Collection production rule" do
    with_method(:parse_collection) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [41] GraphNode production rule" do
    with_method(:parse_graph_node) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [42] VarOrTerm production rule" do
    with_method(:parse_var_or_term) do |method|
      it_rejects_empty_input_using method
      it_recognizes_var_using method
      it_recognizes_graph_term_using method
    end
  end

  describe "when matching the [43] VarOrIRIref production rule" do
    with_method(:parse_var_or_iriref) do |method|
      it_rejects_empty_input_using method
      it_recognizes_var_using method
      it_recognizes_iriref_using method
    end
  end

  describe "when matching the [44] Var production rule" do
    with_method(:parse_var) do |method|
      it_rejects_empty_input_using method

      it "recognizes the VAR1 terminal" do
        it_recognizes_var1(method)
      end

      it "recognizes the VAR2 terminal" do
        it_recognizes_var2(method)
      end
    end
  end

  describe "when matching the [45] GraphTerm production rule" do
    with_method(:parse_graph_term) do |method|
      it_rejects_empty_input_using method
      it_recognizes_iriref_using method
      it_recognizes_rdf_literal_using method
      it_recognizes_numeric_literal_using method
      it_recognizes_boolean_literal_using method
      it_recognizes_blank_node_using method
      it_recognizes_nil_using method
    end
  end

  describe "when matching the [46] Expression production rule" do
    with_method(:parse_expression) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [47] ConditionalOrExpression production rule" do
    with_method(:parse_conditional_or_expression) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [48] ConditionalAndExpression production rule" do
    with_method(:parse_conditional_and_expression) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [49] ValueLogical production rule" do
    with_method(:parse_value_logical) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [50] RelationalExpression production rule" do
    with_method(:parse_relational_expression) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [51] NumericExpression production rule" do
    with_method(:parse_numeric_expression) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [52] AdditiveExpression production rule" do
    with_method(:parse_additive_expression) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [53] MultiplicativeExpression production rule" do
    with_method(:parse_multiplicative_expression) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [54] UnaryExpression production rule" do
    with_method(:parse_unary_expression) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [55] PrimaryExpression production rule" do
    with_method(:parse_primary_expression) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [56] BrackettedExpression production rule" do
    with_method(:parse_bracketted_expression) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [57] BuiltInCall production rule" do
    with_method(:parse_built_in_call) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [58] RegexExpression production rule" do
    with_method(:parse_regex_expression) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [59] IRIrefOrFunction production rule" do
    with_method(:parse_iriref_or_function) do |method|
      it_rejects_empty_input_using method
      # TODO
    end
  end

  describe "when matching the [60] RDFLiteral production rule" do
    with_method(:parse_rdf_literal) do |method|
      it_rejects_empty_input_using method

      it "recognizes plain literals" do
        it_recognizes_rdf_literal_without_language_or_datatype method
      end

      it "recognizes language-tagged literals" do
        it_recognizes_rdf_literal_with_language method
      end

      it "recognizes datatyped literals" do
        it_recognizes_rdf_literal_with_datatype method
      end
    end
  end

  describe "when matching the [61] NumericLiteral production rule" do
    with_method(:parse_numeric_literal) do |method|
      it_rejects_empty_input_using method

      it "recognizes the NumericLiteralUnsigned nonterminal" do
        parser(method).call(%q(123)).should     == RDF::Literal::Integer.new(123)
        parser(method).call(%q(3.1415)).should  == RDF::Literal::Decimal.new(3.1415)
        parser(method).call(%q(1e6)).should     == RDF::Literal::Double.new(1e6)
      end

      it "recognizes the NumericLiteralPositive nonterminal" do
        parser(method).call(%q(+123)).should    == RDF::Literal::Integer.new(123)
        parser(method).call(%q(+3.1415)).should == RDF::Literal::Decimal.new(3.1415)
        parser(method).call(%q(+1e6)).should    == RDF::Literal::Double.new(1e6)
      end

      it "recognizes the NumericLiteralNegative nonterminal" do
        parser(method).call(%q(-123)).should    == RDF::Literal::Integer.new(-123)
        parser(method).call(%q(-3.1415)).should == RDF::Literal::Decimal.new(-3.1415)
        parser(method).call(%q(-1e6)).should    == RDF::Literal::Double.new(-1e6)
      end
    end
  end

  describe "when matching the [62] NumericLiteralUnsigned production rule" do
    with_method(:parse_numeric_literal_unsigned) do |method|
      it_rejects_empty_input_using method

      it "recognizes the INTEGER terminal" do
        %w(1 2 3 42 123).each do |input|
          parser(method).call(input).should == RDF::Literal::Integer.new(input.to_i)
        end
      end

      it "recognizes the DECIMAL terminal" do
        %w(1. 3.1415 .123).each do |input|
          parser(method).call(input).should == RDF::Literal::Decimal.new(input.to_f)
        end
      end

      it "recognizes the DOUBLE terminal" do
        %w(1e2 3.1415e2 .123e2).each do |input|
          parser(method).call(input).should == RDF::Literal::Double.new(input.to_f)
        end
      end
    end
  end

  describe "when matching the [63] NumericLiteralPositive production rule" do
    with_method(:parse_numeric_literal_positive) do |method|
      it_rejects_empty_input_using method

      it "recognizes the INTEGER_POSITIVE terminal" do
        %w(+1 +2 +3 +42 +123).each do |input|
          parser(method).call(input).should == RDF::Literal::Integer.new(input.to_i)
        end
      end

      it "recognizes the DECIMAL_POSITIVE terminal" do
        %w(+1. +3.1415 +.123).each do |input|
          parser(method).call(input).should == RDF::Literal::Decimal.new(input.to_f)
        end
      end

      it "recognizes the DOUBLE_POSITIVE terminal" do
        %w(+1e2 +3.1415e2 +.123e2).each do |input|
          parser(method).call(input).should == RDF::Literal::Double.new(input.to_f)
        end
      end
    end
  end

  describe "when matching the [64] NumericLiteralNegative production rule" do
    with_method(:parse_numeric_literal_negative) do |method|
      it_rejects_empty_input_using method

      it "recognizes the INTEGER_NEGATIVE terminal" do
        %w(-1 -2 -3 -42 -123).each do |input|
          parser(method).call(input).should == RDF::Literal::Integer.new(input.to_i)
        end
      end

      it "recognizes the DECIMAL_NEGATIVE terminal" do
        %w(-1. -3.1415 -.123).each do |input|
          parser(method).call(input).should == RDF::Literal::Decimal.new(input.to_f)
        end
      end

      it "recognizes the DOUBLE_NEGATIVE terminal" do
        %w(-1e2 -3.1415e2 -.123e2).each do |input|
          parser(method).call(input).should == RDF::Literal::Double.new(input.to_f)
        end
      end
    end
  end

  describe "when matching the [65] BooleanLiteral production rule" do
    with_method(:parse_boolean_literal) do |method|
      it_rejects_empty_input_using method

      it "recognizes the 'true' lexeme" do
        %w(true).each do |input|
          parser(method).call(input).should == RDF::Literal(true)
        end
      end

      it "recognizes the 'false' lexeme" do
        %w(false).each do |input|
          parser(method).call(input).should == RDF::Literal(false)
        end
      end
    end
  end

  describe "when matching the [66] String production rule" do
    with_method(:parse_string) do |method|
      it_rejects_empty_input_using method

      inputs = {
        :STRING_LITERAL1      => %q('foobar'),
        :STRING_LITERAL2      => %q("foobar"),
        :STRING_LITERAL_LONG1 => %q('''foobar'''),
        :STRING_LITERAL_LONG2 => %q("""foobar"""),
      }
      inputs.each do |terminal, input|
        it "recognizes the #{terminal} terminal" do
          parser(method).call(input).should eql(RDF::Literal('foobar'))
        end
      end
    end
  end

  describe "when matching the [67] IRIref production rule" do
    with_method(:parse_iriref) do |method|
      it_rejects_empty_input_using method

      it "recognizes the IRI_REF terminal" do
        %w(<> <foobar> <http://example.org/foobar>).each do |input|
          parser(method).call(input).should_not == false # TODO
        end
      end

      it "recognizes the PrefixedName nonterminal" do
        %w(: foo: :bar foo:bar).each do |input|
          parser(method).call(input).should_not == false # TODO
        end
      end
    end
  end

  describe "when matching the [68] PrefixedName production rule" do
    with_method(:parse_prefixed_name) do |method|
      it_rejects_empty_input_using method

      inputs = {
        :PNAME_LN => %w(:bar foo:bar),
        :PNAME_NS => %w(: foo:),
      }
      inputs.each do |terminal, examples|
        it "recognizes the #{terminal} terminal" do
          examples.each do |input|
            parser(method).call(input).should_not == false # TODO
          end
        end
      end
    end
  end

  describe "when matching the [69] BlankNode production rule" do
    with_method(:parse_blank_node) do |method|
      it_rejects_empty_input_using method

      inputs = {
        :BLANK_NODE_LABEL => %q(_:foobar),
        :ANON             => %q([]),
      }
      inputs.each do |terminal, input|
        it "recognizes the #{terminal} terminal" do
          if output = parser(method).call(input)
            output.should be_an(RDF::Node)
          end
        end
      end
    end
  end

  describe "when matching the [70] IRI_REF production rule" do
    with_method(:parse_iri_ref) do |method|
      it_rejects_empty_input_using method

      it "recognizes the empty IRI reference" do
        parser(method).call(%q(<>)).should eql(RDF::URI(''))
      end

      it "recognizes relative IRI references" do
        parser(method).call(%q(<foobar>)).should eql(RDF::URI('foobar'))
      end

      it "recognizes absolute IRI references" do
        parser(method).call(%q(<http://example.org/foobar>)).should eql(RDF::URI('http://example.org/foobar'))
      end
    end
  end

  describe "when matching the [71] PNAME_NS production rule" do
    with_method(:parse_pname_ns) do |method|
      it_rejects_empty_input_using method

      it "recognizes the ':' lexeme" do
        parser(method).call(%q(:)).should == nil
      end

      it "recognizes the 'foo:' lexeme" do
        parser(method).call(%q(foo:)).should == :foo
      end
    end
  end

  describe "when matching the [72] PNAME_LN production rule" do
    with_method(:parse_pname_ln) do |method|
      it_rejects_empty_input_using method

      it "recognizes the ':bar' lexeme" do
        parser(method).call(%q(:bar)).should == [nil, :bar]
      end

      it "recognizes the 'foo:bar' lexeme" do
        parser(method).call(%q(foo:bar)).should == [:foo, :bar]
      end
    end
  end

  # NOTE: production rules [73..75] are internal to the lexer

  describe "when matching the [76] LANGTAG production rule" do
    with_method(:parse_langtag) do |method|
      it_rejects_empty_input_using method

      it "recognizes the '@en' lexeme" do
        parser(method).call(%q(@en)).should == :en
      end

      it "recognizes the '@en-US' lexeme" do
        parser(method).call(%q(@en-US)).should == :'en-US'
      end
    end
  end

  # NOTE: production rules [77..91] are internal to the lexer

  describe "when matching the [92] NIL production rule" do
    with_method(:parse_nil) do |method|
      it_rejects_empty_input_using method

      it "recognizes the '()' lexeme" do
        it_recognizes_nil method
      end
    end
  end

  # NOTE: production rules [93..100] are internal to the lexer

  describe "when parsing ASK queries" do
    # TODO
  end

  describe "when parsing SELECT queries" do
    # TODO
  end

  describe "when parsing CONSTRUCT queries" do
    # TODO
  end

  describe "when parsing DESCRIBE queries" do
    # TODO
  end

  def parser(method = nil, options = {})
    Proc.new do |query|
      parser = SPARQL::Grammar::Parser.new(query, options)
      method ? parser.send(method) : parser
    end
  end
end
