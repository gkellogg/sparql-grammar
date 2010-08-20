require 'strscan'    unless defined?(StringScanner)
require 'bigdecimal' unless defined?(BigDecimal)

module SPARQL; module Grammar
  ##
  # A lexical analyzer for the SPARQL 1.0 grammar.
  #
  # Note that productions [80]-[85] have been incorporated directly into
  # [77], [78], [79].
  #
  # @see http://www.w3.org/TR/rdf-sparql-query/#grammar
  # @see http://en.wikipedia.org/wiki/Lexical_analysis
  class Lexer
    include Enumerable

    ESCAPE_CHAR4         = /\\u([0-9A-Fa-f]{4,4})/                              # \uXXXX
    ESCAPE_CHAR8         = /\\U([0-9A-Fa-f]{8,8})/                              # \UXXXXXXXX
    ESCAPE_CHAR          = /#{ESCAPE_CHAR4}|#{ESCAPE_CHAR8}/

    module Unicode
      U_CHARS1           = /[\u00C0-\u00D6]|[\u00D8-\u00F6]|[\u00F8-\u02FF]|
                            [\u0370-\u037D]|[\u037F-\u1FFF]|[\u200C-\u200D]|
                            [\u2070-\u218F]|[\u2C00-\u2FEF]|[\u3001-\uD7FF]|
                            [\uF900-\uFDCF]|[\uFDF0-\uFFFD]|[\u{10000}-\u{EFFFF}]/xu
      U_CHARS2           = /\u00B7|[\u0300-\u036F]|[\u203F-\u2040]/u
    end
    include Unicode      # FIXME: Ruby 1.8 compatibility

    KEYWORD              = /#{KEYWORDS.join('|')}|#{FUNCTIONS.join('|')}/i
    DELIMITER            = /\^\^|[{}()\[\],;\.]/
    OPERATOR             = /a|\|\||&&|!=|<=|>=|[!=<>+\-*\/]/

    PN_CHARS_BASE        = /[A-Z]|[a-z]|#{U_CHARS1}/                            # [95]
    PN_CHARS_U           = /_|#{PN_CHARS_BASE}/                                 # [96]
    VARNAME              = /(?:[0-9]|#{PN_CHARS_U})
                            (?:[0-9]|#{PN_CHARS_U}|#{U_CHARS2})*/x              # [97]
    PN_CHARS             = /-|[0-9]|#{PN_CHARS_U}|#{U_CHARS2}/                  # [98]
    PN_CHARS_BODY        = /(?:(?:\.|#{PN_CHARS})*#{PN_CHARS})?/
    PN_PREFIX            = /#{PN_CHARS_BASE}#{PN_CHARS_BODY}/                   # [99]
    PN_LOCAL             = /(?:[0-9]|#{PN_CHARS_U})#{PN_CHARS_BODY}/            # [100]

    IRI_REF              = /<([^<>"{}|^`\\\x00-\x20]*)>/                        # [70]
    PNAME_NS             = /(#{PN_PREFIX}?):/                                   # [71]
    PNAME_LN             = /#{PNAME_NS}(#{PN_LOCAL})/                           # [72]
    BLANK_NODE_LABEL     = /_:(#{PN_LOCAL})/                                    # [73]
    VAR1                 = /\?(#{VARNAME})/                                     # [74]
    VAR2                 = /\$(#{VARNAME})/                                     # [75]
    LANGTAG              = /@([a-zA-Z]+(?:-[a-zA-Z0-9]+)*)/                     # [76]
    INTEGER              = /[+-]?[0-9]+/                                        # [77]
    DECIMAL              = /[+-]?(?:[0-9]+\.[0-9]*|\.[0-9]+)/                   # [78]
    EXPONENT             = /[eE][+-]?[0-9]+/                                    # [86]
    DOUBLE               = /[+-]?(?:[0-9]+\.[0-9]*|\.[0-9]+|[0-9]+)#{EXPONENT}/ # [79]
    ECHAR                = /\\[tbnrf\\"']/                                      # [91]
    STRING_LITERAL1      = /'((?:[^\x27\x5C\x0A\x0D]|#{ECHAR})*)'/              # [87]
    STRING_LITERAL2      = /"((?:[^\x22\x5C\x0A\x0D]|#{ECHAR})*)"/              # [88]
    STRING_LITERAL_LONG1 = /'''((?:(?:'|'')?(?:[^'\\]|#{ECHAR})+)*)'''/         # [89]
    STRING_LITERAL_LONG2 = /"""((?:(?:"|"")?(?:[^"\\]|#{ECHAR})+)*)"""/         # [90]
    WS                   = /\x20|\x09|\x0D|\x0A/                                # [93]
    NIL                  = /\(#{WS}*\)/                                         # [92]
    ANON                 = /\[#{WS}*\]/                                         # [94]

    Var                  = /#{VAR1}|#{VAR2}/                                    # [44]
    NumericLiteral       = /#{DOUBLE}|#{DECIMAL}|#{INTEGER}/                    # [61]
    BooleanLiteral       = /true|false/                                         # [65]
    String               = /#{STRING_LITERAL_LONG1}|#{STRING_LITERAL_LONG2}|
                            #{STRING_LITERAL1}|#{STRING_LITERAL2}/x             # [66]
    PrefixedName         = /#{PNAME_LN}|#{PNAME_NS}/                            # [68]
    IRIref               = /#{IRI_REF}|#{PrefixedName}/                         # [67]
    RDFLiteral           = /#{String}(?:#{LANGTAG}|(?:\^\^#{IRIref}))?/         # [60]
    BlankNode            = /#{BLANK_NODE_LABEL}|#{ANON}/                        # [69]

    # Make all defined regular expression constants immutable:
    constants.each { |name| const_get(name).freeze }

    ##
    # Returns a copy of the given `input` string with all `\uXXXX` and
    # `\UXXXXXXXX` Unicode codepoint escape sequences replaced with their
    # unescaped UTF-8 character counterparts.
    #
    # @param  [String] input
    # @return [String]
    # @see    http://www.w3.org/TR/rdf-sparql-query/#codepointEscape
    def self.unescape(input)
      string = input.dup
      string.force_encoding(Encoding::ASCII_8BIT) if string.respond_to?(:force_encoding)

      # Decode \uXXXX and \UXXXXXXXX code points:
      string.gsub!(ESCAPE_CHAR) do
        s = [($1 || $2).hex].pack('U*')
        s.respond_to?(:force_encoding) ? s.force_encoding(Encoding::ASCII_8BIT) : s
      end

      string.force_encoding(Encoding::UTF_8) if string.respond_to?(:force_encoding)
      string
    end

    ##
    # Tokenizes the given `input` string or stream.
    #
    # @param  [String, #to_s]          input
    # @param  [Hash{Symbol => Object}] options
    # @return [Enumerable<Token>]
    def self.tokenize(input, options = {})
      self.new(input, options)
    end

    ##
    # @param  [String, #to_s]          input
    # @param  [Hash{Symbol => Object}] options
    def initialize(input = nil, options = {})
      @options = options.dup
      self.input = input if input
    end

    # @return [Hash]
    attr_reader   :options

    # @return [String]
    attr_accessor :input

    ##
    # @param  [String, #to_s] input
    # @return [void]
    def input=(input)
      @input = case input
        when String       then input
        when IO, StringIO then input.read
        else input.to_s
      end
      @input = self.class.unescape(@input) if ESCAPE_CHAR === @input
    end

    ##
    # Enumerates each token in the input string.
    #
    # @yield  [token]
    # @yieldparam [Token] token
    # @return [Enumerator]
    def each_token(&block)
      if block_given?
        scanner = StringScanner.new(@input)
        until scanner.eos?
          case
            when matched = scanner.scan(Var)
              yield Token.new(:Var, (scanner[1] || scanner[2]).to_sym)
            when matched = scanner.scan(IRI_REF)
              yield Token.new(:IRI_REF, RDF::URI(scanner[1]))
            when matched = scanner.scan(PNAME_LN)
              yield Token.new(:PNAME_LN, [scanner[1].empty? ? nil : scanner[1].to_sym, scanner[2].to_sym])
            when matched = scanner.scan(PNAME_NS)
              yield Token.new(:PNAME_NS, scanner[1].empty? ? nil : scanner[1].to_sym)
            when matched = scanner.scan(String)
              yield Token.new(:String, unescape_string(scanner[1] || scanner[2] || scanner[3] || scanner[4]))
            when matched = scanner.scan(LANGTAG)
              yield Token.new(:LANGTAG, scanner[1].to_sym)
            when matched = scanner.scan(DOUBLE)
              yield Token.new(:NumericLiteral, Float(matched))
            when matched = scanner.scan(DECIMAL)
              yield Token.new(:NumericLiteral, BigDecimal(matched))
            when matched = scanner.scan(INTEGER)
              yield Token.new(:NumericLiteral, Integer(matched))
            when matched = scanner.scan(BooleanLiteral)
              yield Token.new(:BooleanLiteral, matched.eql?('true'))
            when matched = scanner.scan(BlankNode)
              yield Token.new(:BlankNode, RDF::Node(scanner[1]))
            when matched = scanner.scan(NIL)
              yield Token.new(:NIL, RDF.nil)
            when matched = scanner.scan(KEYWORD)
              yield Token.new(nil, matched.downcase.to_sym)
            when matched = scanner.scan(DELIMITER)
              yield Token.new(nil, matched)
            when matched = scanner.scan(OPERATOR)
              yield Token.new(nil, matched.to_sym)
            when matched = scanner.scan(WS)
              # silently skip all whitespace
              # TODO: handle SPARQL comments
              # TODO: increment lineno when encountering "\n"
            else
              raise Error.new("unexpected token: #{scanner.rest.inspect}")
          end
        end
      end
      enum_for(:each_token)
    end
    alias_method :each, :each_token

  protected

    ##
    # @param  [String]
    # @return [String]
    def unescape_string(string)
      string # TODO
    end

    ##
    # Represents a lexer token.
    class Token
      ##
      # @param  [Symbol]                 type
      # @param  [Object]                 value
      # @param  [Hash{Symbol => Object}] options
      def initialize(type, value, options = {})
        @type, @value = type, value
        @options = options.dup
      end

      # @return [Symbol]
      attr_reader :type

      # @return [Object]
      attr_reader :value

      # @return [Hash]
      attr_reader :options

      ##
      # Returns the attribute named by `key`.
      #
      # @param  [Symbol] key
      # @return [Object]
      def [](key)
        key = key.to_s.to_sym unless key.is_a?(Integer) || key.is_a?(Symbol)
        case key
          when 0, :type  then type
          when 1, :value then value
          else nil
        end
      end

      ##
      # Returns a hash table representation of this token.
      #
      # @return [Hash]
      def to_hash
        {:type => type, :value => value}
      end

      ##
      # Returns an array representation of this token.
      #
      # @return [Array]
      def to_a
        [type, value]
      end

      ##
      # Returns a developer-friendly representation of this token.
      #
      # @return [String]
      def inspect
        to_hash.inspect
      end
    end # class Token

    ##
    # Raised for errors during lexical analysis.
    class Error < StandardError
      attr_reader :lineno
    end
  end # class Lexer
end; end # module SPARQL::Grammar
