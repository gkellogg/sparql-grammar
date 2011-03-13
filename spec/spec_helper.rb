require "bundler/setup"
require 'open-uri/cached'
require 'sparql/grammar'
require 'sparql/spec'
require 'rdf/spec'
require 'rdf/ntriples'
require 'rdf/n3'
Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  #config.include(RDF::Spec::Matchers)
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.exclusion_filter = {
    :ruby           => lambda { |version| RUBY_VERSION.to_s !~ /^#{version}/},
    :blank_nodes    => 'unique',
    :arithmetic     => 'native',
    :sparql_algebra => false,
    #:status         => 'bug',
    :reduced        => 'all',
  }
end

# Create and maintain a cache of downloaded URIs
URI_CACHE = File.expand_path(File.join(File.dirname(__FILE__), "uri-cache"))
Dir.mkdir(URI_CACHE) unless File.directory?(URI_CACHE)
OpenURI::Cache.class_eval { @cache_path = URI_CACHE }

DAWG = RDF::Vocabulary.new('http://www.w3.org/2001/sw/DataAccess/tests/test-dawg#')
MF   = RDF::Vocabulary.new('http://www.w3.org/2001/sw/DataAccess/tests/test-manifest#')
QT   = RDF::Vocabulary.new('http://www.w3.org/2001/sw/DataAccess/tests/test-query#')
RS   = RDF::Vocabulary.new('http://www.w3.org/2001/sw/DataAccess/tests/result-set#')

# This file defines the sparql query function, which makes a sparql query and returns results.

# run a sparql query against SPARQL S-Expression (SSE)
# Options:
#   :graphs
#     example
#       opts[:graphs] ==
#        { :default => {
#             :data => '...',
#             :format => :ttl
#           },
#           <g1> => {
#            :data => '...',
#            :format => :ttl
#           }
#           <g2> => {
#            :default => true
#           }
#        }
#   :allow_empty => true
#     allow no data for query (raises an exception by default)
#   :query
#     A SPARQL query, as a string
#   :repository
#     The dydra repository associated with the account to use
#   :form
#     :ask, :construct, :select or :describe
def sparql_query(opts)
  opts[:to_hash] = true unless opts.has_key?(:to_hash)
  raise "A query is required to be run" if opts[:query].nil?

  # Load default and named graphs into repository
  repo = RDF::Repository.new do |r|
    opts[:graphs].each do |key, info|
      next if key == :result
      data, format, default = info[:data], info[:format], info[:default]
      if data
        RDF::Reader.for(:file_extension => format).new(data).each_statement do |st|
          st.context = key unless key == :default || default
          r << st
        end
      end
    end
  end

  query_str = opts[:query]
  query_opts = {:debug => ENV['PARSER_DEBUG']}
  query_opts[:base_uri] = opts[:base_uri]
  
  if opts[:sse]
    query = SPARQL::Algebra.parse(query_str, query_opts)
  else
    query = SPARQL::Grammar.parse(query_str, query_opts)
  end

  case opts[:form]
  when :ask, :describe, :construct
    query.execute(repo, :debug => ENV['EXEC_DEBUG'])
  else
    results = query.execute(repo, :debug => ENV['EXEC_DEBUG'])
    opts[:to_hash] ? results.map(&:to_hash) : results
  end
end

