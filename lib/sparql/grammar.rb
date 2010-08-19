require 'rdf'

module SPARQL
  ##
  # A SPARQL grammar for RDF.rb.
  #
  # @see http://www.w3.org/TR/rdf-sparql-query/#grammar
  module Grammar
    autoload :Lexer,   'sparql/grammar/lexer'
    autoload :VERSION, 'sparql/grammar/version'
  end
end
