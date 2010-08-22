module SPARQL; module Grammar
  ##
  # A parser for the SPARQL 1.0 grammar.
  #
  # @see http://www.w3.org/TR/rdf-sparql-query/#grammar
  # @see http://en.wikipedia.org/wiki/Parsing
  # @see http://en.wikipedia.org/wiki/Recursive_descent_parser
  class Parser
    ##
    # Initializes a new parser instance.
    #
    # @param  [String, #to_s]          input
    # @param  [Hash{Symbol => Object}] options
    def initialize(input = nil, options = {})
      @options = options.dup
      self.input = input if input
    end

    ##
    # Any additional options for the parser.
    #
    # @return [Hash]
    attr_reader   :options

    ##
    # The current input string.
    #
    # @return [String]
    attr_accessor :input

    ##
    # @param  [String, #to_s] input
    # @return [void]
    def input=(input)
      @input = input
      @input = case @input
        when Lexer then @input
        else Lexer.new(@input, @options)
      end
    end

    ##
    # Returns `true` if the input string is syntactically valid.
    #
    # @return [Boolean]
    def valid?
      nil # TODO
    end
  end # class Parser
end; end # module SPARQL::Grammar
