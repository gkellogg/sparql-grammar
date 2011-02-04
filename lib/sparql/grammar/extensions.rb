# Extensions for RDF classes

module RDF
  class URI
    ##
    # Returns the SXP representation of this object.
    #
    # @return [String]
    def to_sxp; qname || "<#{self}>"; end
    
    # Override qname to save value for SXP serialization
    def qname=(value); @qname = value; end
    def qname; @qname; end
  end

  class Literal
    ##
    # Returns the SXP representation of a Literal.
    #
    # @return [String]
    def to_sxp
      case datatype
      when XSD.boolean, XSD.integer, XSD.double, XSD.decimal, XSD.time
        object.to_sxp
      else
        text = value.dump
        text << "@#{language}" if self.has_language?
        text << "^^#{datatype.to_sxp}" if self.has_datatype?
        text
      end
    end
  end

  class Statement
    def inspect
      to_sxa.map(&:to_sxp).inspect
    end
    
    # Transform Query into an Array form of an SXP
    # @return [Statement]
    def to_sxa
      [:triple, subject, predicate, object]
    end

    # Transform Statement into an SXP
    # @return [String]
    def to_sxp
      to_sxa.to_sxp
    end
  end
  
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

    # Query has no patterns
    def empty?
      patterns.empty?
    end

    def inspect
      "RDF::Query(#{context ? context.to_sxp : 'nil'})#{patterns.inspect}"
    end

    # Transform Query into an Array form of an SXP
    #
    # If Query is named, it's treated as a GroupGraphPattern, otherwise, a BGP
    #
    # @return [Array]
    def to_sxa
      res = [:bgp] + patterns
      named? ? [:graph, context, res] : res
    end
    
    # Transform Query into an SXP
    # @return [String]
    def to_sxp
      to_sxa.to_sxp
    end
  end
  
  ##
  # A Query sub-class to represent :join, :union and :leftjoin
  #
  # Represents pairs of Queries with an operation.
  #
  # Variables, solutions, and patterns can be derived via an operation on the constituent graphs.
  # This may be done after execution of sub-components, or as an optimization phase to resolve
  # a GroupQuery object into a new GroupQuery object with a simpler graph, or to a Query object
  class GroupQuery < Query
    ##
    # Queries included. No greater than 2.
    # @return [RDF::Query]
    attr_accessor :queries

    ##
    # Operation to be performed, one of :join, :leftjoin, or :union.
    # @return [Symbol]
    attr_accessor :operation

    ##
    # Initializes a new algebra query.
    #
    # @param  [Array<RDF::Query>] queries
    #   Queries to be operated upon
    # @param  [to_sym] operation (:join)
    #   Must be one of :join, :leftjoin, or :union
    # @param  [Hash{Symbol => Object}] options
    #   any additional keyword options
    # @option options [RDF::Query::Solutions] :solutions (Solutions.new)
    # @yield  [query]
    # @yieldparam  [RDF::GroupQuery] query
    # @yieldreturn [void] ignored
    def initialize(queries = [], operation = :join, options = {}, &block)
      super(nil, options) do
        @queries = [queries].flatten.compact
        @operation = operation

        if block_given?
          case block.arity
            when 0 then instance_eval(&block)
            else block.call(self)
          end
        end
      end
    end
    
    ##
    # Appends the given query to this query.
    #
    # @param  [RDF::Query] query
    #   a query
    # @return [void] self
    def <<(query)
      @queries << query
      self
    end

    ##
    # Prepends the given query to this query.
    #
    # @param  [RDF::Query] query
    #   a query
    # @return [void] self
    def unshift(query)
      @queries.unshift(query)
      self
    end

    ##
    # Appends the given query to this query.
    #
    # @param  [RDF::Query] query
    #   a query
    # @return [void] self
    def query(query)
      @queries << query
      self
    end

    # Query has no queries
    def empty?
      queries.empty?
    end

    def inspect
      "RDF::GroupQuery(#{operation})#{queries.inspect}"
    end
    
    # Transform GroupQuery into an Array form of an SXP
    #
    # @return [Array]
    def to_sxa
      [operation] + queries.map {|q| q.to_sxa}
    end
  end
  
  class Query::Variable
    def to_sxp; to_s; end
  end
end