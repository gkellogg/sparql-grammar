# Spira class for manipulating test-manifest style test suites.
# Used for DAWG tests
require 'spira'
require 'rdf/n3'

module Fixtures
  module SPARQL
    class MF < RDF::Vocabulary("http://www.w3.org/2001/sw/DataAccess/tests/test-manifest#"); end
    class DT < RDF::Vocabulary("http://www.w3.org/2001/sw/DataAccess/tests/test-dawg#"); end

    class Entry
      include Spira::Resource
      attr_accessor :debug
      attr_accessor :compare
      type MF["PositiveSyntaxTest"]

      property :name, :predicate => MF["name"], :type => XSD.string
      property :action, :predicate => MF["action"]
      property :approvedBy, :predicate => DT.approvedBy
      property :approval, :predicate => DT.approval

      def inspect
        "[#{self.class.to_s} " + %w(
          subject
          name
          action
          approvedBy
          approval
        ).map {|a| v = self.send(a); "#{a}='#{v}'" if v}.compact.join(", ") +
        "]"
      end
    end

    class Syn1 < Entry
      default_source :syn1
    end
    class Syn2 < Entry
      default_source :syn2
    end
    class Syn3 < Entry
      default_source :syn3
    end
    class Syn4 < Entry
      default_source :syn4
    end
    class Syn5 < Entry
      default_source :syn5
    end
    
    syn1 = RDF::Repository.load("http://www.w3.org/2001/sw/DataAccess/tests/data-r2/syntax-sparql1/manifest.ttl", :format => :n3)
    syn2 = RDF::Repository.load("http://www.w3.org/2001/sw/DataAccess/tests/data-r2/syntax-sparql2/manifest.ttl", :format => :n3)
    syn3 = RDF::Repository.load("http://www.w3.org/2001/sw/DataAccess/tests/data-r2/syntax-sparql3/manifest.ttl", :format => :n3)
    syn4 = RDF::Repository.load("http://www.w3.org/2001/sw/DataAccess/tests/data-r2/syntax-sparql4/manifest.ttl", :format => :n3)
    syn5 = RDF::Repository.load("http://www.w3.org/2001/sw/DataAccess/tests/data-r2/syntax-sparql5/manifest.ttl", :format => :n3)

    Spira.add_repository! :syn1, syn1
    Spira.add_repository! :syn2, syn2
    Spira.add_repository! :syn3, syn3
    Spira.add_repository! :syn4, syn4
    Spira.add_repository! :syn5, syn5
  end
end