require 'sparql/grammar'
require 'rdf/spec'
require 'rdf/ntriples'
require 'rdf/raptor'

Spec::Runner.configure do |config|
  config.include(RDF::Spec::Matchers)
end

DAWG = RDF::Vocabulary.new('http://www.w3.org/2001/sw/DataAccess/tests/test-dawg#')
MF   = RDF::Vocabulary.new('http://www.w3.org/2001/sw/DataAccess/tests/test-manifest#')
QT   = RDF::Vocabulary.new('http://www.w3.org/2001/sw/DataAccess/tests/test-query#')
RS   = RDF::Vocabulary.new('http://www.w3.org/2001/sw/DataAccess/tests/result-set#')
