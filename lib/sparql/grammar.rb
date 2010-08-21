require 'rdf'

module SPARQL
  ##
  # A SPARQL grammar for RDF.rb.
  #
  # @see http://www.w3.org/TR/rdf-sparql-query/#grammar
  module Grammar
    autoload :Lexer,   'sparql/grammar/lexer'
    autoload :VERSION, 'sparql/grammar/version'

    METHODS   = %w(SELECT CONSTRUCT DESCRIBE ASK).map(&:to_sym)
    KEYWORDS  = %w(BASE PREFIX LIMIT OFFSET DISTINCT REDUCED
                   ORDER BY ASC DESC FROM NAMED WHERE GRAPH
                   OPTIONAL UNION FILTER).map(&:to_sym).unshift(*METHODS)
    FUNCTIONS = %w(STR LANGMATCHES LANG DATATYPE BOUND sameTerm
                   isIRI isURI isBLANK isLITERAL REGEX).map(&:to_sym)

    # Make all defined non-autoloaded constants immutable:
    constants.each { |name| const_get(name).freeze unless autoload?(name) }

    ##
    # Tokenizes the given SPARQL `query` string.
    #
    # @param  [String, #to_s]          query
    # @param  [Hash{Symbol => Object}] options
    # @yield  [lexer]
    # @yieldparam [Lexer] lexer
    # @return [Lexer]
    # @raise  [Lexer::Error] on invalid input
    def self.tokenize(query, options = {}, &block)
      Lexer.tokenize(query, options, &block)
    end
  end
end
