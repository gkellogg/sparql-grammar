module SPARQL; module Grammar
  ##
  # A lexical analyzer for the SPARQL 1.0 grammar.
  #
  # @see http://www.w3.org/TR/rdf-sparql-query/#grammar
  # @see http://en.wikipedia.org/wiki/Lexical_analysis
  class Lexer
    include Enumerable

    ESCAPE_CHAR4 = /\\u([0-9A-Fa-f]{4,4})/.freeze
    ESCAPE_CHAR8 = /\\U([0-9A-Fa-f]{8,8})/.freeze
    ESCAPE_CHAR  = Regexp.union(ESCAPE_CHAR4, ESCAPE_CHAR8).freeze

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
    # @return [Array<Token>]
    def self.tokenize(input, options = {})
      self.new(input, options).to_a
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
      return enum_for(:each) unless block_given?
      # TODO
    end
    alias_method :each, :each_token

    ##
    # Represents a lexer token.
    class Token
      ##
      # @param  [Symbol]                 name
      # @param  [Object]                 value
      # @param  [Hash{Symbol => Object}] options
      def initialize(name, value, options = {})
        @name, @value = name, value
        @options = options.dup
      end

      # @return [Symbol]
      attr_reader :name

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
          when 0, :name  then name
          when 1, :value then value
          else nil
        end
      end

      ##
      # Returns a hash table representation of this token.
      #
      # @return [Hash]
      def to_hash
        {:name => name, :value => value}
      end

      ##
      # Returns an array representation of this token.
      #
      # @return [Array]
      def to_a
        [name, value]
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
