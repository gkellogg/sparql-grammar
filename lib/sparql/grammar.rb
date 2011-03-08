require 'rdf' # @see http://rubygems.org/gems/rdf
require 'sparql/algebra'
require 'json'
require 'sxp'

module SPARQL
  ##
  # A SPARQL grammar for RDF.rb.
  #
  # @see http://www.w3.org/TR/rdf-sparql-query/#grammar
  module Grammar
    autoload :Lexer,   'sparql/grammar/lexer'
    autoload :Parser,  'sparql/grammar/parser'
    autoload :Meta,    'sparql/grammar/parser/meta'
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
    # Parser the given SPARQL `query` string.
    #
    # @example
    #   parser = SPARQL::Grammar.new("SELECT * WHERE { ?s ?p ?o }")
    #   result = parser.parse
    #
    # @param  [String, #to_s]          query
    # @param  [Hash{Symbol => Object}] options
    # @return [Parser]
    # @raise  [Parser::Error] on invalid input
    def self.parse(query, options = {}, &block)
      Parser.new(query, options).parse
    end

    ##
    # Returns `true` if the given SPARQL `query` string is valid.
    #
    # @example
    #   SPARQL::Grammar.valid?("SELECT ?s WHERE { ?s ?p ?o }")  #=> true
    #   SPARQL::Grammar.valid?("SELECT s WHERE { ?s ?p ?o }")   #=> false
    #
    # @param  [String, #to_s]          query
    # @param  [Hash{Symbol => Object}] options
    # @return [Boolean]
    def self.valid?(query, options = {})
      Parser.new(query, options).valid?
    end

    ##
    # Tokenizes the given SPARQL `query` string.
    #
    # @example
    #   lexer = SPARQL::Grammar.tokenize("SELECT * WHERE { ?s ?p ?o }")
    #   lexer.each_token do |token|
    #     puts token.inspect
    #   end
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
    
    class SPARQL_GRAMMAR < RDF::Vocabulary("http://www.w3.org/2000/10/swap/grammar/sparql#"); end
  end # Grammar
end # SPARQL
