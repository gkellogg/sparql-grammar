# Extensions for RDF classes

module RDF
  class URI
    # Override qname to save value for SXP serialization
    def qname=(value); @qname = value; end
    def qname; @qname; end
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
    # Filter to be applied to solution set.
    # Represented as an S-Expression of SPARQL Algebra operations
    # @return [Array]
    attr_accessor :filter

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
    # @option options [Array] :filter (nil)
    #   Filter to apply (leftjoin only)
    # @yield  [query]
    # @yieldparam  [RDF::GroupQuery] query
    # @yieldreturn [void] ignored
    def initialize(queries = [], operation = :join, options = {}, &block)
      super(nil, options) do
        @queries = [queries].flatten.compact
        @filter = options[:filter]
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
    
    ##
    # Executes this query on the given `queryable` graph or repository.
    #
    # @param  [RDF::Queryable] queryable
    #   the graph or repository to query
    # @param  [Hash{Symbol => Object}] options
    #   any additional keyword options
    # @return [RDF::Query::Solutions]
    #   the resulting solution sequence
    # @see    http://www.w3.org/TR/rdf-sparql-query/#sparqlAlgebra
    #
    #     D : a dataset
    #     D(G) : D a dataset with active graph G (the one patterns match against)
    #     D[i] : The graph with IRI i in dataset D
    #     D[DFT] : the default graph of D
    #     P, P1, P2 : graph patterns
    #     L : a solution sequence
    def execute(queryable, options = {})
      case @operation
      when :union
        # Definition: Union
        # Let Ω1 and Ω2 be multisets of solution mappings. We define:
        # Union(Ω1, Ω2) = { μ | μ in Ω1 or μ in Ω2 }
        # card[Union(Ω1, Ω2)](μ) = card[Ω1](μ) + card[Ω2](μ)
        # eval(D(G), Union(P1,P2)) = Union(eval(D(G), P1), eval(D(G), P2)
      when :leftjoin
        # Let Ω1 and Ω2 be multisets of solution mappings and expr be an expression. We define:
        # LeftJoin(Ω1, Ω2, expr) = Filter(expr, Join(Ω1, Ω2)) set-union Diff(Ω1, Ω2, expr)
        # card[LeftJoin(Ω1, Ω2, expr)](μ) = card[Filter(expr, Join(Ω1, Ω2))](μ) + card[Diff(Ω1, Ω2, expr)](μ)
        #
        # Written in full that is:
        # LeftJoin(Ω1, Ω2, expr) =
        #     { merge(μ1, μ2) | μ1 in Ω1and μ2 in Ω2, and μ1 and μ2 are compatible and expr(merge(μ1, μ2)) is true }
        # set-union
        #     { μ1 | μ1 in Ω1and μ2 in Ω2, and μ1 and μ2 are not compatible }
        # set-union
        #     { μ1 | μ1 in Ω1and μ2 in Ω2, and μ1 and μ2 are compatible and expr(merge(μ1, μ2)) is false }
        # eval(D(G), LeftJoin(P1, P2, F)) = LeftJoin(eval(D(G), P1), eval(D(G), P2), F)
      else #join
        # Join(Ω1, Ω2) = { merge(μ1, μ2) | μ1 in Ω1and μ2 in Ω2, and μ1 and μ2 are compatible }
        # eval(D(G), Join(P1, P2)) = Join(eval(D(G), P1), eval(D(G), P2))
      end
    end

    def inspect
      "RDF::GroupQuery(#{operation})#{queries.inspect}"
    end
    
    # Transform GroupQuery into an Array form of an SXP
    #
    # @return [Array]
    def to_sxa
      sse = [operation] + queries.map {|q| q.to_sxa}
      sse << @filter if @filter
      sse
    end
  end
  
  class Query::Variable
    def to_sxp; to_s; end
  end
end