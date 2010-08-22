require File.join(File.dirname(__FILE__), 'spec_helper')

describe SPARQL::Grammar::Parser do
  describe "when matching the [37] Verb production rule" do
    it "recognizes the VarOrIRIref nonterminal" do
      # TODO
    end

    it "recognizes the 'a' lexeme" do
      parse(%q(a)).verb.should == RDF.type
    end
  end

  describe "when matching the [42] VarOrTerm production rule" do
    it "recognizes the Var nonterminal" do
      # TODO
    end

    it "recognizes the GraphTerm nonterminal" do
      # TODO
    end
  end

  describe "when matching the [43] VarOrIRIref production rule" do
    it "recognizes the Var nonterminal" do
      # TODO
    end

    it "recognizes the IRIref nonterminal" do
      # TODO
    end
  end

  describe "when matching the [44] Var production rule" do
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

  describe "when matching the [60] RDFLiteral production rule" do
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
    it "recognizes the ':' lexeme" do
      parse(%q(:)).pname_ns.should == nil
    end

    it "recognizes the 'foo:' lexeme" do
      parse(%q(foo:)).pname_ns.should == :foo
    end
  end

  describe "when matching the [72] PNAME_LN production rule" do
    it "recognizes the ':bar' lexeme" do
      parse(%q(:bar)).pname_ln.should == [nil, :bar]
    end

    it "recognizes the 'foo:bar' lexeme" do
      parse(%q(foo:bar)).pname_ln.should == [:foo, :bar]
    end
  end

  describe "when matching the [76] LANGTAG production rule" do
    it "recognizes the '@en' lexeme" do
      parse(%q(@en)).langtag.should == :en
    end

    it "recognizes the '@en-US' lexeme" do
      parse(%q(@en-US)).langtag.should == :'en-US'
    end
  end

  describe "when matching the [92] NIL production rule" do
    it "recognizes the '()' lexeme" do
      parse(%q(())).nil.should == RDF.nil
    end
  end

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
