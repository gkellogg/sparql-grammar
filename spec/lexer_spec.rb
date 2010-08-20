require File.join(File.dirname(__FILE__), 'spec_helper')

describe SPARQL::Grammar::Lexer do
  describe "when tokenizing Unicode strings" do
    it "unescapes \\uXXXX codepoint escape sequences" do
      inputs = {
        %q(\u0020)       => %q( ),
        %q(<ab\u00E9xy>) => %Q(<ab\xC3\xA9xy>),
        %q(\u03B1:a)     => %Q(\xCE\xB1:a),
        %q(a\u003Ab)     => %Q(a\x3Ab),
      }
      inputs.each do |input, output|
        output.force_encoding(Encoding::UTF_8) if output.respond_to?(:force_encoding) # Ruby 1.9+
        unescape(input).should == output
      end
    end

    it "unescapes \\UXXXXXXXX codepoint escape sequences" do
      inputs = {
        %q(\U00000020)   => %q( ),
        %q(\U00010000)   => %Q(\xF0\x90\x80\x80),
        %q(\U000EFFFF)   => %Q(\xF3\xAF\xBF\xBF),
      }
      inputs.each do |input, output|
        output.force_encoding(Encoding::UTF_8) if output.respond_to?(:force_encoding) # Ruby 1.9+
        unescape(input).should == output
      end
    end

    it "matches the PN_CHARS_BASE production correctly" do
      strings = [
        ["\xC3\x80",         "\xC3\x96"],         # \u00C0-\u00D6
        ["\xC3\x98",         "\xC3\xB6"],         # \u00D8-\u00F6
        ["\xC3\xB8",         "\xCB\xBF"],         # \u00F8-\u02FF
        ["\xCD\xB0",         "\xCD\xBD"],         # \u0370-\u037D
        ["\xCD\xBF",         "\xE1\xBF\xBF"],     # \u037F-\u1FFF
        ["\xE2\x80\x8C",     "\xE2\x80\x8D"],     # \u200C-\u200D
        ["\xE2\x81\xB0",     "\xE2\x86\x8F"],     # \u2070-\u218F
        ["\xE2\xB0\x80",     "\xE2\xBF\xAF"],     # \u2C00-\u2FEF
        ["\xE3\x80\x81",     "\xED\x9F\xBF"],     # \u3001-\uD7FF
        ["\xEF\xA4\x80",     "\xEF\xB7\x8F"],     # \uF900-\uFDCF
        ["\xEF\xB7\xB0",     "\xEF\xBF\xBD"],     # \uFDF0-\uFFFD
        ["\xF0\x90\x80\x80", "\xF3\xAF\xBF\xBF"], # \u{10000}-\u{EFFFF}]
      ]
      strings.each do |range|
        range.each do |string|
          string.force_encoding(Encoding::UTF_8) if string.respond_to?(:force_encoding) # Ruby 1.9+
          string.should match(SPARQL::Grammar::Lexer::PN_CHARS_BASE)
        end
      end
    end
  end

  describe "when tokenizing boolean literals" do
    it "tokenizes the true literal" do
      tokenize(%q(true)) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should  == :BooleanLiteral
        tokens.first.value.should == true
      end
    end

    it "tokenizes the false literal" do
      tokenize(%q(false)) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should  == :BooleanLiteral
        tokens.first.value.should == false
      end
    end

    it "tokenizes the nil literal" do
      tokenize(%q(()), %q(( )), %q((  ))) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should  == :NIL
        tokens.first.value.should == RDF.nil
      end
    end
  end

  describe "when tokenizing numeric literals" do
    it "tokenizes unsigned integer literals" do
      tokenize(%q(42)) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should  == :NumericLiteral
        tokens.first.value.should == 42
      end
    end

    it "tokenizes positive integer literals" do
      tokenize(%q(+42)) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should  == :NumericLiteral
        tokens.first.value.should == 42
      end
    end

    it "tokenizes negative integer literals" do
      tokenize(%q(-42)) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should  == :NumericLiteral
        tokens.first.value.should == -42
      end
    end

    it "tokenizes unsigned decimal literals" do
      tokenize(%q(3.1415)) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should  == :NumericLiteral
        tokens.first.value.should == 3.1415
      end
    end

    it "tokenizes positive decimal literals" do
      tokenize(%q(+3.1415)) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should  == :NumericLiteral
        tokens.first.value.should == 3.1415
      end
    end

    it "tokenizes negative decimal literals" do
      tokenize(%q(-3.1415)) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should  == :NumericLiteral
        tokens.first.value.should == -3.1415
      end
    end

    it "tokenizes unsigned double literals" do
      tokenize(%q(1e6)) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should  == :NumericLiteral
        tokens.first.value.should == 1e6
      end
    end

    it "tokenizes positive double literals" do
      tokenize(%q(+1e6)) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should  == :NumericLiteral
        tokens.first.value.should == 1e6
      end
    end

    it "tokenizes negative double literals" do
      tokenize(%q(-1e6)) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should  == :NumericLiteral
        tokens.first.value.should == -1e6
      end
    end
  end

  describe "when tokenizing string literals" do
    it "tokenizes single-quoted string literals" do
      tokenize(%q('Hello, world!')) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should  == :String
        tokens.first.value.should == 'Hello, world!'
      end
    end

    it "tokenizes double-quoted string literals" do
      tokenize(%q("Hello, world!")) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should  == :String
        tokens.first.value.should == "Hello, world!"
      end
    end

    it "tokenizes long single-quoted string literals" do
      tokenize(%q('''Hello, world!''')) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should  == :String
        tokens.first.value.should == 'Hello, world!'
      end
    end

    it "tokenizes long double-quoted string literals" do
      tokenize(%q("""Hello, world!""")) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should  == :String
        tokens.first.value.should == 'Hello, world!'
      end
    end
  end

  describe "when tokenizing blank nodes" do
    it "tokenizes blank node labels" do
      tokenize(%q(_:foobar)) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should  == :BlankNode
        tokens.first.value.should == RDF::Node(:foobar)
      end
    end

    it "tokenizes anonymous blank nodes" do
      tokenize(%q([]), %q([ ])) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should  == :BlankNode
        tokens.first.value.should be_an(RDF::Node)
      end
    end
  end

  describe "when tokenizing variables" do
    it "tokenizes variables prefixed with '?'" do
      tokenize(%q(?foo)) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should  == :Var
        tokens.first.value.should == :foo
      end
    end

    it "tokenizes variables prefixed with '$'" do
      tokenize(%q($foo)) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should  == :Var
        tokens.first.value.should == :foo
      end
    end
  end

  describe "when tokenizing IRI references" do
    it "tokenizes absolute IRI references" do
      tokenize(%q(<http://example.org/foobar>)) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should  == :IRI_REF
        tokens.first.value.should == RDF::URI('http://example.org/foobar')
      end
    end

    it "tokenizes relative IRI references" do
      tokenize(%q(<foobar>)) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should  == :IRI_REF
        tokens.first.value.should == RDF::URI('foobar')
      end
    end
  end

  describe "when tokenizing prefixes" do
    it "tokenizes the empty prefix" do
      tokenize(%q(:)) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should  == :PNAME_NS
        tokens.first.value.should == nil
      end
    end

    it "tokenizes labelled prefixes" do
      tokenize(%q(dc:)) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should  == :PNAME_NS
        tokens.first.value.should == :dc
      end
    end
  end

  describe "when tokenizing prefixed names" do
    it "tokenizes prefixed names" do
      tokenize(%q(dc:title)) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should == :PNAME_LN
        tokens.first.value.should be_an(Array)
        tokens.first.value.should have(2).elements
        tokens.first.value[0].should == :dc
        tokens.first.value[1].should == :title
      end
    end

    it "tokenizes prefixed names having an empty prefix label" do
      tokenize(%q(:title)) do |tokens|
        tokens.should have(1).element
        tokens.first.type.should == :PNAME_LN
        tokens.first.value.should be_an(Array)
        tokens.first.value.should have(2).elements
        tokens.first.value[0].should == nil
        tokens.first.value[1].should == :title
      end
    end
  end

  describe "when tokenizing RDF literals" do
    it "tokenizes language-tagged literals" do
      tokenize(%q("Hello, world!"@en)) do |tokens|
        tokens.should have(2).elements
        tokens[0].type.should  == :String
        tokens[0].value.should == 'Hello, world!'
        tokens[1].type.should  == :LANGTAG
        tokens[1].value.should == :en
      end
      tokenize(%q("Hello, world!"@en-US)) do |tokens|
        tokens.should have(2).elements
        tokens[0].type.should  == :String
        tokens[0].value.should == "Hello, world!"
        tokens[1].type.should  == :LANGTAG
        tokens[1].value.should == :'en-US'
      end
    end

    it "tokenizes datatyped literals" do
      inputs = [%q('3.1415'^^<http://www.w3.org/2001/XMLSchema#double>),
                %q("3.1415"^^<http://www.w3.org/2001/XMLSchema#double>)]
      tokenize(*inputs) do |tokens|
        tokens.should have(3).elements
        tokens[0].type.should  == :String
        tokens[0].value.should == '3.1415'
        tokens[1].type.should  == nil
        tokens[1].value.should == '^^'
        tokens[2].type.should  == :IRI_REF
        tokens[2].value.should == RDF::XSD.double
      end
    end
  end

  describe "when tokenizing SPARQL delimiters" do
    %w|^^ { } ( ) [ ] , ; .|.each do |delimiter|
      it "tokenizes the #{delimiter.inspect} delimiter" do
        tokenize(delimiter) do |tokens|
          tokens.should have(1).element
          tokens.first.type.should  == nil
          tokens.first.value.should == delimiter
        end
      end
    end
  end

  describe "when tokenizing SPARQL operators" do
    %w(a || && != <= >= ! = < > + - * /).each do |operator|
      it "tokenizes the #{operator.inspect} operator" do
        tokenize(operator) do |tokens|
          tokens.should have(1).element
          tokens.first.type.should  == nil
          tokens.first.value.should == operator.to_sym
        end
      end
    end
  end

  describe "when tokenizing declaration keywords" do
    %w(BASE PREFIX).each do |keyword|
      it "tokenizes the #{keyword} keyword" do
        tokenize(keyword.upcase, keyword.downcase) do |tokens|
          tokens.should have(1).element
          tokens.first.type.should  == nil
          tokens.first.value.should == keyword.downcase.to_sym
        end
      end
    end
  end

  describe "when tokenizing query form keywords" do
    %w(SELECT CONSTRUCT DESCRIBE ASK).each do |keyword|
      it "tokenizes the #{keyword} keyword" do
        tokenize(keyword.upcase, keyword.downcase) do |tokens|
          tokens.should have(1).element
          tokens.first.type.should  == nil
          tokens.first.value.should == keyword.downcase.to_sym
        end
      end
    end
  end

  describe "when tokenizing solution modifier keywords" do
    %w(LIMIT OFFSET DISTINCT REDUCED).each do |keyword|
      it "tokenizes the #{keyword} keyword" do
        tokenize(keyword.upcase, keyword.downcase) do |tokens|
          tokens.should have(1).element
          tokens.first.type.should  == nil
          tokens.first.value.should == keyword.downcase.to_sym
        end
      end
    end
  end

  describe "when tokenizing order clause keywords" do
    %w(ORDER BY ASC DESC).each do |keyword|
      it "tokenizes the #{keyword} keyword" do
        tokenize(keyword.upcase, keyword.downcase) do |tokens|
          tokens.should have(1).element
          tokens.first.type.should  == nil
          tokens.first.value.should == keyword.downcase.to_sym
        end
      end
    end
  end

  describe "when tokenizing dataset clause keywords" do
    %w(FROM NAMED WHERE).each do |keyword|
      it "tokenizes the #{keyword} keyword" do
        tokenize(keyword.upcase, keyword.downcase) do |tokens|
          tokens.should have(1).element
          tokens.first.type.should  == nil
          tokens.first.value.should == keyword.downcase.to_sym
        end
      end
    end
  end

  describe "when tokenizing graph pattern keywords" do
    %w(GRAPH OPTIONAL UNION FILTER).each do |keyword|
      it "tokenizes the #{keyword} keyword" do
        tokenize(keyword.upcase, keyword.downcase) do |tokens|
          tokens.should have(1).element
          tokens.first.type.should  == nil
          tokens.first.value.should == keyword.downcase.to_sym
        end
      end
    end
  end

  describe "when tokenizing built-in function keywords" do
    %w(STR LANGMATCHES LANG DATATYPE BOUND sameTerm isIRI isURI isBLANK isLITERAL REGEX).each do |keyword|
      it "tokenizes the #{keyword} keyword" do
        tokenize(keyword, keyword.upcase, keyword.downcase) do |tokens|
          tokens.should have(1).element
          tokens.first.type.should  == nil
          tokens.first.value.should == keyword.downcase.to_sym
        end
      end
    end
  end

  def tokenize(*inputs, &block)
    inputs.each do |input|
      tokens = SPARQL::Grammar::Lexer.tokenize(input, options)
      tokens.should be_a(SPARQL::Grammar::Lexer)
      block.call(tokens.to_a)
    end
  end

  def unescape(input)
    result = SPARQL::Grammar::Lexer.unescape(input)
  end
end
