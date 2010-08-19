module SPARQL; module Grammar
  ##
  # A lexical analyzer for the SPARQL 1.0 grammar.
  #
  # @see http://www.w3.org/TR/rdf-sparql-query/#grammar
  # @see http://en.wikipedia.org/wiki/Lexical_analysis
  class Lexer
    include Enumerable

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
