require File.join(File.dirname(__FILE__), 'spec_helper')

describe SPARQL::Grammar::Parser do
  describe "when matching the [1] Query production rule" do
    it "rejects empty input" do
      parse(%q()).query.should be_false
    end

    # TODO
  end

  describe "when matching the [2] Prologue production rule" do
    it "rejects empty input" do
      parse(%q()).prologue.should be_false
    end

    it "recognizes a BaseDecl nonterminal" do
      parse(%q(BASE <http://example.org/>)).prologue.should == [:prologue, [:base, RDF::URI('http://example.org/')]]
    end

    it "recognizes a PrefixDecl nonterminal" do
      parse(%q(PREFIX : <foobar>)).prologue.should == [:prologue, [:prefix, nil, RDF::URI('foobar')]]
      parse(%q(PREFIX foo: <bar>)).prologue.should == [:prologue, [:prefix, :foo, RDF::URI('bar')]]
    end

    it "recognizes a sequence of PrefixDecl nonterminals" do
      input = %Q(PREFIX : <foobar>\nPREFIX foo: <bar>)
      parse(input).prologue.should == [:prologue, [:prefix, nil, RDF::URI('foobar')], [:prefix, :foo, RDF::URI('bar')]]
    end

    it "recognizes a BaseDecl nonterminal followed by a PrefixDecl nonterminal" do
      input = %Q(BASE <http://example.org/>\nPREFIX foo: <bar>)
      parse(input).prologue.should == [:prologue, [:base, RDF::URI('http://example.org/')], [:prefix, :foo, RDF::URI('bar')]]
    end
  end

  describe "when matching the [3] BaseDecl production rule" do
    it "rejects empty input" do
      parse(%q()).base_decl.should be_false
    end

    it "recognizes BASE declarations" do
      parse(%q(BASE <http://example.org/>)).base_decl.should == [:base, RDF::URI('http://example.org/')]
    end
  end

  describe "when matching the [4] PrefixDecl production rule" do
    it "rejects empty input" do
      parse(%q()).prefix_decl.should be_false
    end

    it "recognizes PREFIX declarations" do
      parse(%q(PREFIX : <http://example.org/>)).prefix_decl.should    == [:prefix, nil, RDF::URI('http://example.org/')]
      parse(%q(PREFIX foo: <http://example.org/>)).prefix_decl.should == [:prefix, :foo, RDF::URI('http://example.org/')]
    end
  end

  describe "when matching the [5] SelectQuery production rule" do
    it "rejects empty input" do
      parse(%q()).select_query.should be_false
    end

    # TODO
  end

  describe "when matching the [6] ConstructQuery production rule" do
    it "rejects empty input" do
      parse(%q()).construct_query.should be_false
    end

    # TODO
  end

  describe "when matching the [7] DescribeQuery production rule" do
    it "rejects empty input" do
      parse(%q()).describe_query.should be_false
    end

    # TODO
  end

  describe "when matching the [8] AskQuery production rule" do
    it "rejects empty input" do
      parse(%q()).ask_query.should be_false
    end

    # TODO
  end

  describe "when matching the [9] DatasetClause production rule" do
    it "rejects empty input" do
      parse(%q()).dataset_clause.should be_false
    end

    it "recognizes the 'FROM' lexeme" do
      # TODO
    end

    it "recognizes the DefaultGraphClause nonterminal" do
      parse(%q(FROM <http://example.org/foaf/aliceFoaf>)).dataset_clause # TODO
    end

    it "recognizes the NamedGraphClause nonterminal" do
      parse(%q(FROM NAMED <http://example.org/alice>)).dataset_clause # TODO
    end
  end

  describe "when matching the [10] DefaultGraphClause production rule" do
    it "rejects empty input" do
      parse(%q()).default_graph_clause.should be_false
    end

    it "recognizes default graph clauses" do
      parse(%q(<http://example.org/foaf/aliceFoaf>)).default_graph_clause.should == [:default, RDF::URI('http://example.org/foaf/aliceFoaf')]
    end
  end

  describe "when matching the [11] NamedGraphClause production rule" do
    it "rejects empty input" do
      parse(%q()).named_graph_clause.should be_false
    end

    it "recognizes the 'NAMED' lexeme" do
      # TODO
    end

    it "recognizes named graph clauses" do
      parse(%q(NAMED <http://example.org/alice>)).named_graph_clause.should == [:named, RDF::URI('http://example.org/alice')]
    end
  end

  describe "when matching the [12] SourceSelector production rule" do
    it "rejects empty input" do
      parse(%q()).source_selector.should be_false
    end

    it "recognizes the IRIref nonterminal" do
      # TODO
    end
  end

  describe "when matching the [13] WhereClause production rule" do
    it "rejects empty input" do
      parse(%q()).where_clause.should be_false
    end

    # TODO
  end

  describe "when matching the [14] SolutionModifier production rule" do
    it "rejects empty input" do
      parse(%q()).solution_modifier.should be_false
    end

    # TODO
  end

  describe "when matching the [15] LimitOffsetClauses production rule" do
    it "rejects empty input" do
      parse(%q()).limit_offset_clauses.should be_false
    end

    # TODO
  end

  describe "when matching the [16] OrderClause production rule" do
    it "rejects empty input" do
      parse(%q()).order_clause.should be_false
    end

    # TODO
  end

  describe "when matching the [17] OrderCondition production rule" do
    it "rejects empty input" do
      parse(%q()).order_condition.should be_false
    end

    # TODO
  end

  describe "when matching the [18] LimitClause production rule" do
    it "rejects empty input" do
      parse(%q()).limit_clause.should be_false
    end

    it "recognizes LIMIT clauses" do
      parse(%q(LIMIT 10)).limit_clause.should == [:limit, 10]
    end
  end

  describe "when matching the [19] OffsetClause production rule" do
    it "rejects empty input" do
      parse(%q()).offset_clause.should be_false
    end

    it "recognizes OFFSET clauses" do
      parse(%q(OFFSET 10)).offset_clause.should == [:offset, 10]
    end
  end

  describe "when matching the [20] GroupGraphPattern production rule" do
    it "rejects empty input" do
      parse(%q()).group_graph_pattern.should be_false
    end

    # TODO
  end

  describe "when matching the [21] TriplesBlock production rule" do
    it "rejects empty input" do
      parse(%q()).triples_block.should be_false
    end

    # TODO
  end

  describe "when matching the [22] GraphPatternNotTriples production rule" do
    it "rejects empty input" do
      parse(%q()).graph_pattern_not_triples.should be_false
    end

    # TODO
  end

  describe "when matching the [23] OptionalGraphPattern production rule" do
    it "rejects empty input" do
      parse(%q()).optional_graph_pattern.should be_false
    end

    # TODO
  end

  describe "when matching the [24] GraphGraphPattern production rule" do
    it "rejects empty input" do
      parse(%q()).graph_graph_pattern.should be_false
    end

    # TODO
  end

  describe "when matching the [25] GroupOrUnionGraphPattern production rule" do
    it "rejects empty input" do
      parse(%q()).group_or_union_graph_pattern.should be_false
    end

    # TODO
  end

  describe "when matching the [26] Filter production rule" do
    it "rejects empty input" do
      parse(%q()).filter.should be_false
    end

    # TODO
  end

  describe "when matching the [27] Constraint production rule" do
    it "rejects empty input" do
      parse(%q()).constraint.should be_false
    end

    # TODO
  end

  describe "when matching the [28] FunctionCall production rule" do
    it "rejects empty input" do
      parse(%q()).function_call.should be_false
    end

    # TODO
  end

  describe "when matching the [29] ArgList production rule" do
    it "rejects empty input" do
      parse(%q()).arg_list.should be_false
    end

    # TODO
  end

  describe "when matching the [30] ConstructTemplate production rule" do
    it "rejects empty input" do
      parse(%q()).construct_template.should be_false
    end

    # TODO
  end

  describe "when matching the [31] ConstructTriples production rule" do
    it "rejects empty input" do
      parse(%q()).construct_triples.should be_false
    end

    # TODO
  end

  describe "when matching the [32] TriplesSameSubject production rule" do
    it "rejects empty input" do
      parse(%q()).triples_same_subject.should be_false
    end

    # TODO
  end

  describe "when matching the [33] PropertyListNotEmpty production rule" do
    it "rejects empty input" do
      parse(%q()).property_list_not_empty.should be_false
    end

    # TODO
  end

  describe "when matching the [34] PropertyList production rule" do
    it "rejects empty input" do
      parse(%q()).property_list.should be_false
    end

    # TODO
  end

  describe "when matching the [35] ObjectList production rule" do
    it "rejects empty input" do
      parse(%q()).object_list.should be_false
    end

    # TODO
  end

  describe "when matching the [36] Object production rule" do
    it "rejects empty input" do
      parse(%q()).object.should be_false
    end

    # TODO
  end

  describe "when matching the [37] Verb production rule" do
    it "rejects empty input" do
      parse(%q()).verb.should be_false
    end

    it "recognizes the VarOrIRIref nonterminal" do
      # TODO
    end

    it "recognizes the 'a' lexeme" do
      parse(%q(a)).verb.should == RDF.type
    end
  end

  describe "when matching the [38] TriplesNode production rule" do
    it "rejects empty input" do
      parse(%q()).triples_node.should be_false
    end

    # TODO
  end

  describe "when matching the [39] BlankNodePropertyList production rule" do
    it "rejects empty input" do
      parse(%q()).blank_node_property_list.should be_false
    end

    # TODO
  end

  describe "when matching the [40] Collection production rule" do
    it "rejects empty input" do
      parse(%q()).collection.should be_false
    end

    # TODO
  end

  describe "when matching the [41] GraphNode production rule" do
    it "rejects empty input" do
      parse(%q()).graph_node.should be_false
    end

    # TODO
  end

  describe "when matching the [42] VarOrTerm production rule" do
    it "rejects empty input" do
      parse(%q()).var_or_term.should be_false
    end

    it "recognizes the Var nonterminal" do
      # TODO
    end

    it "recognizes the GraphTerm nonterminal" do
      # TODO
    end
  end

  describe "when matching the [43] VarOrIRIref production rule" do
    it "rejects empty input" do
      parse(%q()).var_or_iriref.should be_false
    end

    it "recognizes the Var nonterminal" do
      # TODO
    end

    it "recognizes the IRIref nonterminal" do
      # TODO
    end
  end

  describe "when matching the [44] Var production rule" do
    it "rejects empty input" do
      parse(%q()).var.should be_false
    end

    it "recognizes the VAR1 terminal" do
      %w(foo bar).each do |input|
        parse("?#{input}").var.should == RDF::Query::Variable.new(input.to_sym)
      end
    end

    it "recognizes the VAR2 terminal" do
      %w(foo bar).each do |input|
        parse("$#{input}").var.should == RDF::Query::Variable.new(input.to_sym)
      end
    end
  end

  describe "when matching the [45] GraphTerm production rule" do
    it "rejects empty input" do
      parse(%q()).graph_term.should be_false
    end

    it "recognizes the IRIref nonterminal" do
      # TODO
    end

    it "recognizes the RDFLiteral nonterminal" do
      # TODO
    end

    it "recognizes the NumericLiteral nonterminal" do
      # TODO
    end

    it "recognizes the BooleanLiteral nonterminal" do
      # TODO
    end

    it "recognizes the BlankNode nonterminal" do
      # TODO
    end

    it "recognizes the NIL terminal" do
      # TODO
    end
  end

  describe "when matching the [46] Expression production rule" do
    it "rejects empty input" do
      parse(%q()).expression.should be_false
    end

    # TODO
  end

  describe "when matching the [47] ConditionalOrExpression production rule" do
    it "rejects empty input" do
      parse(%q()).conditional_or_expression.should be_false
    end

    # TODO
  end

  describe "when matching the [48] ConditionalAndExpression production rule" do
    it "rejects empty input" do
      parse(%q()).conditional_and_expression.should be_false
    end

    # TODO
  end

  describe "when matching the [49] ValueLogical production rule" do
    it "rejects empty input" do
      parse(%q()).value_logical.should be_false
    end

    # TODO
  end

  describe "when matching the [50] RelationalExpression production rule" do
    it "rejects empty input" do
      parse(%q()).relational_expression.should be_false
    end

    # TODO
  end

  describe "when matching the [51] NumericExpression production rule" do
    it "rejects empty input" do
      parse(%q()).numeric_expression.should be_false
    end

    # TODO
  end

  describe "when matching the [52] AdditiveExpression production rule" do
    it "rejects empty input" do
      parse(%q()).additive_expression.should be_false
    end

    # TODO
  end

  describe "when matching the [53] MultiplicativeExpression production rule" do
    it "rejects empty input" do
      parse(%q()).multiplicative_expression.should be_false
    end

    # TODO
  end

  describe "when matching the [54] UnaryExpression production rule" do
    it "rejects empty input" do
      parse(%q()).unary_expression.should be_false
    end

    # TODO
  end

  describe "when matching the [55] PrimaryExpression production rule" do
    it "rejects empty input" do
      parse(%q()).primary_expression.should be_false
    end

    # TODO
  end

  describe "when matching the [56] BrackettedExpression production rule" do
    it "rejects empty input" do
      parse(%q()).bracketted_expression.should be_false
    end

    # TODO
  end

  describe "when matching the [57] BuiltInCall production rule" do
    it "rejects empty input" do
      parse(%q()).built_in_call.should be_false
    end

    # TODO
  end

  describe "when matching the [58] RegexExpression production rule" do
    it "rejects empty input" do
      parse(%q()).regex_expression.should be_false
    end

    # TODO
  end

  describe "when matching the [59] IRIrefOrFunction production rule" do
    it "rejects empty input" do
      parse(%q()).iriref_or_function.should be_false
    end

    # TODO
  end

  describe "when matching the [60] RDFLiteral production rule" do
    it "rejects empty input" do
      parse(%q()).rdf_literal.should be_false
    end

    it "recognizes plain literals" do
      # TODO
    end

    it "recognizes language-tagged literals" do
      # TODO
    end

    it "recognizes datatyped literals" do
      # TODO
    end
  end

  describe "when matching the [61] NumericLiteral production rule" do
    it "rejects empty input" do
      parse(%q()).numeric_literal.should be_false
    end

    it "recognizes the NumericLiteralUnsigned nonterminal" do
      parse(%q(123)).numeric_literal.should     == RDF::Literal::Integer.new(123)
      parse(%q(3.1415)).numeric_literal.should  == RDF::Literal::Decimal.new(3.1415)
      parse(%q(1e6)).numeric_literal.should     == RDF::Literal::Double.new(1e6)
    end

    it "recognizes the NumericLiteralPositive nonterminal" do
      parse(%q(+123)).numeric_literal.should    == RDF::Literal::Integer.new(123)
      parse(%q(+3.1415)).numeric_literal.should == RDF::Literal::Decimal.new(3.1415)
      parse(%q(+1e6)).numeric_literal.should    == RDF::Literal::Double.new(1e6)
    end

    it "recognizes the NumericLiteralNegative nonterminal" do
      parse(%q(-123)).numeric_literal.should    == RDF::Literal::Integer.new(-123)
      parse(%q(-3.1415)).numeric_literal.should == RDF::Literal::Decimal.new(-3.1415)
      parse(%q(-1e6)).numeric_literal.should    == RDF::Literal::Double.new(-1e6)
    end
  end

  describe "when matching the [62] NumericLiteralUnsigned production rule" do
    it "rejects empty input" do
      parse(%q()).numeric_literal_unsigned.should be_false
    end

    it "recognizes the INTEGER terminal" do
      %w(1 2 3 42 123).each do |input|
        parse(input).numeric_literal_unsigned.should == RDF::Literal::Integer.new(input.to_i)
      end
    end

    it "recognizes the DECIMAL terminal" do
      %w(1. 3.1415 .123).each do |input|
        parse(input).numeric_literal_unsigned.should == RDF::Literal::Decimal.new(input.to_f)
      end
    end

    it "recognizes the DOUBLE terminal" do
      %w(1e2 3.1415e2 .123e2).each do |input|
        parse(input).numeric_literal_unsigned.should == RDF::Literal::Double.new(input.to_f)
      end
    end
  end

  describe "when matching the [63] NumericLiteralPositive production rule" do
    it "rejects empty input" do
      parse(%q()).numeric_literal_positive.should be_false
    end

    it "recognizes the INTEGER_POSITIVE terminal" do
      %w(+1 +2 +3 +42 +123).each do |input|
        parse(input).numeric_literal_positive.should == RDF::Literal::Integer.new(input.to_i)
      end
    end

    it "recognizes the DECIMAL_POSITIVE terminal" do
      %w(+1. +3.1415 +.123).each do |input|
        parse(input).numeric_literal_positive.should == RDF::Literal::Decimal.new(input.to_f)
      end
    end

    it "recognizes the DOUBLE_POSITIVE terminal" do
      %w(+1e2 +3.1415e2 +.123e2).each do |input|
        parse(input).numeric_literal_positive.should == RDF::Literal::Double.new(input.to_f)
      end
    end
  end

  describe "when matching the [64] NumericLiteralNegative production rule" do
    it "rejects empty input" do
      parse(%q()).numeric_literal_negative.should be_false
    end

    it "recognizes the INTEGER_NEGATIVE terminal" do
      %w(-1 -2 -3 -42 -123).each do |input|
        parse(input).numeric_literal_negative.should == RDF::Literal::Integer.new(input.to_i)
      end
    end

    it "recognizes the DECIMAL_NEGATIVE terminal" do
      %w(-1. -3.1415 -.123).each do |input|
        parse(input).numeric_literal_negative.should == RDF::Literal::Decimal.new(input.to_f)
      end
    end

    it "recognizes the DOUBLE_NEGATIVE terminal" do
      %w(-1e2 -3.1415e2 -.123e2).each do |input|
        parse(input).numeric_literal_negative.should == RDF::Literal::Double.new(input.to_f)
      end
    end
  end

  describe "when matching the [65] BooleanLiteral production rule" do
    it "rejects empty input" do
      parse(%q()).boolean_literal.should be_false
    end

    it "recognizes the 'true' lexeme" do
      %w(true).each do |input|
        parse(input).boolean_literal.should == RDF::Literal(true)
      end
    end

    it "recognizes the 'false' lexeme" do
      %w(false).each do |input|
        parse(input).boolean_literal.should == RDF::Literal(false)
      end
    end
  end

  describe "when matching the [66] String production rule" do
    it "rejects empty input" do
      parse(%q()).string.should be_false
    end

    inputs = {
      :STRING_LITERAL1      => %q('foobar'),
      :STRING_LITERAL2      => %q("foobar"),
      :STRING_LITERAL_LONG1 => %q('''foobar'''),
      :STRING_LITERAL_LONG2 => %q("""foobar"""),
    }
    inputs.each do |terminal, input|
      it "recognizes the #{terminal} terminal" do
        parse(input).string.should eql(RDF::Literal('foobar'))
      end
    end
  end

  describe "when matching the [67] IRIref production rule" do
    it "rejects empty input" do
      parse(%q()).iriref.should be_false
    end

    it "recognizes the IRI_REF terminal" do
      %w(<> <foobar> <http://example.org/foobar>).each do |input|
        parse(input).iriref.should_not == false # TODO
      end
    end

    it "recognizes the PrefixedName nonterminal" do
      %w(: foo: :bar foo:bar).each do |input|
        parse(input).iriref.should_not == false # TODO
      end
    end
  end

  describe "when matching the [68] PrefixedName production rule" do
    it "rejects empty input" do
      parse(%q()).prefixed_name.should be_false
    end

    inputs = {
      :PNAME_LN => %w(:bar foo:bar),
      :PNAME_NS => %w(: foo:),
    }
    inputs.each do |terminal, examples|
      it "recognizes the #{terminal} terminal" do
        examples.each do |input|
          parse(input).prefixed_name.should_not == false # TODO
        end
      end
    end
  end

  describe "when matching the [69] BlankNode production rule" do
    it "rejects empty input" do
      parse(%q()).blank_node.should be_false
    end

    inputs = {
      :BLANK_NODE_LABEL => %q(_:foobar),
      :ANON             => %q([]),
    }
    inputs.each do |terminal, input|
      it "recognizes the #{terminal} terminal" do
        if output = parse(input).blank_node
          output.should be_an(RDF::Node)
        end
      end
    end
  end

  describe "when matching the [70] IRI_REF production rule" do
    it "rejects empty input" do
      parse(%q()).iri_ref.should be_false
    end

    it "recognizes the empty IRI reference" do
      parse(%q(<>)).iri_ref.should eql(RDF::URI(''))
    end

    it "recognizes relative IRI references" do
      parse(%q(<foobar>)).iri_ref.should eql(RDF::URI('foobar'))
    end

    it "recognizes absolute IRI references" do
      parse(%q(<http://example.org/foobar>)).iri_ref.should eql(RDF::URI('http://example.org/foobar'))
    end
  end

  describe "when matching the [71] PNAME_NS production rule" do
    it "rejects empty input" do
      parse(%q()).pname_ns.should be_false
    end

    it "recognizes the ':' lexeme" do
      parse(%q(:)).pname_ns.should == nil
    end

    it "recognizes the 'foo:' lexeme" do
      parse(%q(foo:)).pname_ns.should == :foo
    end
  end

  describe "when matching the [72] PNAME_LN production rule" do
    it "rejects empty input" do
      parse(%q()).pname_ln.should be_false
    end

    it "recognizes the ':bar' lexeme" do
      parse(%q(:bar)).pname_ln.should == [nil, :bar]
    end

    it "recognizes the 'foo:bar' lexeme" do
      parse(%q(foo:bar)).pname_ln.should == [:foo, :bar]
    end
  end

  # NOTE: production rules [73..75] are internal to the lexer

  describe "when matching the [76] LANGTAG production rule" do
    it "rejects empty input" do
      parse(%q()).langtag.should be_false
    end

    it "recognizes the '@en' lexeme" do
      parse(%q(@en)).langtag.should == :en
    end

    it "recognizes the '@en-US' lexeme" do
      parse(%q(@en-US)).langtag.should == :'en-US'
    end
  end

  # NOTE: production rules [77..91] are internal to the lexer

  describe "when matching the [92] NIL production rule" do
    it "rejects empty input" do
      parse(%q()).nil.should be_false
    end

    it "recognizes the '()' lexeme" do
      parse(%q(())).nil.should == RDF.nil
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

  def parse(query, options = {})
    SPARQL::Grammar::Parser.new(query, options)
  end
end
