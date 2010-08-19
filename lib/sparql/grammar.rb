require 'rdf'

module SPARQL
  ##
  # A SPARQL grammar for RDF.rb.
  module Grammar
    autoload :Lexer,   'sparql/grammar/lexer'
    autoload :VERSION, 'sparql/grammar/version'
  end
end
