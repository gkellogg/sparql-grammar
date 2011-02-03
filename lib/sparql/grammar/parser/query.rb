# Patches for RDF::Query
require 'rdf/query'

module RDF
  class Query
    ##
    # @return [RDF::Resource]
    attr_accessor :context

    # Add patterns from another query to form a new Query
    # @param [RDF::Query] other
    # @return [RDF::Query]
    def +(other)
      Query.new(self.patterns + other.patterns)
    end
    
    # Is this is a named query?
    # @return [Boolean]
    def named?
      !unnamed?
    end
    
    def unnamed?
      options[:context].nil?
    end
    
    # Add name to query
    # @param [RDF::Value] value
    # @return [RDF::Value]
    def context=(value)
      options[:context] = value
    end
    
    # Name of this query, if any
    # @return [RDF::Value]
    def context
      options[:context]
    end
  end
end