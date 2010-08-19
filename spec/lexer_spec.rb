require File.join(File.dirname(__FILE__), 'spec_helper')

describe SPARQL::Grammar::Lexer do
  describe "when tokenizing Unicode query strings" do
    it "unescapes \\uXXXX codepoint escape sequences" do
      inputs = {
        %q(\u0020)       => %q( ),
        %q(<ab\u00E9xy>) => %Q(<ab\xC3\xA9xy>),
        %q(\u03B1:a)     => %Q(\xCE\xB1:a),
        %q(a\u003Ab)     => %Q(a\x3Ab),
      }
      inputs.each do |input, output|
        output.force_encoding(Encoding::UTF_8) if output.respond_to?(:force_encoding)
        unescape(input).should == output
      end
    end
    it "unescapes \\UXXXXXXXX codepoint escape sequences" do
      inputs = {
        %q(\U00000020)   => %q( ),
      }
      inputs.each do |input, output|
        output.force_encoding(Encoding::UTF_8) if output.respond_to?(:force_encoding)
        unescape(input).should == output
      end
    end
  end

  describe "when tokenizing boolean literals" do
    it "tokenizes the true literal" do
      tokenize(%q(true)).first
    end

    it "tokenizes the false literal" do
      tokenize(%q(false)).first
    end

    it "tokenizes the nil literal" do
      tokenize(%q(())).first
      tokenize(%q(( ))).first
    end
  end

  describe "when tokenizing numeric literals" do
    it "tokenizes unsigned integer literals" do
      tokenize(%q(42)).first
    end

    it "tokenizes positive integer literals" do
      tokenize(%q(+42)).first
    end

    it "tokenizes negative integer literals" do
      tokenize(%q(-42)).first
    end

    it "tokenizes unsigned decimal literals" do
      tokenize(%q(3.1415)).first
    end

    it "tokenizes positive decimal literals" do
      tokenize(%q(+3.1415)).first
    end

    it "tokenizes negative decimal literals" do
      tokenize(%q(-3.1415)).first
    end

    it "tokenizes unsigned double literals" do
      tokenize(%q(1e6)).first
    end

    it "tokenizes positive double literals" do
      tokenize(%q(+1e6)).first
    end

    it "tokenizes negative double literals" do
      tokenize(%q(-1e6)).first
    end
  end

  describe "when tokenizing string literals" do
    it "tokenizes single-quoted string literals" do
      tokenize(%q('Hello, world!')).first
    end

    it "tokenizes double-quoted string literals" do
      tokenize(%q("Hello, world!")).first
    end

    it "tokenizes long single-quoted string literals" do
      tokenize(%q('''Hello, world!''')).first
    end

    it "tokenizes long double-quoted string literals" do
      tokenize(%q("""Hello, world!""")).first
    end
  end

  describe "when tokenizing blank nodes" do
    it "tokenizes blank node labels" do
      tokenize(%q(_:foobar)).first
    end

    it "tokenizes anonymous blank nodes" do
      tokenize(%q([])).first
      tokenize(%q([ ])).first
    end
  end

  describe "when tokenizing variables" do
    it "tokenizes variables prefixed with '?'" do
      tokenize(%q(?foo)).first
    end

    it "tokenizes variables prefixed with '$'" do
      tokenize(%q($foo)).first
    end
  end

  describe "when tokenizing IRI references" do
    it "tokenizes absolute IRI references" do
      tokenize(%q(<http://example.org/foobar>)).first
    end

    it "tokenizes relative IRI references" do
      tokenize(%q(<foobar>)).first
    end
  end

  describe "when tokenizing prefixed names" do
    it "tokenizes prefixed names" do
      tokenize(%q(dc:title)).first
    end
  end

  describe "when tokenizing RDF literals" do
    it "tokenizes language-tagged literals" do
      tokenize(%q("Hello, world!"@en)).first
      tokenize(%q("Hello, world!"@en-US)).first
    end

    it "tokenizes datatyped literals" do
      tokenize(%q("3.1415"^^<http://www.w3.org/2001/XMLSchema#double>)).first
    end
  end

  describe "when tokenizing SPARQL keywords" do
    it "tokenizes base and prefix declaration keywords" do
      %w(base prefix).each do |keyword|
        tokenize(keyword.upcase).first
        tokenize(keyword.downcase).first
      end
    end

    it "tokenizes query form keywords" do
      %w(select construct describe ask).each do |keyword|
        tokenize(keyword.upcase).first
        tokenize(keyword.downcase).first
      end
    end

    it "tokenizes solution sequence modifier keywords" do
      ['order by'] + %w(limit offset distinct reduced).each do |keyword|
        tokenize(keyword.upcase).first
        tokenize(keyword.downcase).first
      end
    end

    it "tokenizes dataset clause specifier keywords" do
      ['from named'] + %w(from where).each do |keyword|
        tokenize(keyword.upcase).first
        tokenize(keyword.downcase).first
      end
    end

    it "tokenizes graph pattern constraint keywords" do
      %w(graph optional union filter).each do |keyword|
        tokenize(keyword.upcase).first
        tokenize(keyword.downcase).first
      end
      tokenize(%q(a)).first
    end

    it "tokenizes built-in function keywords" do
      %w(STR LANG LANGMATCHES DATATYPE BOUND sameTerm isIRI isURI isBLANK isLITERAL REGEX).each do |keyword|
        tokenize(keyword.upcase).first
        tokenize(keyword.downcase).first
        tokenize(keyword).first
      end
    end
  end

  def tokenize(input, options = {}, &block)
    result = SPARQL::Grammar::Lexer.tokenize(input, options)
    block_given? ? block.call(result) : result
  end

  def unescape(input)
    result = SPARQL::Grammar::Lexer.unescape(input)
  end
end
