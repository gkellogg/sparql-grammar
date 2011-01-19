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

  def it_does_not_generate_using(production, input)
    it "Does not generate" do
      parser(production).call(input).should be_false
    end
  end

  def given_it_generates(production, input, result, options = {})
    it "given #{input.inspect} it generates #{present_results(result, options)}" do
      if options[:last]
        # Only look at end of production
        parser(production, options).call(input).last.should == result
      elsif options[:shift]
        parser(production, options).call(input)[1..-1].should == result
      elsif result.is_a?(String)
        parser(production, options).call(input).to_sxp.should == result.gsub(/[\n ]+/m, " ")
      else
        parser(production, options).call(input).should == result
      end
    end
  end

  # [28] FunctionCall
  def it_recognizes_function_using(production)
    it "recognizes the FunctionCall nonterminal" do
      it_recognizes_function(production)
    end
  end

  # [41]    GraphNode
  def it_recognizes_graph_node_using(production)
    it "recognizes the GraphNode nonterminal" do
      it_recognizes_graph_node(production)
    end
  end

  # [42]    VarOrTerm
  def it_recognizes_var_or_term_using(production)
    it "recognizes the VarOrTerm nonterminal" do
      it_recognizes_var_or_iriref(production)
    end
  end

  # [43]    VarOrIRIref
  def it_recognizes_var_or_iriref_using(production)
    it "recognizes the VarOrIRIref nonterminal" do
      it_recognizes_var_or_iriref(production)
    end
  end

  # [44] Var
  def it_recognizes_var_using(production)
    it "recognizes the Var nonterminal" do
      it_recognizes_var(production)
    end
  end

  # [45] GraphTerm
  def it_recognizes_graph_term_using(production)
    it "recognizes the GraphTerm nonterminal" do
      it_recognizes_graph_term(production)
    end
  end

  # [46]    Expression
  def it_recognizes_expression_using(production)
    it "recognizes Expression nonterminal" do
      it_recognizes_expression(production)
    end
  end

  # [47]    ConditionalOrExpression
  def it_recognizes_conditional_or_expression_using(production)
    it "recognizes ConditionalOrExpression nonterminal" do
      it_recognizes_conditional_or_expression(production)
    end
  end

  # [48]    ConditionalAndExpression
  def it_recognizes_conditional_and_expression_using(production)
    it "recognizes ConditionalAndExpression nonterminal" do
      it_recognizes_conditional_and_expression(production)
    end
  end

  # [49]    ValueLogical
  def it_recognizes_value_logical_using(production)
    it "recognizes ValueLogical nonterminal" do
      it_recognizes_value_logical(production)
    end
  end

  # [50]    RelationalExpression
  def it_recognizes_relational_expression_using(production)
    it "recognizes RelationalExpression nonterminal" do
      it_recognizes_relational_expression(production)
    end
  end

  # [51]    NumericExpression
  def it_recognizes_numeric_expression_using(production)
    it "recognizes NumericExpression nonterminal" do
      it_recognizes_numeric_expression(production)
    end
  end

  # [52]    AdditiveExpression
  def it_recognizes_additive_expression_using(production)
    it "recognizes AdditiveExpression nonterminal" do
      it_recognizes_additive_expression(production)
    end
  end

  # [53]    MultiplicativeExpression
  def it_recognizes_multiplicative_expression_using(production)
    it "recognizes MultiplicativeExpression nonterminal" do
      it_recognizes_multiplicative_expression(production)
    end
  end

  # [54] UnaryExpression
  def it_recognizes_unary_expression_using(production)
    it "recognizes UnaryExpression nonterminal" do
      it_recognizes_unary_expression(production)
    end
  end

  # [55]    PrimaryExpression
  def it_recognizes_primary_expression_using(production)
    it "recognizes PrimaryExpression nonterminal" do
      it_recognizes_primary_expression(production)
    end
  end

  # [56]    BrackettedExpression ::=       '(' Expression ')'
  def it_recognizes_bracketted_expression_using(production)
    it "recognizes BrackettedExpression nonterminal" do
      it_recognizes_bracketted_expression(production)
    end
  end

  # [57]    BuiltInCall
  def it_recognizes_built_in_call_using(production)
    it "recognizes BuiltInCall nonterminal" do
      it_recognizes_built_in_call(production)
    end
  end

  # [58]    RegexExpression
  def it_recognizes_regex_expression_using(production)
    it "recognizes RegexExpression nonterminal" do
      it_recognizes_regex_expression(production)
    end
  end

  # [59]    IRIrefOrFunction
  def it_recognizes_iriref_or_function_using(production)
    it "recognizes the IRIrefOrFunction nonterminal" do
      it_recognizes_iriref_or_function(production)
    end
  end

  # [60] RDFLiteral
  def it_recognizes_rdf_literal_using(production)
    it "recognizes the RDFLiteral nonterminal" do
      it_recognizes_rdf_literal_without_language_or_datatype(production)
      it_recognizes_rdf_literal_with_language(production)
      it_recognizes_rdf_literal_with_datatype(production)
    end
  end

  # [61] NumericLiteral
  def it_recognizes_numeric_literal_using(production)
    it "recognizes the NumericLiteral nonterminal" do
      it_recognizes_numeric_literal(production)
    end
  end

  # [65] BooleanLiteral
  def it_recognizes_boolean_literal_using(production)
    it "recognizes the BooleanLiteral nonterminal" do
      it_recognizes_boolean_literal(production)
    end
  end

  # [67] IRIref
  def it_recognizes_iriref_using(production)
    it "recognizes the IRIref nonterminal" do
      it_recognizes_iriref(production)
    end
  end

  # [69] BlankNode
  def it_recognizes_blank_node_using(production)
    it "recognizes the BlankNode nonterminal" do
      it_recognizes_blank_node(production)
    end
  end

  # [92] NIL
  def it_recognizes_nil_using(production)
    it "recognizes the NIL terminal" do
      it_recognizes_nil(production)
    end
  end

  def present_results(array, options = {})
    return array if array.is_a?(String)
    "[" +
    array.map do |e|
      case e
      when Array                then present_results(e, options)
      when Symbol               then ":#{e}"
      when RDF::Node            then e.to_s
      when RDF::Query::Variable then e.to_s
      when RDF::Literal        then RDF::NTriples::Writer.new.format_value(e)
      when RDF::URI
        if options[:prefixes] && (start = options[:prefixes].values.detect {|v| e.to_s.index(v) == 0})
          prefix = options[:prefixes].invert[start].to_s
          "#{prefix}:#{e.to_s.sub(start, '')}"
        elsif options[:base_uri] && e.to_s.index(options[:base_uri]) == 0
          "<#{e.to_s.sub(options[:base_uri], '')}>"
        else
          "<#{e}>"
        end
      else                           e.inspect
      end
    end.join(", ") +
    "]"
  end
end

