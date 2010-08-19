module SPARQL; module Grammar
  ##
  # A lexical analyzer for the SPARQL 1.0 grammar.
  #
  # @see http://en.wikipedia.org/wiki/Lexical_analysis
  class Lexer
    include Enumerable

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
      @input = input.to_s
    end

    ##
    # @yield  [token]
    # @yieldparam [Object] token
    # @return [Enumerator]
    def each(&block)
      return enum_for(:each) unless block_given?
      # TODO
    end
  end # class Lexer
end; end # module SPARQL::Grammar
