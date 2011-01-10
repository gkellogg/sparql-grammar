require 'sparql/grammar'
require 'rdf/spec'
require 'rdf/ntriples'
require 'open-uri/cached'

# Create and maintain a cache of downloaded URIs
URI_CACHE = File.expand_path(File.join(File.dirname(__FILE__), "uri-cache"))
Dir.mkdir(URI_CACHE) unless File.directory?(URI_CACHE)
OpenURI::Cache.class_eval { @cache_path = URI_CACHE }

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.exclusion_filter = {
    :ruby => lambda { |version| !(RUBY_VERSION.to_s =~ /^#{version.to_s}/) },
  }
  config.include(RDF::Spec::Matchers)
end

DAWG = RDF::Vocabulary.new('http://www.w3.org/2001/sw/DataAccess/tests/test-dawg#')
MF   = RDF::Vocabulary.new('http://www.w3.org/2001/sw/DataAccess/tests/test-manifest#')
QT   = RDF::Vocabulary.new('http://www.w3.org/2001/sw/DataAccess/tests/test-query#')
RS   = RDF::Vocabulary.new('http://www.w3.org/2001/sw/DataAccess/tests/result-set#')
SG   = RDF::Vocabulary.new('http://www.w3.org/2000/10/swap/grammar/sparql#')