module ProductionExamples
  # [28] FunctionCall
  def it_recognizes_function(production)
    parser(production).call(%q(<foo>("bar"))).last.should == [RDF::URI("foo"), RDF::Literal("bar")]
    parser(production).call(%q(<foo>())).last.should == [RDF::URI("foo"), RDF["nil"]]
  end

  # [41]    GraphNode                 ::=       VarOrTerm | TriplesNode
  def it_recognizes_graph_node(production)
    it_recognizes_var_or_term(production)
  end

  # [42]    VarOrTerm                 ::=       Var | GraphTerm
  def it_recognizes_var_or_term(production)
    it_recognizes_var(production)
    it_recognizes_graph_term(production)
  end

  # [43]    VarOrIRIref               ::=       Var | IRIref
  def it_recognizes_var_or_iriref(production)
    it_recognizes_var(production)
    it_recognizes_iriref(production)
  end

  # [44]    Var                       ::=       VAR1 | VAR2
  def it_recognizes_var(production)
    it_recognizes_var1(production)
    it_recognizes_var2(production)
  end

  # [45] GraphTerm ::=       IRIref | RDFLiteral | NumericLiteral | BooleanLiteral | BlankNode | NIL
  def it_recognizes_graph_term(production)
    it_recognizes_iriref(production)
    it_recognizes_rdf_literal_without_language_or_datatype(production)
    it_recognizes_rdf_literal_with_language(production)
    it_recognizes_rdf_literal_with_datatype(production)
    it_recognizes_numeric_literal production
    it_recognizes_boolean_literal production
    it_recognizes_blank_node production
    it_recognizes_nil production
  end

  # [46]    Expression ::=       ConditionalOrExpression
  def it_recognizes_expression(production)
    it_recognizes_conditional_or_expression(production)
  end

  # [47]    ConditionalOrExpression ::=       ConditionalAndExpression ( '||' ConditionalAndExpression )*
  def it_recognizes_conditional_or_expression(production)
    parser(production).call(%q(1 || 2)).should == [:Expression, [:"||", RDF::Literal(1), RDF::Literal(2)]]
    parser(production).call(%q(1 || 2 && 3)).should == [:Expression, [:"||", RDF::Literal(1), [:"&&", RDF::Literal(2), RDF::Literal(3)]]]
    parser(production).call(%q(1 && 2 || 3)).should == [:Expression, [:"||", [:"&&", RDF::Literal(1), RDF::Literal(2)], RDF::Literal(3)]]

    parser(production).call(%q(1 || 2 || 3)).should == [:Expression, [:"||", [:"||", RDF::Literal(1), RDF::Literal(2)], RDF::Literal(3)]]
    it_recognizes_conditional_and_expression(production)
  end

  # [48]    ConditionalAndExpression ::=       ValueLogical ( '&&' ValueLogical )*
  def it_recognizes_conditional_and_expression(production)
    parser(production).call(%q(1 && 2)).should == [:Expression, [:"&&", RDF::Literal(1), RDF::Literal(2)]]
    parser(production).call(%q(1 && 2 = 3)).should == [:Expression, [:"&&", RDF::Literal(1), [:"=", RDF::Literal(2), RDF::Literal(3)]]]

    parser(production).call(%q(1 && 2 && 3)).should == [:Expression, [:"&&", [:"&&", RDF::Literal(1), RDF::Literal(2)], RDF::Literal(3)]]
    it_recognizes_value_logical(production)
  end

  # [49]    ValueLogical ::=       RelationalExpression
  def it_recognizes_value_logical(production)
    it_recognizes_relational_expression(production)
  end

  # [50]    RelationalExpression ::= NumericExpression (
  #                                      '=' NumericExpression
  #                                    | '!=' NumericExpression
  #                                    | '<' NumericExpression
  #                                    | '>' NumericExpression
  #                                    | '<=' NumericExpression
  #                                    | '>=' NumericExpression )?
  def it_recognizes_relational_expression(production)
    parser(production).call(%q(1 = 2)).should == [:Expression, [:"=", RDF::Literal(1), RDF::Literal(2)]]
    parser(production).call(%q(1 != 2)).should == [:Expression, [:"!=", RDF::Literal(1), RDF::Literal(2)]]
    parser(production).call(%q(1 < 2)).should == [:Expression, [:"<", RDF::Literal(1), RDF::Literal(2)]]
    parser(production).call(%q(1 > 2)).should == [:Expression, [:">", RDF::Literal(1), RDF::Literal(2)]]
    parser(production).call(%q(1 <= 2)).should == [:Expression, [:"<=", RDF::Literal(1), RDF::Literal(2)]]
    parser(production).call(%q(1 >= 2)).should == [:Expression, [:">=", RDF::Literal(1), RDF::Literal(2)]]

    parser(production).call(%q(1 + 2 = 3)).should == [:Expression, [:"=", [:"+", RDF::Literal(1), RDF::Literal(2)], RDF::Literal(3)]]
    
    it_recognizes_numeric_expression(production)
  end

  # [51]    NumericExpression ::=       AdditiveExpression
  def it_recognizes_numeric_expression(production)
    it_recognizes_additive_expression(production)
  end

  # [52]    AdditiveExpression ::= MultiplicativeExpression ( '+' MultiplicativeExpression | '-' MultiplicativeExpression )*
  def it_recognizes_additive_expression(production)
    parser(production).call(%q(1 + 2)).should == [:Expression, [:"+", RDF::Literal(1), RDF::Literal(2)]]
    parser(production).call(%q(1 - 2)).should == [:Expression, [:"-", RDF::Literal(1), RDF::Literal(2)]]
    parser(production).call(%q(3+4)).should == [:Expression, [:"+", RDF::Literal(3), RDF::Literal(4)]]

    parser(production).call(%q("1" + "2" - "3")).should == [:Expression, [:"-", [:"+", RDF::Literal("1"), RDF::Literal("2")], RDF::Literal("3")]]
    parser(production).call(%q("1" - "2" + "3")).should == [:Expression, [:"+", [:"-", RDF::Literal("1"), RDF::Literal("2")], RDF::Literal("3")]]
    
    it_recognizes_multiplicative_expression(production)
  end

  # [53]    MultiplicativeExpression ::=       UnaryExpression ( '*' UnaryExpression | '/' UnaryExpression )*
  def it_recognizes_multiplicative_expression(production)
    parser(production).call(%q(1 * 2)).should == [:Expression, [:"*", RDF::Literal(1), RDF::Literal(2)]]
    parser(production).call(%q(1 / 2)).should == [:Expression, [:"/", RDF::Literal(1), RDF::Literal(2)]]
    parser(production).call(%q(3*4)).should == [:Expression, [:"*", RDF::Literal(3), RDF::Literal(4)]]

    parser(production).call(%q("1" * "2" * "3")).should == [:Expression, [:"*", [:"*", RDF::Literal("1"), RDF::Literal("2")], RDF::Literal("3")]]
    parser(production).call(%q("1" * "2" / "3")).should == [:Expression, [:"/", [:"*", RDF::Literal("1"), RDF::Literal("2")], RDF::Literal("3")]]

    it_recognizes_unary_expression(production)
  end

  # [54] UnaryExpression ::=  '!' PrimaryExpression | '+' PrimaryExpression | '-' PrimaryExpression | PrimaryExpression
  def it_recognizes_unary_expression(production)
    parser(production).call(%q(! "foo")).should == [:Expression, [:"!", RDF::Literal("foo")]]
    parser(production).call(%q(+ 1)).should == [:Expression, [:"+", RDF::Literal(1)]]
    parser(production).call(%q(- 1)).should == [:Expression, [:"-", RDF::Literal(1)]]
    parser(production).call(%q(+ "foo")).should == [:Expression, [:"+", RDF::Literal("foo")]]
    parser(production).call(%q(- "foo")).should == [:Expression, [:"-", RDF::Literal("foo")]]

    it_recognizes_bracketted_expression production
    it_recognizes_built_in_call production
    it_recognizes_iriref_or_function production
    it_recognizes_rdf_literal_without_language_or_datatype(production)
    it_recognizes_rdf_literal_with_language(production)
    it_recognizes_rdf_literal_with_datatype(production)
    #it_recognizes_numeric_literal production             # This conflicts
    it_recognizes_boolean_literal production
    it_recognizes_var production
  end

  # [55]    PrimaryExpression ::=       BrackettedExpression | BuiltInCall | IRIrefOrFunction | RDFLiteral | NumericLiteral | BooleanLiteral | Var
  def it_recognizes_primary_expression(production)
    it_recognizes_bracketted_expression production
    it_recognizes_built_in_call production
    it_recognizes_iriref_or_function production
    it_recognizes_rdf_literal_without_language_or_datatype(production)
    it_recognizes_rdf_literal_with_language(production)
    it_recognizes_rdf_literal_with_datatype(production)
    it_recognizes_numeric_literal production
    it_recognizes_boolean_literal production
    it_recognizes_var production
  end

  # [56]    BrackettedExpression ::=       '(' Expression ')'
  def it_recognizes_bracketted_expression(production)
    parser(production).call(%q(("foo")))[1..-1].should == [RDF::Literal("foo")]
  end

  # [57]    BuiltInCall ::=  'STR' '(' Expression ')'
  #                        | 'LANG' '(' Expression ')'
  #                        | 'LANGMATCHES' '(' Expression ',' Expression ')'
  #                        | 'DATATYPE' '(' Expression ')'
  #                        | 'BOUND' '(' Var ')'
  #                        | 'sameTerm' '(' Expression ',' Expression ')'
  #                        | 'isIRI' '(' Expression ')'
  #                        | 'isURI' '(' Expression ')'
  #                        | 'isBLANK' '(' Expression ')'
  #                        | 'isLITERAL' '(' Expression ')'
  #                        | RegexExpression
  def it_recognizes_built_in_call(production)
    parser(production).call(%q(STR ("foo")))[1..-1].should == %q((str "foo"))
    parser(production).call(%q(STR (("foo"))))[1..-1].to_sxp.should == %q((str "foo"))
    parser(production).call(%q(LANG ("foo")))[1..-1].should == %q((lang "foo"))
    parser(production).call(%q(LANGMATCHES ("foo", "bar")))[1..-1].should == %q((langMatches "foo" "bar"))
    parser(production).call(%q(DATATYPE ("foo")))[1..-1].should == %q((datatype "foo"))
    parser(production).call(%q(sameTerm ("foo", "bar")))[1..-1].should == %q((sameTerm "foo" "bar"))
    parser(production).call(%q(isIRI ("foo")))[1..-1].should == %q((isIRI "foo"))
    parser(production).call(%q(isURI ("foo")))[1..-1].should == %q((isURI "foo"))
    parser(production).call(%q(isBLANK ("foo")))[1..-1].should == %q((isBLANK "foo"))
    parser(production).call(%q(isLITERAL ("foo")))[1..-1].should == %q((isLITERAL "foo"))
    parser(production).call(%q(BOUND (?foo)))[1..-1].should ==  %q((bound "foo"))
    parser(production).call(%q(REGEX ("foo", "bar")))[1..-1].should == %q((regex "foo" "bar"))
  end

  # [58]    RegexExpression ::=       'REGEX' '(' Expression ',' Expression ( ',' Expression )? ')'
  def it_recognizes_regex_expression(production)
    lambda { parser(production).call(%q(REGEX ("foo"))) }.should raise_error
    parser(production).call(%q(REGEX ("foo", "bar"))).should == %q((regex "foo" "bar"))
  end

  # [59]    IRIrefOrFunction ::=       IRIref ArgList?
  def it_recognizes_iriref_or_function(production)
    it_recognizes_iriref(production)
    it_recognizes_function(production)
  end

  # [60] RDFLiteral
  def it_recognizes_rdf_literal_without_language_or_datatype(production)
    parser(production).call(%q("")).last.should == RDF::Literal.new("")
    parser(production).call(%q("foobar")).last.should == RDF::Literal.new("foobar")
    {
      :STRING_LITERAL1      => %q('foobar'),
      :STRING_LITERAL2      => %q("foobar"),
      :STRING_LITERAL_LONG1 => %q('''foobar'''),
      :STRING_LITERAL_LONG2 => %q("""foobar"""),
    }.each do |terminal, input|
      parser(production).call(input).last.should eql(RDF::Literal('foobar'))
    end
  end

  # [60] RDFLiteral
  def it_recognizes_rdf_literal_with_language(production)
    parser(production).call(%q(""@en)).last.should == RDF::Literal.new("", :language => :en)
    parser(production).call(%q("foobar"@en-US)).last.should == RDF::Literal.new("foobar", :language => :'en-US')
  end

  # [60] RDFLiteral
  def it_recognizes_rdf_literal_with_datatype(production)
    parser(production).call(%q(""^^<http://www.w3.org/2001/XMLSchema#string>)).last.should == RDF::Literal.new("", :datatype => RDF::XSD.string)
    parser(production).call(%q("foobar"^^<http://www.w3.org/2001/XMLSchema#string>)).last.should == RDF::Literal.new("foobar", :datatype => RDF::XSD.string)
  end

  # [61] NumericLiteral
  def it_recognizes_numeric_literal(production)
    parser(production).call(%q(123)).last.should     == RDF::Literal::Integer.new(123)
    parser(production).call(%q(+3.1415)).last.should == RDF::Literal::Decimal.new(3.1415)
    parser(production).call(%q(-1e6)).last.should    == RDF::Literal::Double.new(-1e6)
  end

  # [65] BooleanLiteral
  def it_recognizes_boolean_literal(production)
    parser(production).call(%q(true)).last.should == RDF::Literal(true)
    parser(production).call(%q(false)).last.should == RDF::Literal(false)
  end

  # [67] IRIref
  def it_recognizes_iriref(production)
    parser(production).call(%q(<http://example.org/>)).last.should == RDF::URI('http://example.org/')
    # XXXtest prefixed names
  end

  # [69] BlankNode
  def it_recognizes_blank_node(production)
    parser(production).call(%q(_:foobar)).last.should == RDF::Node(:foobar)
    parser(production).call(%q([])).last.should be_an(RDF::Node)
  end

  # [74] VAR1
  def it_recognizes_var1(production)
    %w(foo bar).each do |input|
      parser(production).call("?#{input}").last.should == RDF::Query::Variable.new(input.to_sym)
    end
  end

  # [75] VAR2
  def it_recognizes_var2(production)
    %w(foo bar).each do |input|
      parser(production).call("$#{input}").last.should == RDF::Query::Variable.new(input.to_sym)
    end
  end

  # [92] NIL
  def it_recognizes_nil(production)
    parser(production).call(%q(())).last.should == RDF.nil
  end

  TRIPLES = {
    # From sytax-sparql1/syntax-basic-03.rq
    %q(?x ?y ?z) =>
      [[:triple, RDF::Query::Variable.new("x"), RDF::Query::Variable.new("y"), RDF::Query::Variable.new("z")]],
    # From sytax-sparql1/syntax-basic-05.rq
    %q(?x ?y ?z . ?a ?b ?c) =>
      [[:triple, RDF::Query::Variable.new("x"), RDF::Query::Variable.new("y"), RDF::Query::Variable.new("z")],
      [:triple, RDF::Query::Variable.new("a"), RDF::Query::Variable.new("b"), RDF::Query::Variable.new("c")]],
    # From sytax-sparql1/syntax-bnodes-01.rq
    %q([:p :q ]) =>
      [[:triple, RDF::Node("gen0001"), RDF::URI("http://example.com/p"), RDF::URI("http://example.com/q")]],
    # From sytax-sparql1/syntax-bnodes-02.rq
    %q([] :p :q) =>
      [[:triple, RDF::Node("gen0001"), RDF::URI("http://example.com/p"), RDF::URI("http://example.com/q")]],

    # From sytax-sparql2/syntax-general-01.rq
    %q(<a><b><c>) =>
      [[:triple, RDF::URI("http://example.org/a"), RDF::URI("http://example.org/b"), RDF::URI("http://example.org/c")]],
    # From sytax-sparql2/syntax-general-02.rq
    %q(<a><b>_:x) =>
      [[:triple, RDF::URI("http://example.org/a"), RDF::URI("http://example.org/b"), RDF::Node("x")]],
    # From sytax-sparql2/syntax-general-03.rq
    %q(<a><b>1) =>
      [[:triple, RDF::URI("http://example.org/a"), RDF::URI("http://example.org/b"), RDF::Literal(1)]],
    # From sytax-sparql2/syntax-general-04.rq
    %q(<a><b>+1) =>
      [[:triple, RDF::URI("http://example.org/a"), RDF::URI("http://example.org/b"), RDF::Literal::Integer.new("+1")]],
    # From sytax-sparql2/syntax-general-05.rq
    %q(<a><b>-1) =>
      [[:triple, RDF::URI("http://example.org/a"), RDF::URI("http://example.org/b"), RDF::Literal::Integer.new("-1")]],
    # From sytax-sparql2/syntax-general-06.rq
    %q(<a><b>1.0) =>
      [[:triple, RDF::URI("http://example.org/a"), RDF::URI("http://example.org/b"), RDF::Literal::Decimal.new("1.0")]],
    # From sytax-sparql2/syntax-general-07.rq
    %q(<a><b>+1.0) =>
      [[:triple, RDF::URI("http://example.org/a"), RDF::URI("http://example.org/b"), RDF::Literal::Decimal.new("+1.0")]],
    # From sytax-sparql2/syntax-general-08.rq
    %q(<a><b>-1.0) =>
      [[:triple, RDF::URI("http://example.org/a"), RDF::URI("http://example.org/b"), RDF::Literal::Decimal.new("-1.0")]],
    # From sytax-sparql2/syntax-general-09.rq
    %q(<a><b>1.0e0) =>
      [[:triple, RDF::URI("http://example.org/a"), RDF::URI("http://example.org/b"), RDF::Literal::Double.new("1.0e0")]],
    # From sytax-sparql2/syntax-general-10.rq
    %q(<a><b>+1.0e+1) =>
      [[:triple, RDF::URI("http://example.org/a"), RDF::URI("http://example.org/b"), RDF::Literal::Double.new("+1.0e+1")]],
    # From sytax-sparql2/syntax-general-11.rq
    %q(<a><b>-1.0e-1) =>
      [[:triple, RDF::URI("http://example.org/a"), RDF::URI("http://example.org/b"), RDF::Literal::Double.new("-1.0e-1")]],

    # Made up syntax tests
    %q(<a><b><c>,<d>) =>
      [[:triple, RDF::URI("http://example.org/a"), RDF::URI("http://example.org/b"), RDF::URI("http://example.org/c")],
      [:triple, RDF::URI("http://example.org/a"), RDF::URI("http://example.org/b"), RDF::URI("http://example.org/d")]],
    %q(<a><b><c>;<d><e>) =>
      [[:triple, RDF::URI("http://example.org/a"), RDF::URI("http://example.org/b"), RDF::URI("http://example.org/c")],
      [:triple, RDF::URI("http://example.org/a"), RDF::URI("http://example.org/d"), RDF::URI("http://example.org/e")]],
    %q([<b><c>,<d>]) =>
      [[:triple, RDF::Node("gen0001"), RDF::URI("http://example.org/b"), RDF::URI("http://example.org/c")],
      [:triple, RDF::Node("gen0001"), RDF::URI("http://example.org/b"), RDF::URI("http://example.org/d")]],
    %q([<b><c>;<d><e>]) =>
      [[:triple, RDF::Node("gen0001"), RDF::URI("http://example.org/b"), RDF::URI("http://example.org/c")],
      [:triple, RDF::Node("gen0001"), RDF::URI("http://example.org/d"), RDF::URI("http://example.org/e")]],
    %q((<a>)) =>
      [[:triple, RDF::Node("gen0001"), RDF["first"], RDF::URI("http://example.org/a")],
      [:triple, RDF::Node("gen0001"), RDF["rest"], RDF["nil"]]],
    %q((<a> <b>)) =>
      [[:triple, RDF::Node("gen0001"), RDF["first"], RDF::URI("http://example.org/a")],
      [:triple, RDF::Node("gen0001"), RDF["rest"], RDF::Node("gen0002")],
      [:triple, RDF::Node("gen0002"), RDF["first"], RDF::URI("http://example.org/b")],
      [:triple, RDF::Node("gen0002"), RDF["rest"], RDF["nil"]]],
    %q(<a><b>"foobar") =>
      [[:triple, RDF::URI("http://example.org/a"), RDF::URI("http://example.org/b"), RDF::Literal("foobar")]],
    %q(<a><b>'foobar') =>
      [[:triple, RDF::URI("http://example.org/a"), RDF::URI("http://example.org/b"), RDF::Literal("foobar")]],
    %q(<a><b>"""foobar""") =>
      [[:triple, RDF::URI("http://example.org/a"), RDF::URI("http://example.org/b"), RDF::Literal("foobar")]],
    %q(<a><b>'''foobar''') =>
      [[:triple, RDF::URI("http://example.org/a"), RDF::URI("http://example.org/b"), RDF::Literal("foobar")]],
    %q(<a><b>"foobar"@en) =>
      [[:triple, RDF::URI("http://example.org/a"), RDF::URI("http://example.org/b"), RDF::Literal("foobar", :language => :en)]],
    %q(<a><b>"foobar"^^<c>) =>
      [[:triple, RDF::URI("http://example.org/a"), RDF::URI("http://example.org/b"), RDF::Literal("foobar", :datatype => RDF::URI("http://example.org/c"))]],
    %q(<a><b>()) =>
      [[:triple,  RDF::URI("http://example.org/a"), RDF::URI("http://example.org/b"), RDF["nil"]]],

    # From sytax-sparql1/syntax-bnodes-03.rq
    %q([ ?x ?y ] <http://example.com/p> [ ?pa ?b ]) =>
      [[:triple, RDF::Node("gen0001"), RDF::Query::Variable.new("x"), RDF::Query::Variable.new("y")],
      [:triple, RDF::Node("gen0001"), RDF::URI("http://example.com/p"), RDF::Node("gen0002")],
      [:triple, RDF::Node("gen0002"), RDF::Query::Variable.new("pa"), RDF::Query::Variable.new("b")]],
    # From sytax-sparql1/syntax-bnodes-03.rq
    %q(_:a :p1 :q1 .
       _:a :p2 :q2 .) =>
      [[:triple, RDF::Node("a"), RDF::URI("http://example.com/p1"), RDF::URI("http://example.com/q1")],
      [:triple, RDF::Node("a"), RDF::URI("http://example.com/p2"), RDF::URI("http://example.com/q2")]],
    # From sytax-sparql1/syntax-forms-01.rq
    %q(( [ ?x ?y ] ) :p ( [ ?pa ?b ] 57 )) =>
      [[:triple, RDF::Node("gen0002"), RDF::Query::Variable.new("x"), RDF::Query::Variable.new("y")],
      [:triple, RDF::Node("gen0001"), RDF["first"], RDF::Node("gen0002")],
      [:triple, RDF::Node("gen0001"), RDF["rest"], RDF["nil"]],
      [:triple, RDF::Node("gen0001"), RDF::URI("http://example.com/p"), RDF::Node("gen0003")],
      [:triple, RDF::Node("gen0004"), RDF::Query::Variable.new("pa"), RDF::Query::Variable.new("b")],
      [:triple, RDF::Node("gen0003"), RDF["first"], RDF::Node("gen0004")],
      [:triple, RDF::Node("gen0003"), RDF["rest"], RDF::Node("gen0005")],
      [:triple, RDF::Node("gen0005"), RDF["first"], RDF::Literal(57)],
      [:triple, RDF::Node("gen0005"), RDF["rest"], RDF["nil"]]],
    # From sytax-sparql1/syntax-lists-01.rq
    %q(( ?x ) :p ?z) =>
      [[:triple, RDF::Node("gen0001"), RDF["first"], RDF::Query::Variable.new("x")],
      [:triple, RDF::Node("gen0001"), RDF["rest"], RDF["nil"]],
      [:triple, RDF::Node("gen0001"), RDF::URI("http://example.com/p"), RDF::Query::Variable.new("z")]],
  }
end

describe SPARQL::Grammar::Parser do
  extend  ProductionRequirements
  extend  ProductionExamples
  include ProductionRequirements
  include ProductionExamples

  describe "when matching the [1] Query production rule" do
    with_production(:Query) do |production|
      it_rejects_empty_input_using production

      {
        "BASE <foo/> SELECT * WHERE { <a> <b> <c> }" =>
          [:base, RDF::URI("foo/"),
            [:bgp, [:triple, RDF::URI("foo/a"), RDF::URI("foo/b"), RDF::URI("foo/c")]]],
        "PREFIX : <http://example.com/> SELECT * WHERE { :a :b :c }" =>
          [:prefix, [[:":", RDF::URI("http://example.com/")]],
            [:bgp, [:triple, RDF::URI("http://example.com/a"), RDF::URI("http://example.com/b"), RDF::URI("http://example.com/c")]]],
        "PREFIX : <foo#> PREFIX bar: <bar#> SELECT * WHERE { :a :b bar:c }" =>
          [:prefix, [[:":", RDF::URI("foo#")], [:"bar:", RDF::URI("bar#")]],
            [:bgp, [:triple, RDF::URI("foo#a"), RDF::URI("foo#b"), RDF::URI("bar#c")]]],
        "BASE <http://baz/> PREFIX : <http://foo#> PREFIX bar: <http://bar#> SELECT * WHERE { <a> :b bar:c }" =>
          [:base, RDF::URI("http://baz/"), [:prefix, [[:":", RDF::URI("http://foo#")], [:"bar:", RDF::URI("http://bar#")]],
            [:bgp, [:triple, RDF::URI("http://baz/a"), RDF::URI("http://foo#b"), RDF::URI("http://bar#c")]]]],
      }.each_pair do |input, result|
        given_it_generates(production, input, result)
      end

      TRIPLES.each_pair do |input, result|
        given_it_generates(production, "SELECT * WHERE {#{input}}", ([:bgp] + result),
          :prefixes => {nil => "http://example.com/", :rdf => RDF.to_uri.to_s},
          :base_uri => RDF::URI("http://example.org/"),
          :anon_base => "gen0000")
      end
    end
  end

  describe "when matching the [2] Prologue production rule" do
    with_production(:Prologue) do |production|
      it "sets base_uri to <http://example.org> given 'BASE <http://example.org/>'" do
        p = parser.call(%q(BASE <http://example.org/>))
        p.parse(production)
        p.base_uri.should == RDF::URI('http://example.org/')
      end

      given_it_generates(production, %q(BASE <http://example.org/>), [:BaseDecl, [RDF::URI("http://example.org/")]])

      it "sets prefix : to 'foobar' given 'PREFIX : <foobar>'" do
        p = parser.call(%q(PREFIX : <foobar>))
        p.parse(production)
        p.prefix(nil).should == 'foobar'
        p.prefixes[nil].should == 'foobar'
      end

      given_it_generates(production, %q(PREFIX : <foobar>), [:PrefixDecl, [[:":", RDF::URI("foobar")]]], :resolve_uris => false)

      it "sets prefix foo: to 'bar' given 'PREFIX foo: <bar>'" do
        p = parser.call(%q(PREFIX foo: <bar>))
        p.parse(production)
        p.prefix(:foo).should == 'bar'
        p.prefix("foo").should == 'bar'
        p.prefixes[:foo].should == 'bar'
      end

      given_it_generates(production, %q(PREFIX foo: <bar>), [:PrefixDecl, [[:"foo:", RDF::URI("bar")]]], :resolve_uris => false)

      given_it_generates(production, %q(PREFIX : <foobar> PREFIX foo: <bar>),
        [:PrefixDecl, [
          [:":", RDF::URI("foobar")],
          [:"foo:", RDF::URI("bar")]]], :resolve_uris => false);
    end
  end

  # [5]     SelectQuery               ::=       'SELECT' ( 'DISTINCT' | 'REDUCED' )? ( Var+ | '*' ) DatasetClause* WhereClause SolutionModifier
  describe "when matching the [5] SelectQuery production rule" do
    with_production(:SelectQuery) do |production|
      it_rejects_empty_input_using production

      describe "SELECT * WHERE {...}" do
        TRIPLES.each_pair do |input, result|
          given_it_generates(production, "SELECT * WHERE {#{input}}", ([:bgp] + result),
            :prefixes => {nil => "http://example.com/", :rdf => RDF.to_uri.to_s},
            :base_uri => RDF::URI("http://example.org/"),
            :anon_base => "gen0000")
        end
      end
    end
  end

  # [6]     ConstructQuery            ::=       'CONSTRUCT' ConstructTemplate DatasetClause* WhereClause SolutionModifier
  describe "when matching the [6] ConstructQuery production rule" do
    with_production(:ConstructQuery) do |production|
      it_rejects_empty_input_using production
      
      query = %(
        PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> 
        PREFIX  foaf:       <http://xmlns.com/foaf/0.1/>

        CONSTRUCT { ?s foaf:name ?o . }
        WHERE {
          ?s foaf:name ?o .
        }
      )
      result = %(
        (prefix ((rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>)
                 (foaf: <http://xmlns.com/foaf/0.1/>))
          (project (?s ?o)
            (bgp (triple ?s foaf:name ?o))))
      )
    end
  end

  describe "when matching the [7] DescribeQuery production rule" do
    with_production(:DescribeQuery) do |production|
      it_rejects_empty_input_using production
      pending("TODO")
    end
  end

  describe "when matching the [8] AskQuery production rule" do
    with_production(:AskQuery) do |production|
      it_rejects_empty_input_using production

      it "recognizes a DatasetClause nonterminal" do
        parser(production).call(%q(ASK FROM <http://example.org/>)) #.should == [:prologue, [:base, RDF::URI('http://example.org/')]] # FIXME
      end

      it "recognizes a WhereClause nonterminal" do
        pending("TODO")
      end
    end
  end

  describe "when matching the [9] DatasetClause production rule" do
    with_production(:DatasetClause) do |production|
      it_rejects_empty_input_using production
      it_does_not_generate_using(production, %q(FROM <http://example.org/foaf/aliceFoaf>))
      it_does_not_generate_using(production, %q(FROM NAMED <http://example.org/foaf/aliceFoaf>))
    end
  end

  # No specs for the following, as nothing is produced in SSE.
  #   [10] DefaultGraphClause
  #   [11] NamedGraphClause
  #   [12] SourceSelector
  describe "when matching the [13] WhereClause production rule" do
    with_production(:WhereClause) do |production|
      it_rejects_empty_input_using production

      TRIPLES.each_pair do |input, result|
        given_it_generates(production, "WHERE {#{input}}", ([:bgp] + result),
          :prefixes => {nil => "http://example.com/", :rdf => RDF.to_uri.to_s},
          :base_uri => RDF::URI("http://example.org/"),
          :anon_base => "gen0000")
      end
    end
  end

  # [14]    SolutionModifier          ::=       OrderClause? LimitOffsetClauses?
  describe "when matching the [14] SolutionModifier production rule" do
    with_production(:SolutionModifier) do |production|
      it_rejects_empty_input_using production

      given_it_generates(production, "LIMIT 1", %q((slice _ 1)))
      given_it_generates(production, "OFFSET 1", %q((slice 1 _)))
      given_it_generates(production, "LIMIT 1 OFFSET 2", %q((slice 2 1)))
      given_it_generates(production, "OFFSET 2 LIMIT 1", %q((slice 2 1)))

      given_it_generates(production, "ORDER BY ASC (1)", %q((order ((asc 1)))))
      given_it_generates(production, "ORDER BY DESC (?a)", %q((order ((desc ?a)))))
      given_it_generates(production, "ORDER BY ?a ASC (1) isURI(<b>)", %q((order ?a ((asc 1)) isURI (<b>))))
      
      # XXX Can't test both together, as they are handled individually in [5] SelectQuery
    end
  end

  # [15]    LimitOffsetClauses        ::=       ( LimitClause OffsetClause? | OffsetClause LimitClause? )
  describe "when matching the [15] LimitOffsetClauses production rule" do
    with_production(:LimitOffsetClauses) do |production|
      given_it_generates(production, "LIMIT 1", %q((slice _ 1)))
      given_it_generates(production, "OFFSET 1", %q((slice 1 _)))
      given_it_generates(production, "LIMIT 1 OFFSET 2", %q((slice 2 1)))
      given_it_generates(production, "OFFSET 2 LIMIT 1", %q((slice 2 1)))
    end
  end

  # [16]    OrderClause               ::=       'ORDER' 'BY' OrderCondition+
  describe "when matching the [16] OrderClause production rule" do
    with_production(:OrderClause) do |production|
      given_it_generates(production, "ORDER BY ASC (1)", %q((order ((asc 1)))))
      given_it_generates(production, "ORDER BY DESC (?a)", %q((order ((desc ?a)))))
      given_it_generates(production, "ORDER BY ?a ASC (1) isURI(<b>)", %q((order ?a ((asc 1)) isURI (<b>))))
    end
  end

  # [17]    OrderCondition            ::=       ( ( 'ASC' | 'DESC' ) BrackettedExpression ) | ( Constraint | Var )
  describe "when matching the [17] OrderCondition production rule" do
    with_production(:OrderCondition) do |production|
      given_it_generates(production, "ASC (1)", [:order, [[:asc, RDF::Literal(1)]]])
      given_it_generates(production, "DESC (?a)", [:order, [[:desc, RDF::Query::Variable.new("a")]]])

      # Constraint
      it_recognizes_bracketted_expression_using production
      it_recognizes_built_in_call_using production
      it_recognizes_function_using production

      it_recognizes_var_using production
    end
  end

  describe "when matching the [18] LimitClause production rule" do
    with_production(:LimitClause) do |production|
      it "recognizes LIMIT clauses" do
        parser(production).call(%q(LIMIT 10)).should == [:limit, RDF::Literal.new(10)]
      end
    end
  end

  describe "when matching the [19] OffsetClause production rule" do
    with_production(:OffsetClause) do |production|
      it "recognizes OFFSET clauses" do
        parser(production).call(%q(OFFSET 10)).should == [:offset, 10]
      end
    end
  end

  # [20]    GroupGraphPattern         ::=       '{' TriplesBlock? ( ( GraphPatternNotTriples | Filter ) '.'? TriplesBlock? )* '}'
  describe "when matching the [20] GroupGraphPattern production rule" do
    with_production(:GroupGraphPattern) do |production|
      {
        # From data/Optional/q-opt-1.rq
        "{<a><b><c> OPTIONAL {<d><e><f>}}" =>
          %q((leftjoin
            (bgp (triple <a> <b> <c>))
            (bgp (triple <d> <e> <f>)))),
        "{OPTIONAL {<d><e><f>}}" =>
          %q((leftjoin
            (table unit)
            (bgp (triple <d> <e> <f>)))),     # XXX Really?
        # From data/Optional/q-opt-2.rq
        "{<a><b><c> OPTIONAL {<d><e><f>} OPTIONAL {<g><h><i>}}" =>
          %q((leftjoin
              (leftjoin
                (bgp (triple <a> <b> <c>))
                (bgp (triple <d> <e> <f>)))
              (bgp (triple <g> <h> <i>)))),
        "{<a><b><c> {:x :y :z} {<d><e><f>}}" =>
          %q((join
              (join
                (bgp (triple <a> <b> <c>))
                (bgp (triple :x :y :z)))
              (bgp (triple <d> <e> <f>)))),
        "{<a><b><c> {:x :y :z} <d><e><f>}" =>
          %q((join
              (join
                (bgp (triple <a> <b> <c>))
                (bgp (triple :x :y :z)))
              (bgp (triple <d> <e> <f>)))),
        # From data/extracted-examples/query-4.1-q1.rq
       "{{:x :y :z} {<d><e><f>}}" =>
          %q((join
              (bgp (triple :x :y :z))
              (bgp (triple <d> <e> <f>)))),
        "{<a><b><c> {:x :y :z} UNION {<d><e><f>}}" =>
          %q((join
              (bgp (triple <a> <b> <c>))
              (union
                (bgp (triple :x :y :z))
                (bgp (triple <d> <e> <f>))))),
        # From data/Optional/q-opt-3.rq
        "{{:x :y :z} UNION {<d><e><f>}}" =>
          %q((union
              (bgp (triple :x :y :z))
              (bgp (triple <d> <e> <f>)))),
        "{GRAPH ?src { :x :y :z}}" => %q((graph ?src (bgp (triple :x :y :z)))),
        "{<a><b><c> GRAPH <graph> {<d><e><f>}}" =>
          %q((join
              (bgp (triple <a> <b> <c>))
              (graph <graph>
                (bgp (triple <d> <e> <f>))))),
        "{ ?a :b ?c .  OPTIONAL { ?c :d ?e } . FILTER (! bound(?e))}" =>
          %q((filter (! (bound ?e))
              (leftjoin
                (bgp (triple ?a :b ?c))
                (bgp (triple ?c :d ?e))))),
      }.each_pair do |input, result|
        given_it_generates(production, input, result, :resolve_uris => false)
      end
    end
  end

  # [21]    TriplesBlock              ::=       TriplesSameSubject ( '.' TriplesBlock? )?
  describe "when matching the [21] TriplesBlock production rule" do
    with_production(:TriplesBlock) do |production|
      TRIPLES.each_pair do |input, result|
        given_it_generates(production, input, ([:bgp] + result),
          :prefixes => {nil => "http://example.com/", :rdf => RDF.to_uri.to_s},
          :base_uri => RDF::URI("http://example.org/"),
          :anon_base => "gen0000")
      end
    end
  end

  # [22] GraphPatternNotTriples ::= OptionalGraphPattern | GroupOrUnionGraphPattern | GraphGraphPattern
  describe "when matching the [22] GraphPatternNotTriples production rule" do
    with_production(:GraphPatternNotTriples) do |production|
      it_rejects_empty_input_using production
      {
        # OptionalGraphPattern
        "OPTIONAL {<d><e><f>}" => %q((leftjoin (bgp (triple <d> <e> <f>)))),

        # GroupOrUnionGraphPattern
        "{:x :y :z}" => %q((bgp (triple :x :y :z))),
        "{:x :y :z} UNION {<d><e><f>}" =>
          %q((union
              (bgp (triple :x :y :z))
              (bgp (triple <d> <e> <f>)))),
        "{:x :y :z} UNION {<d><e><f>} UNION {?a ?b ?c}" =>
          %q((union
              (union
                (bgp (triple :x :y :z))
                (bgp (triple <d> <e> <f>)))
              (bgp (triple ?a ?b ?c)))),

        # GraphGraphPattern
        "GRAPH ?a {<d><e><f>}" => %q((graph ?a (bgp (triple <d> <e> <f>)))),
        "GRAPH :a {<d><e><f>}" => %q((graph :a (bgp (triple <d> <e> <f>)))),
        "GRAPH <a> {<d><e><f>}" => %q((graph <a> (bgp (triple <d> <e> <f>)))),
      }.each_pair do |input, result|
        given_it_generates(production, input, result, :resolve_uris => false)
      end
    end
  end

  # [23]    OptionalGraphPattern      ::=       'OPTIONAL' GroupGraphPattern
  describe "when matching the [23] OptionalGraphPattern production rule" do
    with_production(:OptionalGraphPattern) do |production|
      it_rejects_empty_input_using production
      {
        "OPTIONAL {<d><e><f>}" => %q((leftjoin (bgp (triple <d> <e> <f>))))
      }.each_pair do |input, result|
        given_it_generates(production, input, result)
      end
    end
  end

  # [24]    GraphGraphPattern         ::=       'GRAPH' VarOrIRIref GroupGraphPattern
  describe "when matching the [24] GraphGraphPattern production rule" do
    with_production(:GraphGraphPattern) do |production|
      it_rejects_empty_input_using production

      {
        "GRAPH ?a {<d><e><f>}" => %q((graph ?a (bgp (triple <d> <e> <f>)))),
        "GRAPH :a {<d><e><f>}" => %q((graph :a (bgp (triple <d> <e> <f>)))),
        "GRAPH <a> {<d><e><f>}" => %q((graph <a> (bgp (triple <d> <e> <f>)))),
      }.each_pair do |input, result|
        given_it_generates(production, input, result, :resolve_uris => false)
      end
    end
  end

  # [25]    GroupOrUnionGraphPattern  ::=       GroupGraphPattern ( 'UNION' GroupGraphPattern )*
  describe "when matching the [25] GroupOrUnionGraphPattern production rule" do
    with_production(:GroupOrUnionGraphPattern) do |production|
      it_rejects_empty_input_using production

      {
        # From data/Optional/q-opt-3.rq
        "{:x :y :z}" => %q((bgp (triple :x :y :z))),
        "{:x :y :z} UNION {<d><e><f>}" =>
          %q((union
              (bgp (triple :x :y :z))
              (bgp (triple <d> <e> <f>)))),
        "{:x :y :z} UNION {<d><e><f>} UNION {?a ?b ?c}" =>
          %q((union
              (union
                (bgp (triple :x :y :z))
                (bgp (triple <d> <e> <f>)))
              (bgp (triple ?a ?b ?c)))),
      }.each_pair do |input, result|
        given_it_generates(production, input, result, :resolve_uris => false)
      end
    end
  end

  # [26]    Filter                    ::=       'FILTER' Constraint
  describe "when matching the [26] Filter production rule" do
    with_production(:Filter) do |production|
      given_it_generates(production, %(FILTER (1)), %q((filter 1)))
      given_it_generates(production, %(FILTER ((1))), %q((filter 1)))
      given_it_generates(production, %(FILTER ("foo")), %q((filter "foo")))
      #given_it_generates(production, %(FILTER STR ("foo")), %q((filter STR ("foo"))))
      #given_it_generates(production, %(FILTER LANGMATCHES ("foo", "bar")), %q((filter LANGMATCHES ("foo", "bar"))))
      #given_it_generates(production, %(FILTER isIRI ("foo")), %q((filter isIRI ("foo"))))
      #given_it_generates(production, %(FILTER REGEX ("foo", "bar")), %q((filter REGEX ("foo", "bar"))))
      #given_it_generates(production, %(FILTER (fun "arg")), %q((filter (fun "arg"))))


      given_it_generates(production, %(FILTER STR ("foo")), %q((filter (str "foo"))))

      given_it_generates(production, %(FILTER BOUND ?e), %q((filter (bound ?e))))
      given_it_generates(production, %(FILTER (BOUND ?e)), %q((filter (bound ?e))))
      given_it_generates(production, %(FILTER (! BOUND ?e)), %q((filter (! (bound ?e)))))
    end
  end

  # [27] Constraint ::=  BrackettedExpression | BuiltInCall | FunctionCall
  describe "when matching the [27] Constraint production rule" do
    with_production(:Constraint) do |production|
      it_rejects_empty_input_using production
      it_recognizes_bracketted_expression_using production
      it_recognizes_built_in_call_using production
      it_recognizes_function_using production
    end
  end

  describe "when matching the [28] FunctionCall production rule" do
    with_production(:FunctionCall) do |production|
      it_recognizes_function_using production
    end
  end

  describe "when matching the [29] ArgList production rule" do
    with_production(:ArgList) do |production|
      it_recognizes_nil_using production

      given_it_generates(production, %q(()), [:ArgList, RDF["nil"]])
      given_it_generates(production, %q(("foo")), [:ArgList, RDF::Literal("foo")])
      given_it_generates(production, %q(("foo", "bar")), [:ArgList, RDF::Literal("foo"), RDF::Literal("bar")])
    end
  end

  describe "when matching the [30] ConstructTemplate production rule" do
    with_production(:ConstructTemplate) do |production|
      TRIPLES.each_pair do |input, result|
        given_it_generates(production, "{#{input}}", ([:ConstructTriples] + result),
          :prefixes => {nil => "http://example.com/", :rdf => RDF.to_uri.to_s},
          :base_uri => RDF::URI("http://example.org/"),
          :anon_base => "gen0000")
      end
    end
  end

  describe "when matching the [31] ConstructTriples production rule" do
    with_production(:ConstructTriples) do |production|
      TRIPLES.each_pair do |input, result|
        given_it_generates(production, input, ([:ConstructTriples] + result),
          :prefixes => {nil => "http://example.com/", :rdf => RDF.to_uri.to_s},
          :base_uri => RDF::URI("http://example.org/"),
          :anon_base => "gen0000")
      end
    end
  end

  # Productions that can be tested individually
  describe "individual nonterminal productions" do
    describe "when matching the [41] GraphNode production rule" do
      with_production(:GraphNode) do |production|
        it_recognizes_graph_node_using(production)
      end
    end

    describe "when matching the [42] VarOrTerm production rule" do
      with_production(:VarOrTerm) do |production|
        it_recognizes_var_or_term_using production
      end
    end

    describe "when matching the [43] VarOrIRIref production rule" do
      with_production(:VarOrIRIref) do |production|
        it_recognizes_var_or_iriref_using production
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
        it_recognizes_graph_term_using(production)
      end
    end

    describe "when matching the [46] Expression production rule" do
      with_production(:Expression) do |production|
        it_recognizes_expression_using production
      end
    end

    describe "when matching the [47] ConditionalOrExpression production rule" do
      with_production(:ConditionalOrExpression) do |production|
        it_recognizes_conditional_or_expression_using production
      end
    end

    describe "when matching the [48] ConditionalAndExpression production rule" do
      with_production(:ConditionalAndExpression) do |production|
        it_recognizes_conditional_and_expression_using production
      end
    end

    describe "when matching the [49] ValueLogical production rule" do
      with_production(:ValueLogical) do |production|
        it_recognizes_value_logical_using production
      end
    end

    describe "when matching the [50] RelationalExpression production rule" do
      with_production(:RelationalExpression) do |production|
        it_recognizes_relational_expression_using production
      end
    end

    describe "when matching the [51] NumericExpression production rule" do
      with_production(:NumericExpression) do |production|
        it_recognizes_numeric_expression_using production
      end
    end

    describe "when matching the [52] AdditiveExpression production rule" do
      with_production(:AdditiveExpression) do |production|
        it_recognizes_additive_expression_using production
      end
    end

    describe "when matching the [53] MultiplicativeExpression production rule" do
      with_production(:MultiplicativeExpression) do |production|
        it_recognizes_multiplicative_expression_using production
      end
    end

    describe "when matching the [54] UnaryExpression production rule" do
      with_production(:UnaryExpression) do |production|
        it_recognizes_unary_expression_using production
      end
    end

    describe "when matching the [55] PrimaryExpression production rule" do
      # [55] PrimaryExpression ::= BrackettedExpression | BuiltInCall | IRIrefOrFunction | RDFLiteral | NumericLiteral | BooleanLiteral | Var
      with_production(:PrimaryExpression) do |production|
        it_recognizes_primary_expression_using production
      end
    end

    describe "when matching the [56] BrackettedExpression production rule" do
      with_production(:BrackettedExpression) do |production|
        it_recognizes_bracketted_expression_using production
      end
    end

    describe "when matching the [57] BuiltInCall production rule", :focus => true do
      with_production(:BuiltInCall) do |production|
        it_recognizes_built_in_call_using production
      end
    end

    describe "when matching the [58] RegexExpression production rule" do
      with_production(:RegexExpression) do |production|
        it_recognizes_regex_expression_using production
      end
    end

    describe "when matching the [59] IRIrefOrFunction production rule" do
      with_production(:IRIrefOrFunction) do |production|
        it_recognizes_iriref_or_function_using production
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
        it_recognizes_numeric_literal_using production

        it "recognizes the NumericLiteralUnsigned nonterminal" do
          parser(production).call(%q(123)).last.should     == RDF::Literal::Integer.new(123)
          parser(production).call(%q(3.1415)).last.should  == RDF::Literal::Decimal.new(3.1415)
          parser(production).call(%q(1e6)).last.should     == RDF::Literal::Double.new(1e6)
        end

        it "recognizes the NumericLiteralPositive nonterminal" do
          parser(production).call(%q(+123)).last.should    == RDF::Literal::Integer.new(123)
          parser(production).call(%q(+3.1415)).last.should == RDF::Literal::Decimal.new(3.1415)
          parser(production).call(%q(+1e6)).last.should    == RDF::Literal::Double.new(1e6)
        end

        it "recognizes the NumericLiteralNegative nonterminal" do
          parser(production).call(%q(-123)).last.should    == RDF::Literal::Integer.new(-123)
          parser(production).call(%q(-3.1415)).last.should == RDF::Literal::Decimal.new(-3.1415)
          parser(production).call(%q(-1e6)).last.should    == RDF::Literal::Double.new(-1e6)
        end
      end
    end

    describe "when matching the [62] NumericLiteralUnsigned production rule" do
      with_production(:NumericLiteralUnsigned) do |production|
        it_rejects_empty_input_using production

        it "recognizes the INTEGER terminal" do
          %w(1 2 3 42 123).each do |input|
            parser(production).call(input).last.should == RDF::Literal::Integer.new(input.to_i)
          end
        end

        it "recognizes the DECIMAL terminal" do
          %w(1. 3.1415 .123).each do |input|
            parser(production).call(input).last.should == RDF::Literal::Decimal.new(input.to_f)
          end
        end

        it "recognizes the DOUBLE terminal" do
          %w(1e2 3.1415e2 .123e2).each do |input|
            parser(production).call(input).last.should == RDF::Literal::Double.new(input.to_f)
          end
        end
      end
    end

    describe "when matching the [63] NumericLiteralPositive production rule" do
      with_production(:NumericLiteralPositive) do |production|
        it_rejects_empty_input_using production

        it "recognizes the INTEGER_POSITIVE terminal" do
          %w(+1 +2 +3 +42 +123).each do |input|
            parser(production).call(input).last.should == RDF::Literal::Integer.new(input.to_i)
          end
        end

        it "recognizes the DECIMAL_POSITIVE terminal" do
          %w(+1. +3.1415 +.123).each do |input|
            parser(production).call(input).last.should == RDF::Literal::Decimal.new(input.to_f)
          end
        end

        it "recognizes the DOUBLE_POSITIVE terminal" do
          %w(+1e2 +3.1415e2 +.123e2).each do |input|
            parser(production).call(input).last.should == RDF::Literal::Double.new(input.to_f)
          end
        end
      end
    end

    describe "when matching the [64] NumericLiteralNegative production rule" do
      with_production(:NumericLiteralNegative) do |production|
        it "recognizes the INTEGER_NEGATIVE terminal" do
          %w(-1 -2 -3 -42 -123).each do |input|
            parser(production).call(input).last.should == RDF::Literal::Integer.new(input.to_i)
          end
        end

        it "recognizes the DECIMAL_NEGATIVE terminal" do
          %w(-1. -3.1415 -.123).each do |input|
            parser(production).call(input).last.should == RDF::Literal::Decimal.new(input.to_f)
          end
        end

        it "recognizes the DOUBLE_NEGATIVE terminal" do
          %w(-1e2 -3.1415e2 -.123e2).each do |input|
            parser(production).call(input).last.should == RDF::Literal::Double.new(input.to_f)
          end
        end
      end
    end
  end
  
  # Individual terminal productions
  describe "individual terminal productions" do
    describe "when matching the [67] IRIref production rule" do
      with_production(:IRIref) do |production|
        it "recognizes the IRI_REF terminal" do
          %w(<> <foobar> <http://example.org/foobar>).each do |input|
            parser(production).call(input).last.should_not == false # TODO
          end
        end

        it "recognizes the PrefixedName nonterminal" do
          %w(: foo: :bar foo:bar).each do |input|
            parser(production).call(input).last.should_not == false # TODO
          end
        end
      end
    end

    describe "when matching the [68] PrefixedName production rule" do
      with_production(:PrefixedName) do |production|
        inputs = {
          :PNAME_LN => {
            ":bar"    => RDF::URI("http://example.com/bar"),
            "foo:bar" => RDF.bar
          },
          :PNAME_NS => {
            ":"    => RDF::URI("http://example.com/"),
            "foo:" => RDF.to_uri
          }
        }
        inputs.each do |terminal, examples|
          it "recognizes the #{terminal} terminal" do
            examples.each_pair do |input, result|
              p = parser(production, :prefixes => {nil => "http://example.com/", :foo => RDF.to_uri.to_s})
              p.call(input).last.should == result
            end
          end
        end
      end
    end

    describe "when matching the [69] BlankNode production rule" do
      with_production(:BlankNode) do |production|
        inputs = {
          :BLANK_NODE_LABEL => %q(_:foobar),
          :ANON             => %q([]),
        }
        inputs.each do |terminal, input|
          it "recognizes the #{terminal} terminal" do
            if output = parser(production).call(input)
              output.last.should be_an(RDF::Node)
            end
          end
        end
      end
    end

    # NOTE: production rules [70..100] are internal to the lexer
  end

  describe "when parsing ASK queries" do
    pending("TODO")
  end

  describe "when parsing SELECT queries" do
    pending("TODO")
  end

  describe "when parsing CONSTRUCT queries" do
    pending("TODO")
  end

  describe "when parsing DESCRIBE queries" do
    pending("TODO")
  end

  def parser(production = nil, options = {})
    Proc.new do |query|
      parser = SPARQL::Grammar::Parser.new(query, {:resolve_uris => true}.merge(options))
      production ? parser.parse(SPARQL::Grammar::SPARQL_GRAMMAR[production]) : parser
    end
  end
end
