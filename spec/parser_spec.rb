require File.join(File.dirname(__FILE__), 'spec_helper')

module ProductionRequirements
  def with_production(production, &block)
    block.call(production)
  end

  def it_rejects_empty_input_using(production)
    it "rejects empty input" do
      parser(production).call(%q()).should be_false
    end
  end

  def it_generates_given(production, input, result)
    it "generates #{present_results(result)} given #{input.inspect}" do
      parser(production).call(input).should == result
    end
  end
  
  def present_results(array)
    "[" +
    array.map do |e|
      case e
      when Array      then present_results(e)
      when Symbol     then ":#{e}"
      when RDF::URI   then "<#{e}>"
      when RDF::Node  then "_:#{e}"
      else                 e.inspect
      end
    end.join(", ") +
    "]"
  end
  
  # [44] Var
  def it_recognizes_var_using(production)
    it "recognizes the Var nonterminal" do
      it_recognizes_var1(production)
      it_recognizes_var2(production)
    end
  end

  # [45] GraphTerm
  def it_recognizes_graph_term_using(production)
    it "recognizes the GraphTerm nonterminal" do
      pending
    end
  end

  # [60] RDFLiteral
  def it_recognizes_rdf_literal_using(production)
    it "recognizes the Var nonterminal" do
      it_recognizes_rdf_literal_without_language_or_datatype(production)
      it_recognizes_rdf_literal_with_language(production)
      it_recognizes_rdf_literal_with_datatype(production)
    end
  end

  # [61] NumericLiteral
  def it_recognizes_numeric_literal_using(production)
    it "recognizes the NumericLiteral nonterminal" do
      # FIXME
      parser(production).call(%q(123)).should     == RDF::Literal::Integer.new(123)
      parser(production).call(%q(+3.1415)).should == RDF::Literal::Decimal.new(3.1415)
      parser(production).call(%q(-1e6)).should    == RDF::Literal::Double.new(-1e6)
    end
  end

  # [65] BooleanLiteral
  def it_recognizes_boolean_literal_using(production)
    it "recognizes the BooleanLiteral nonterminal" do
      # FIXME
      parser(production).call(%q(true)).should == RDF::Literal(true)
      parser(production).call(%q(false)).should == RDF::Literal(false)
    end
  end

  # [67] IRIref
  def it_recognizes_iriref_using(production)
    it "recognizes the IRIref nonterminal" do
      parser(production).call(%q(<http://example.org/>)).should == RDF::URI('http://example.org/')
      pending("test prefixed names")
    end
  end

  # [69] BlankNode
  def it_recognizes_blank_node_using(production)
    it "recognizes the BlankNode nonterminal" do
      # FIXME
      parser(production).call(%q(_:foobar)).should == RDF::Node(:foobar)
      parser(production).call(%q([])).should be_an(RDF::Node)
    end
  end

  # [92] NIL
  def it_recognizes_nil_using(production)
    it "recognizes the NIL terminal" do
      it_recognizes_nil(production)
    end
  end
end

module ProductionExamples
  # [60] RDFLiteral
  def it_recognizes_rdf_literal_without_language_or_datatype(production)
    parser(production).call(%q("")).should == RDF::Literal.new("")
    parser(production).call(%q("foobar")).should == RDF::Literal.new("foobar")
  end

  # [60] RDFLiteral
  def it_recognizes_rdf_literal_with_language(production)
    parser(production).call(%q(""@en)).should == RDF::Literal.new("", :language => :en)
    parser(production).call(%q("foobar"@en-US)).should == RDF::Literal.new("foobar", :language => :'en-US')
  end

  # [60] RDFLiteral
  def it_recognizes_rdf_literal_with_datatype(production)
    parser(production).call(%q(""^^<http://www.w3.org/2001/XMLSchema#string>)).should == RDF::Literal.new("", :datatype => RDF::XSD.string)
    parser(production).call(%q("foobar"^^<http://www.w3.org/2001/XMLSchema#string>)).should == RDF::Literal.new("foobar", :datatype => RDF::XSD.string)
  end

  # [74] VAR1
  def it_recognizes_var1(production)
    %w(foo bar).each do |input|
      parser(production).call("?#{input}").should == RDF::Query::Variable.new(input.to_sym)
    end
  end

  # [75] VAR2
  def it_recognizes_var2(production)
    %w(foo bar).each do |input|
      parser(production).call("$#{input}").should == RDF::Query::Variable.new(input.to_sym)
    end
  end

  # [92] NIL
  def it_recognizes_nil(production)
    parser(production).call(%q(())).should == RDF.nil
  end
end

describe SPARQL::Grammar::Parser do
  extend  ProductionRequirements
  extend  ProductionExamples
  include ProductionRequirements
  include ProductionExamples

  describe "when matching the [1] Query production rule" do
    with_production(:Query) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [2] Prologue production rule" do
    with_production(:Prologue) do |production|
      it_rejects_empty_input_using production

      {
        %q(BASE <http://example.org/>)                    => [:prologue, [:base, RDF::URI('http://example.org/')]],
        %q(PREFIX : <foobar>)                             => [:prologue, [:prefix, nil, RDF::URI('foobar')]],
        %q(PREFIX foo: <bar>)                             => [:prologue, [:prefix, :foo, RDF::URI('bar')]],
        %Q(PREFIX : <foobar>\nPREFIX foo: <bar>)          => [:prologue, [:prefix, nil, RDF::URI('foobar')], [:prefix, :foo, RDF::URI('bar')]],
        %Q(BASE <http://example.org/>\nPREFIX foo: <bar>) => [:prologue, [:base, RDF::URI('http://example.org/')], [:prefix, :foo, RDF::URI('bar')]]
      }.each_pair do |input, result|
        it_generates_given(production, input, result)
      end
    end
  end

  describe "when matching the [3] BaseDecl production rule" do
    with_production(:BaseDecl) do |production|
      it_rejects_empty_input_using production

      {
        %q(BASE <http://example.org/>)                    => [:base, RDF::URI('http://example.org/')],
      }.each_pair do |input, result|
        it_generates_given(production, input, result)
      end
    end
  end

  describe "when matching the [4] PrefixDecl production rule" do
    with_production(:PrefixDecl) do |production|
      it_rejects_empty_input_using production

      {
        %q(PREFIX : <foobar>)                             => [:prefix, nil, RDF::URI('foobar')],
        %q(PREFIX foo: <bar>)                             => [:prefix, :foo, RDF::URI('bar')],
      }.each_pair do |input, result|
        it_generates_given(production, input, result)
      end
    end
  end

  describe "when matching the [5] SelectQuery production rule" do
    with_production(:SelectQuery) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [6] ConstructQuery production rule" do
    with_production(:ConstructQuery) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [7] DescribeQuery production rule" do
    with_production(:DescribeQuery) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [8] AskQuery production rule" do
    with_production(:AskQuery) do |production|
      it_rejects_empty_input_using production

      it "recognizes a DatasetClause nonterminal" do
        parser(production).call(%q(ASK FROM <http://example.org/>)) #.should == [:prologue, [:base, RDF::URI('http://example.org/')]] # FIXME
      end

      it "recognizes a WhereClause nonterminal" do
        # TODO
      end
    end
  end

  describe "when matching the [9] DatasetClause production rule" do
    with_production(:DatasetClause) do |production|
      it_rejects_empty_input_using production

      it "recognizes the 'FROM' lexeme" do
        # TODO
      end

      it "recognizes the DefaultGraphClause nonterminal" do
        parser(production).call(%q(FROM <http://example.org/foaf/aliceFoaf>)) # TODO
      end

      it "recognizes the NamedGraphClause nonterminal" do
        parser(production).call(%q(FROM NAMED <http://example.org/alice>)) # TODO
      end
    end
  end

  describe "when matching the [10] DefaultGraphClause production rule" do
    with_production(:DefaultGraphClause) do |production|
      it_rejects_empty_input_using production

      it "recognizes default graph clauses" do
        parser(production).call(%q(<http://example.org/foaf/aliceFoaf>)).should == [:default, RDF::URI('http://example.org/foaf/aliceFoaf')]
      end
    end
  end

  describe "when matching the [11] NamedGraphClause production rule" do
    with_production(:NamedGraphClause) do |production|
      it_rejects_empty_input_using production

      it "recognizes the 'NAMED' lexeme" do
        # TODO
      end

      it "recognizes named graph clauses" do
        parser(production).call(%q(NAMED <http://example.org/alice>)).should == [:named, RDF::URI('http://example.org/alice')]
      end
    end
  end

  describe "when matching the [12] SourceSelector production rule" do
    with_production(:SourceSelector) do |production|
      it_rejects_empty_input_using production
      it_recognizes_iriref_using production
    end
  end

  describe "when matching the [13] WhereClause production rule" do
    with_production(:WhereClause) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [14] SolutionModifier production rule" do
    with_production(:SolutionModifier) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [15] LimitOffsetClauses production rule" do
    with_production(:LimitOffsetClauses) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [16] OrderClause production rule" do
    with_production(:OrderClause) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [17] OrderCondition production rule" do
    with_production(:OrderCondition) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [18] LimitClause production rule" do
    with_production(:LimitClause) do |production|
      it_rejects_empty_input_using production

      it "recognizes LIMIT clauses" do
        parser(production).call(%q(LIMIT 10)).should == [:limit, 10]
      end
    end
  end

  describe "when matching the [19] OffsetClause production rule" do
    with_production(:OffsetClause) do |production|
      it_rejects_empty_input_using production

      it "recognizes OFFSET clauses" do
        parser(production).call(%q(OFFSET 10)).should == [:offset, 10]
      end
    end
  end

  describe "when matching the [20] GroupGraphPattern production rule" do
    with_production(:GroupGraphPattern) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [21] TriplesBlock production rule" do
    with_production(:TriplesBlock) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [22] GraphPatternNotTriples production rule" do
    with_production(:GraphPatternNotTriples) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [23] OptionalGraphPattern production rule" do
    with_production(:OptionalGraphPattern) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [24] GraphGraphPattern production rule" do
    with_production(:GraphGraphPattern) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [25] GroupOrUnionGraphPattern production rule" do
    with_production(:GroupOrUnionGraphPattern) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [26] Filter production rule" do
    with_production(:Filter) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [27] Constraint production rule" do
    with_production(:Constraint) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [28] FunctionCall production rule" do
    with_production(:FunctionCall) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [29] ArgList production rule" do
    with_production(:ArgList) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [30] ConstructTemplate production rule" do
    with_production(:ConstructTemplate) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [31] ConstructTriples production rule" do
    with_production(:ConstructTriples) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [32] TriplesSameSubject production rule" do
    with_production(:TriplesSameSubject) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [33] PropertyListNotEmpty production rule" do
    with_production(:PropertyListNotEmpty) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [34] PropertyList production rule" do
    with_production(:PropertyList) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [35] ObjectList production rule" do
    with_production(:ObjectList) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [36] Object production rule" do
    with_production(:Object) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [37] Verb production rule" do
    with_production(:Verb) do |production|
      it_rejects_empty_input_using production

      it "recognizes the VarOrIRIref nonterminal" do
        # TODO
      end

      it "recognizes the 'a' lexeme" do
        parser(production).call(%q(a)).should == RDF.type
      end
    end
  end

  describe "when matching the [38] TriplesNode production rule" do
    with_production(:TriplesNode) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [39] BlankNodePropertyList production rule" do
    with_production(:BlankNodePropertyList) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [40] Collection production rule" do
    with_production(:Collection) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [41] GraphNode production rule" do
    with_production(:GraphNode) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [42] VarOrTerm production rule" do
    with_production(:VarOrTerm) do |production|
      it_rejects_empty_input_using production
      it_recognizes_var_using production
      it_recognizes_graph_term_using production
    end
  end

  describe "when matching the [43] VarOrIRIref production rule" do
    with_production(:VarOrIRIref) do |production|
      it_rejects_empty_input_using production
      it_recognizes_var_using production
      it_recognizes_iriref_using production
    end
  end

  describe "when matching the [44] Var production rule" do
    with_production(:Var) do |production|
      it_rejects_empty_input_using production

      it "recognizes the VAR1 terminal" do
        it_recognizes_var1(production)
      end

      it "recognizes the VAR2 terminal" do
        it_recognizes_var2(production)
      end
    end
  end

  describe "when matching the [45] GraphTerm production rule" do
    with_production(:GraphTerm) do |production|
      it_rejects_empty_input_using production
      it_recognizes_iriref_using production
      it_recognizes_rdf_literal_using production
      it_recognizes_numeric_literal_using production
      it_recognizes_boolean_literal_using production
      it_recognizes_blank_node_using production
      it_recognizes_nil_using production
    end
  end

  describe "when matching the [46] Expression production rule" do
    with_production(:Expression) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [47] ConditionalOrExpression production rule" do
    with_production(:ConditionalOrExpression) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [48] ConditionalAndExpression production rule" do
    with_production(:ConditionalAndExpression) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [49] ValueLogical production rule" do
    with_production(:ValueLogical) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [50] RelationalExpression production rule" do
    with_production(:RelationalExpression) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [51] NumericExpression production rule" do
    with_production(:NumericExpression) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [52] AdditiveExpression production rule" do
    with_production(:AdditiveExpression) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [53] MultiplicativeExpression production rule" do
    with_production(:MultiplicativeExpression) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [54] UnaryExpression production rule" do
    with_production(:UnaryExpression) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [55] PrimaryExpression production rule" do
    with_production(:PrimaryExpression) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [56] BrackettedExpression production rule" do
    with_production(:BrackettedExpression) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [57] BuiltInCall production rule" do
    with_production(:BuiltInCall) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [58] RegexExpression production rule" do
    with_production(:RegexExpression) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [59] IRIrefOrFunction production rule" do
    with_production(:IRIrefOrFunction) do |production|
      it_rejects_empty_input_using production
      # TODO
    end
  end

  describe "when matching the [60] RDFLiteral production rule" do
    with_production(:RDFLiteral) do |production|
      it_rejects_empty_input_using production

      it "recognizes plain literals" do
        it_recognizes_rdf_literal_without_language_or_datatype production
      end

      it "recognizes language-tagged literals" do
        it_recognizes_rdf_literal_with_language production
      end

      it "recognizes datatyped literals" do
        it_recognizes_rdf_literal_with_datatype production
      end
    end
  end

  describe "when matching the [61] NumericLiteral production rule" do
    with_production(:NumericLiteral) do |production|
      it_rejects_empty_input_using production

      it "recognizes the NumericLiteralUnsigned nonterminal" do
        parser(production).call(%q(123)).should     == RDF::Literal::Integer.new(123)
        parser(production).call(%q(3.1415)).should  == RDF::Literal::Decimal.new(3.1415)
        parser(production).call(%q(1e6)).should     == RDF::Literal::Double.new(1e6)
      end

      it "recognizes the NumericLiteralPositive nonterminal" do
        parser(production).call(%q(+123)).should    == RDF::Literal::Integer.new(123)
        parser(production).call(%q(+3.1415)).should == RDF::Literal::Decimal.new(3.1415)
        parser(production).call(%q(+1e6)).should    == RDF::Literal::Double.new(1e6)
      end

      it "recognizes the NumericLiteralNegative nonterminal" do
        parser(production).call(%q(-123)).should    == RDF::Literal::Integer.new(-123)
        parser(production).call(%q(-3.1415)).should == RDF::Literal::Decimal.new(-3.1415)
        parser(production).call(%q(-1e6)).should    == RDF::Literal::Double.new(-1e6)
      end
    end
  end

  describe "when matching the [62] NumericLiteralUnsigned production rule" do
    with_production(:NumericLiteralUnsigned) do |production|
      it_rejects_empty_input_using production

      it "recognizes the INTEGER terminal" do
        %w(1 2 3 42 123).each do |input|
          parser(production).call(input).should == RDF::Literal::Integer.new(input.to_i)
        end
      end

      it "recognizes the DECIMAL terminal" do
        %w(1. 3.1415 .123).each do |input|
          parser(production).call(input).should == RDF::Literal::Decimal.new(input.to_f)
        end
      end

      it "recognizes the DOUBLE terminal" do
        %w(1e2 3.1415e2 .123e2).each do |input|
          parser(production).call(input).should == RDF::Literal::Double.new(input.to_f)
        end
      end
    end
  end

  describe "when matching the [63] NumericLiteralPositive production rule" do
    with_production(:NumericLiteralPositive) do |production|
      it_rejects_empty_input_using production

      it "recognizes the INTEGER_POSITIVE terminal" do
        %w(+1 +2 +3 +42 +123).each do |input|
          parser(production).call(input).should == RDF::Literal::Integer.new(input.to_i)
        end
      end

      it "recognizes the DECIMAL_POSITIVE terminal" do
        %w(+1. +3.1415 +.123).each do |input|
          parser(production).call(input).should == RDF::Literal::Decimal.new(input.to_f)
        end
      end

      it "recognizes the DOUBLE_POSITIVE terminal" do
        %w(+1e2 +3.1415e2 +.123e2).each do |input|
          parser(production).call(input).should == RDF::Literal::Double.new(input.to_f)
        end
      end
    end
  end

  describe "when matching the [64] NumericLiteralNegative production rule" do
    with_production(:NumericLiteralNegative) do |production|
      it_rejects_empty_input_using production

      it "recognizes the INTEGER_NEGATIVE terminal" do
        %w(-1 -2 -3 -42 -123).each do |input|
          parser(production).call(input).should == RDF::Literal::Integer.new(input.to_i)
        end
      end

      it "recognizes the DECIMAL_NEGATIVE terminal" do
        %w(-1. -3.1415 -.123).each do |input|
          parser(production).call(input).should == RDF::Literal::Decimal.new(input.to_f)
        end
      end

      it "recognizes the DOUBLE_NEGATIVE terminal" do
        %w(-1e2 -3.1415e2 -.123e2).each do |input|
          parser(production).call(input).should == RDF::Literal::Double.new(input.to_f)
        end
      end
    end
  end

  describe "when matching the [65] BooleanLiteral production rule" do
    with_production(:BooleanLiteral) do |production|
      it_rejects_empty_input_using production

      it "recognizes the 'true' lexeme" do
        %w(true).each do |input|
          parser(production).call(input).should == RDF::Literal(true)
        end
      end

      it "recognizes the 'false' lexeme" do
        %w(false).each do |input|
          parser(production).call(input).should == RDF::Literal(false)
        end
      end
    end
  end

  describe "when matching the [66] String production rule" do
    with_production(:String) do |production|
      it_rejects_empty_input_using production

      inputs = {
        :STRING_LITERAL1      => %q('foobar'),
        :STRING_LITERAL2      => %q("foobar"),
        :STRING_LITERAL_LONG1 => %q('''foobar'''),
        :STRING_LITERAL_LONG2 => %q("""foobar"""),
      }
      inputs.each do |terminal, input|
        it "recognizes the #{terminal} terminal" do
          parser(production).call(input).should eql(RDF::Literal('foobar'))
        end
      end
    end
  end

  describe "when matching the [67] IRIref production rule" do
    with_production(:IRIref) do |production|
      it_rejects_empty_input_using production

      it "recognizes the IRI_REF terminal" do
        %w(<> <foobar> <http://example.org/foobar>).each do |input|
          parser(production).call(input).should_not == false # TODO
        end
      end

      it "recognizes the PrefixedName nonterminal" do
        %w(: foo: :bar foo:bar).each do |input|
          parser(production).call(input).should_not == false # TODO
        end
      end
    end
  end

  describe "when matching the [68] PrefixedName production rule" do
    with_production(:PrefixedName) do |production|
      it_rejects_empty_input_using production

      inputs = {
        :PNAME_LN => %w(:bar foo:bar),
        :PNAME_NS => %w(: foo:),
      }
      inputs.each do |terminal, examples|
        it "recognizes the #{terminal} terminal" do
          examples.each do |input|
            parser(production).call(input).should_not == false # TODO
          end
        end
      end
    end
  end

  describe "when matching the [69] BlankNode production rule" do
    with_production(:BlankNode) do |production|
      it_rejects_empty_input_using production

      inputs = {
        :BLANK_NODE_LABEL => %q(_:foobar),
        :ANON             => %q([]),
      }
      inputs.each do |terminal, input|
        it "recognizes the #{terminal} terminal" do
          if output = parser(production).call(input)
            output.should be_an(RDF::Node)
          end
        end
      end
    end
  end

  describe "when matching the [70] IRI_REF production rule" do
    with_production(:IRI_REF) do |production|
      it_rejects_empty_input_using production

      it "recognizes the empty IRI reference" do
        parser(production).call(%q(<>)).should eql(RDF::URI(''))
      end

      it "recognizes relative IRI references" do
        parser(production).call(%q(<foobar>)).should eql(RDF::URI('foobar'))
      end

      it "recognizes absolute IRI references" do
        parser(production).call(%q(<http://example.org/foobar>)).should eql(RDF::URI('http://example.org/foobar'))
      end
    end
  end

  describe "when matching the [71] PNAME_NS production rule" do
    with_production(:PNAME_NS) do |production|
      it_rejects_empty_input_using production

      it "recognizes the ':' lexeme" do
        parser(production).call(%q(:)).should == nil
      end

      it "recognizes the 'foo:' lexeme" do
        parser(production).call(%q(foo:)).should == :foo
      end
    end
  end

  describe "when matching the [72] PNAME_LN production rule" do
    with_production(:PNAME_LN) do |production|
      it_rejects_empty_input_using production

      it "recognizes the ':bar' lexeme" do
        parser(production).call(%q(:bar)).should == [nil, :bar]
      end

      it "recognizes the 'foo:bar' lexeme" do
        parser(production).call(%q(foo:bar)).should == [:foo, :bar]
      end
    end
  end

  # NOTE: production rules [73..75] are internal to the lexer

  describe "when matching the [76] LANGTAG production rule" do
    with_production(:LANGTAG) do |production|
      it_rejects_empty_input_using production

      it "recognizes the '@en' lexeme" do
        parser(production).call(%q(@en)).should == :en
      end

      it "recognizes the '@en-US' lexeme" do
        parser(production).call(%q(@en-US)).should == :'en-US'
      end
    end
  end

  # NOTE: production rules [77..91] are internal to the lexer

  describe "when matching the [92] NIL production rule" do
    with_production(:NIL) do |production|
      it_rejects_empty_input_using production

      it "recognizes the '()' lexeme" do
        it_recognizes_nil production
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

  def parser(production = nil, options = {})
    Proc.new do |query|
      parser = SPARQL::Grammar::Parser.new(query, options)
      production ? parser.parse(SPARQL::Grammar::SPARQL_GRAMMAR[production]) : parser
    end
  end
end
