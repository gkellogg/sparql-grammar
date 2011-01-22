module SPARQL; module Grammar
  ##
  # A parser for the SPARQL 1.0 grammar.
  #
  # @see http://www.w3.org/TR/rdf-sparql-query/#grammar
  # @see http://en.wikipedia.org/wiki/LR_parser
  # @see http://www.w3.org/2000/10/swap/grammar/predictiveParser.py
  # @see http://www.w3.org/2001/sw/DataAccess/rq23/parsers/sparql.ttl
  class Parser
    include SPARQL::Grammar::Meta

    START = SPARQL_GRAMMAR.Query
    GRAPH_OUTPUTS = [:bgp, :distinct, :filter, :graph, :join, :leftjoin, :order, :project, :reduced, :slice, :union]

    ##
    # Initializes a new parser instance.
    #
    # @param  [String, #to_s]          input
    # @param  [Hash{Symbol => Object}] options
    # @option options [Hash]     :prefixes     (Hash.new)
    #   the prefix mappings to use (for acessing intermediate parser productions)
    # @option options [#to_s]    :base_uri     (nil)
    #   the base URI to use when resolving relative URIs (for acessing intermediate parser productions)
    # @option options [#to_s]    :anon_base     ("gen0000")
    #   Basis for generating anonymous Nodes
    # @option options [Boolean] :resolve_uris (false)
    #   Resolve prefix and relative IRIs, otherwise output as symbols
    # @option options [Boolean]  :validate     (false)
    #   whether to validate the parsed statements and values
    # @option options [Boolean] :progress
    #   Show progress of parser productions
    # @option options [Boolean] :debug
    #   Detailed debug output
    # @return [SPARQL::Grammar::Parser]
    def initialize(input = nil, options = {})
      @options = {:anon_base => "gen0000", :validate => false}.merge(options)
      self.input = input if input
      @productions = []
    end

    ##
    # Any additional options for the parser.
    #
    # @return [Hash]
    attr_reader   :options

    ##
    # The current input string being processed.
    #
    # @return [String]
    attr_accessor :input

    ##
    # The current input tokens being processed.
    #
    # @return [Array<Token>]
    attr_reader   :tokens

    ##
    # The internal S-Exp of the result.
    #
    # @return [Array]
    attr_accessor :result

    ##
    # @param  [String, #to_s] input
    # @return [void]
    def input=(input)
      case input
        when Array
          @input  = nil # FIXME
          @tokens = input
        else
          lexer   = input.is_a?(Lexer) ? input : Lexer.new(input, @options)
          @input  = lexer.input
          @tokens = lexer.to_a
      end
    end

    ##
    # Returns `true` if the input string is syntactically valid.
    #
    # @return [Boolean]
    def valid?
      parse
    rescue Error
      false
    end
    
    # Output SSE as an S-Expression
    #
    # @return [String]
    def to_sse
      @result.to_sxp
    end
    
    alias_method :to_s, :to_sse

    # Parse query
    #
    # The result is a SPARQL Algebra S-List. Productions return an array such as the following:
    #
    #   [:prefix, :foo, <http://example.com>]
    #   [:prologue, [:prefix, :foo, <http://example.com>]]
    #   [:prologue, [:base, <http://example.com>], [:prefix :foo <http://example.com>]]
    #
    # Algebra is based on the SPARQL Algebra notes
    # @param [Symbol, #to_s] prod The starting production for the parser.
    #   It may be a URI from the grammar, or a symbol representing the local_name portion of the grammar URI.
    # @return [Array]
    # @see http://www.w3.org/2001/sw/DataAccess/rq23/rq24-algebra.html
    # @see http://axel.deri.ie/sparqltutorial/ESWC2007_SPARQL_Tutorial_unit2b.pdf
    def parse(prod = START)
      @prod_data = [{}]
      prod = prod.to_s.split("#").last.to_sym unless prod.is_a?(Symbol)
      todo_stack = [{:prod => prod, :terms => nil}]

      while !todo_stack.empty?
        pushed = false
        if todo_stack.last[:terms].nil?
          todo_stack.last[:terms] = []
          token = tokens.first
          @lineno = token.lineno if token
          debug("parse(token)", "#{token.inspect}, prod #{todo_stack.last[:prod]}, depth #{todo_stack.length}")
          
          # Got an opened production
          onStart(abbr(todo_stack.last[:prod]))
          break if token.nil?
          
          cur_prod = todo_stack.last[:prod]
          prod_branch = BRANCHES[cur_prod.to_sym]
          error("parse", "No branches found for '#{abbr(cur_prod)}'",
            :production => cur_prod, :token => token) if prod_branch.nil?
          sequence = prod_branch[token.representation]
          debug("parse(production)", "cur_prod #{cur_prod}, token #{token.representation.inspect} prod_branch #{prod_branch.keys.inspect}, sequence #{sequence.inspect}")
          if sequence.nil?
            expected = prod_branch.values.uniq.map {|u| u.map {|v| abbr(v).inspect}.join(",")}
            error("parse", "Found '#{token.inspect}' when parsing a #{abbr(cur_prod)}. expected #{expected.join(' | ')}",
              :production => cur_prod, :token => token)
          end
          todo_stack.last[:terms] += sequence
        end
        
        debug("parse(terms)", "stack #{todo_stack.last.inspect}, depth #{todo_stack.length}")
        while !todo_stack.last[:terms].to_a.empty?
          term = todo_stack.last[:terms].shift
          debug("parse tokens(#{term})", tokens.inspect)
          if tokens.map(&:representation).include?(term)
            token = accept(term)
            @lineno = token.lineno if token
            debug("parse", "term(#{token.inspect}): #{term}")
            if token
              onToken(abbr(term), token.value)
            else
              error("parse", "Found '#{word}...'; #{term} expected",
                :production => todo_stack.last[:prod], :token => tokens.first)
            end
          else
            todo_stack << {:prod => term, :terms => nil}
            debug("parse(push)", "stack #{term}, depth #{todo_stack.length}")
            pushed = true
            break
          end
        end
        
        while !pushed && !todo_stack.empty? && todo_stack.last[:terms].to_a.empty?
          debug("parse(pop)", "stack #{todo_stack.last.inspect}, depth #{todo_stack.length}")
          todo_stack.pop
          self.onFinish
        end
      end
      while !todo_stack.empty?
        debug("parse(pop)", "stack #{todo_stack.last.inspect}, depth #{todo_stack.length}")
        todo_stack.pop
        self.onFinish
      end
      
      # The last thing on the @prod_data stack is the result
      @result = prod_data
      if @result.is_a?(Hash) && !@result.empty?
        key = @result.keys.first
        @result = [key] + result[key]  # Creates [:bgp, [:triple], ...]
      end
    end
    
    ##
    # Returns the URI prefixes currently defined for this parser.
    #
    # @example
    #   parser.prefixes[:dc]  #=> RDF::URI('http://purl.org/dc/terms/')
    #
    # @return [Hash{Symbol => RDF::URI}]
    # @since  0.3.0
    def prefixes
      @options[:prefixes] ||= {}
    end

    ##
    # Defines the given URI prefixes for this parser.
    #
    # @example
    #   parser.prefixes = {
    #     :dc => RDF::URI('http://purl.org/dc/terms/'),
    #   }
    #
    # @param  [Hash{Symbol => RDF::URI}] prefixes
    # @return [Hash{Symbol => RDF::URI}]
    # @since  0.3.0
    def prefixes=(prefixes)
      @options[:prefixes] = prefixes
    end

    ##
    # Defines the given named URI prefix for this parser.
    #
    # @example Defining a URI prefix
    #   parser.prefix :dc, RDF::URI('http://purl.org/dc/terms/')
    #
    # @example Returning a URI prefix
    #   parser.prefix(:dc)    #=> RDF::URI('http://purl.org/dc/terms/')
    #
    # @overload prefix(name, uri)
    #   @param  [Symbol, #to_s]   name
    #   @param  [RDF::URI, #to_s] uri
    #
    # @overload prefix(name)
    #   @param  [Symbol, #to_s]   name
    #
    # @return [RDF::URI]
    def prefix(name, uri = nil)
      name = name.to_s.empty? ? nil : (name.respond_to?(:to_sym) ? name.to_sym : name.to_s.to_sym)
      uri.nil? ? prefixes[name] : prefixes[name] = uri
    end

    ##
    # Returns the Base URI defined for the parser,
    # as specified or when parsing a BASE prologue element.
    #
    # @example
    #   parser.base  #=> RDF::URI('http://example.com/')
    #
    # @return [HRDF::URI]
    def base_uri
      @options[:base_uri]
    end

    ##
    # Set the Base URI to use for this parser.
    #
    # @param  [RDF::URI, #to_s] uri
    #
    # @example
    #   parser.base_uri = RDF::URI('http://purl.org/dc/terms/')
    #
    # @return [RDF::URI]
    def base_uri=(uri)
      @options[:base_uri] = RDF::URI(uri)
    end

    ##
    # Returns `true` if parsed statements and values should be validated.
    #
    # @return [Boolean] `true` or `false`
    # @since  0.3.0
    def validate?
      @options[:validate]
    end

  protected

    # Handlers used to define actions for each productions.
    # If a context is defined, create a producation data element and add to the @prod_data stack
    # If entries are defined, pass production data to :start and/or :finish handlers
    def contexts(production)
      case production
      when :Query
        # [1]     Query                     ::=       Prologue ( SelectQuery | ConstructQuery | DescribeQuery | AskQuery )
        {
          :finish => lambda { |data| finalize_query(data) }
        }
      when :Prologue
        # [2]     Prologue                  ::=       BaseDecl? PrefixDecl*
        {
          :finish => lambda { |data|
            add_prod_data(:BaseDecl, data[:BaseDecl])
            add_prod_data(:PrefixDecl, data[:PrefixDecl]) if data[:PrefixDecl]
          }
        }
      when :BaseDecl
        # [3]     BaseDecl      ::=       'BASE' IRI_REF
        {
          :finish => lambda { |data|
            self.base_uri = uri(data[:iri].last) if options[:resolve_uris]
            add_prod_datum(:BaseDecl, data[:iri].last)
          }
        }
      when :PrefixDecl
        # [4] PrefixDecl := 'PREFIX' PNAME_NS IRI_REF";
        {
          :finish => lambda { |data|
            if data[:iri]
              self.prefix(data[:prefix], data[:iri].last)
              add_prod_data(:PrefixDecl, data[:iri].unshift("#{data[:prefix]}:".to_sym))
            end
          }
        }
      when :SelectQuery
        # [5]     SelectQuery               ::=       'SELECT' ( 'DISTINCT' | 'REDUCED' )? ( Var+ | '*' ) DatasetClause* WhereClause SolutionModifier
        {
          :finish => lambda { |data|
            prod = GRAPH_OUTPUTS.map.detect {|p| data[p]}
            
            res = data[prod] if prod
            
            if data[:Var]
              res = res ? res.unshift(prod) : [:null]
              res = [data[:Var]] + [res]
              prod = :project
            end

            if data[:DISTINCT_REDUCED]
              res = res ? [res.unshift(prod)] : [:null]
              prod = data[:DISTINCT_REDUCED].first
            end

            add_prod_datum(prod, res)
          }
        }
      when :ConstructQuery
        # [6]     ConstructQuery            ::=       'CONSTRUCT' ConstructTemplate DatasetClause* WhereClause SolutionModifier
        {
          # Nothing output for ConstructTemplate
          :finish => lambda { |data|
            prod = GRAPH_OUTPUTS.map.detect {|p| data[p.to_sym]}
            
            add_prod_datum(prod, data[prod]) if prod
          }
        }
      when :DescribeQuery
        # [7]     DescribeQuery             ::=       'DESCRIBE' ( VarOrIRIref+ | '*' ) DatasetClause* WhereClause? SolutionModifier
        {
          :finish => lambda { |data|
            prod = GRAPH_OUTPUTS.map.detect {|p| data[p.to_sym]}
            
            res = data[prod] if prod
            
            if data[:Var]
              res = res ? res.unshift(prod) : [:null]
              add_prod_data(:project, data[:Var], res)
            else
              add_prod_datum(prod, res)
            end
          }
        }
      when :DatasetClause
        # [9]     DatasetClause             ::=       'FROM' ( DefaultGraphClause | NamedGraphClause )
        {
          # Swallow productions, as nothing is generated in SSE for datasets
        }
      #when :DefaultGraphClause
      #  # [10]    DefaultGraphClause        ::=       SourceSelector
      #  {
      #    :finish => lambda { |data|
      #      add_prod_datum(:default, data[:IRIref])
      #    }
      #  }
      #when :NamedGraphClause
      #  # [11]    NamedGraphClause          ::=       'NAMED' SourceSelector
      #  {
      #    :finish => lambda { |data|
      #      add_prod_datum(:named, data[:IRIref])
      #    }
      #  }
      when :WhereClause
        # [13]    WhereClause               ::=       'WHERE'? GroupGraphPattern
        {
          :finish => lambda { |data|
            prod = GRAPH_OUTPUTS.map.detect {|p| data[p.to_sym]}
            add_prod_datum(prod, data[prod])
          }
        }
      when :SolutionModifier
        # [14]    SolutionModifier          ::=       OrderClause? LimitOffsetClauses?
        {
          :finish => lambda { |data|
            add_prod_datum(:order, data[:order])
            add_prod_datum(:slice, data[:slice])
          }
        }
      when :LimitOffsetClauses
        # [15]    LimitOffsetClauses        ::=       ( LimitClause OffsetClause? | OffsetClause LimitClause? )
        {
          :finish => lambda { |data|
            return unless data[:limit] || data[:offset]
            limit = data[:limit] ? data[:limit].last : :_
            offset = data[:offset] ? data[:offset].last : :_
            add_prod_data(:slice, offset, limit)
          }
        }
      when :OrderClause
        # [16]    OrderClause               ::=       'ORDER' 'BY' OrderCondition+
        {
          :finish => lambda { |data|
            # Output 2puls of order conditions from left to right
            res = data[:OrderCondition]
            if res = data[:OrderCondition]
              res = [res] if [:asc, :desc].include?(res[0]) # Special case when there's only one condition and it's ASC (x) or DESC (x)
              add_prod_data(:order, res)
            end
          }
        }
      when :OrderCondition
        # [17]    OrderCondition            ::=       ( ( 'ASC' | 'DESC' ) BrackettedExpression ) | ( Constraint | Var )
        {
          :finish => lambda { |data|
             if data[:OrderDirection]
              add_prod_datum(:OrderCondition, [data[:OrderDirection] + data[:Expression]])
            else
              add_prod_datum(:OrderCondition, data[:Constraint] || data[:Var])
            end
          }
        }
      when :LimitClause
        # [18]    LimitClause               ::=       'LIMIT' INTEGER
        {
          :finish => lambda { |data|
            add_prod_datum(:limit, data[:literal])
          }
        }
      when :OffsetClause
        # [19]    OffsetClause              ::=       'OFFSET' INTEGER
        {
          :finish => lambda { |data|
            add_prod_datum(:offset, data[:literal])
          }
        }
      when :GroupGraphPattern
        # [20] GroupGraphPattern ::= '{' TriplesBlock? ( ( GraphPatternNotTriples | Filter ) '.'? TriplesBlock? )* '}'
        {
          :finish => lambda { |data|
            production_list = data[:_GraphPatternNotTriples_or_Filter_Dot_Opt_TriplesBlock_Opt]
            debug "GroupGraphPattern", "pl #{production_list.to_a.to_sxp}"
            debug "GroupGraphPattern", "bgp #{data[:bgp].to_a.to_sxp}"
            
            if production_list
              res = data[:bgp] ? data[:bgp].unshift(:bgp) : [:"table unit"]   # Create dummy first element, if necessary, removed later
              while !production_list.empty?
                prod_graph = production_list.shift
                debug "GroupGraphPattern(itr)", "<= pg: #{prod_graph.to_a.to_sxp}"
                debug "GroupGraphPattern(itr)", "<= res: #{res.to_a.to_sxp}"
                prod = prod_graph.first
                if res == [:"table unit"] && prod == :join
                  # Don't need empty node except for leftjoin
                  res = prod_graph.last
                else
                  res = [prod] + [res] + [prod_graph.last]
                end
                debug "GroupGraphPattern(itr)", "=> res: #{res.to_a.to_sxp}"
              end
              prod = res.shift
            elsif data[:bgp]
              prod, res = :bgp, data[:bgp]
            else
              return  # No reason to filter
            end
            
            if data[:filter]
              res = data[:filter] + [[prod] + res]
              prod = :filter
            end
            add_prod_datum(prod, res)
          }
        }
      when :_GraphPatternNotTriples_or_Filter_Dot_Opt_TriplesBlock_Opt
        # Create a stack of production, graph pairs and resolve in GroupGraphPattern
        {
          :finish => lambda { |data|
            lhs = data[:_GraphPatternNotTriples_or_Filter]
            rhs = data[:bgp].unshift(:bgp) if data[:bgp]
            add_prod_datum(:_GraphPatternNotTriples_or_Filter_Dot_Opt_TriplesBlock_Opt, lhs) if lhs
            add_prod_data(:_GraphPatternNotTriples_or_Filter_Dot_Opt_TriplesBlock_Opt, [:join, rhs]) if rhs
            add_prod_datum(:filter, data[:filter])
          }
        }
      when :_GraphPatternNotTriples_or_Filter
        # Create a stack of production, graph pairs and resolve in GroupGraphPattern
        {
          :finish => lambda { |data|
            add_prod_datum(:filter, data[:filter])

            add_prod_data(:_GraphPatternNotTriples_or_Filter, data[:leftjoin].unshift(:leftjoin)) if data[:leftjoin]
            add_prod_data(:_GraphPatternNotTriples_or_Filter, data[:join].unshift(:join)) if data[:join]
            add_prod_data(:_GraphPatternNotTriples_or_Filter, [:join, data[:union].unshift(:union)]) if data[:union]
            add_prod_data(:_GraphPatternNotTriples_or_Filter, [:join, data[:graph].unshift(:graph)]) if data[:graph]
            add_prod_data(:_GraphPatternNotTriples_or_Filter, [:join, data[:bgp].unshift(:bgp)]) if data[:bgp]
          }
        }
      when :TriplesBlock
        # [21]    TriplesBlock ::= TriplesSameSubject ( '.' TriplesBlock? )?
        {
          :finish => lambda { |data|
            if data[:triple]
              triples = data[:triple].map {|v| [:triple, v[:subject], v[:predicate], v[:object]]}
              add_prod_datum(:bgp, triples)
            end
        
            # Append triples from ('.' TriplesBlock? )? 
            add_prod_datum(:bgp, data[:bgp])
          }
        }
      when :GraphPatternNotTriples
        # [22]    GraphPatternNotTriples    ::=       OptionalGraphPattern | GroupOrUnionGraphPattern | GraphGraphPattern
        {
          :finish => lambda { |data|
            add_prod_datum(:bgp, data[:bgp])
            add_prod_datum(:leftjoin, data[:leftjoin])
            add_prod_datum(:union, data[:union])
            add_prod_datum(:graph, data[:graph])
          }
        }
      when :OptionalGraphPattern
        # [23]    OptionalGraphPattern      ::=       'OPTIONAL' GroupGraphPattern
        {
          :finish => lambda { |data|
            add_prod_data(:leftjoin, data[:bgp].unshift(:bgp)) if data[:bgp]
            add_prod_datum(:leftjoin, data[:leftjoin])
          }
        }
      when :GraphGraphPattern
        # [24]    GraphGraphPattern         ::=       'GRAPH' VarOrIRIref GroupGraphPattern
        {
          :finish => lambda { |data|
            add_prod_data(:graph, (data[:Var] || data[:IRIref]).last, data[:bgp].unshift(:bgp)) if data[:bgp]
          }
        }
      when :GroupOrUnionGraphPattern
        # [25]    GroupOrUnionGraphPattern  ::=       GroupGraphPattern ( 'UNION' GroupGraphPattern )*
        {
          :finish => lambda { |data| add_graphs(:union, data) }
        }
      when :_UNION_GroupGraphPattern_Star
        {
          :finish => lambda { |data|  accumulate_graphs(:union, data) }
        }
      when :Filter
        # [26]    Filter                    ::=       'FILTER' Constraint
        {
          :finish => lambda { |data| add_prod_datum(:filter, data[:Constraint]) }
        }
      when :Constraint
        # [27]    Constraint                ::=       BrackettedExpression | BuiltInCall | FunctionCall
        {
          :finish => lambda { |data|
            if data[:Expression]
              # Resolve expression to the point it is either an atom or an s-exp
              res = data[:Expression]
              res = res[0] while res.is_a?(Array) && res.length == 1
              add_prod_data(:Constraint, res)
            elsif data[:BuiltInCall]
              add_prod_datum(:Constraint, data[:BuiltInCall])
            elsif data[:Function]
              add_prod_datum(:Constraint, data[:Function])
            end
          }
        }
      when :FunctionCall
        # [28]    FunctionCall              ::=       IRIref ArgList
        {
          :finish => lambda { |data|
            # Function is (func arg1 arg2 ...)
            add_prod_data(:Function, data[:IRIref] + data[:ArgList])
          }
        }
      when :ArgList
        # [29]    ArgList                   ::=       ( NIL | '(' Expression ( ',' Expression )* ')' )
        {
          :finish => lambda { |data| data.values.each {|v| add_prod_datum(:ArgList, v)} }
        }
      when :ConstructTemplate
        # [30]    ConstructTemplate ::=       '{' ConstructTriples? '}'
        {
          :finish => lambda { |data|
            if data[:triple]
              triples = data[:triple].map {|v| [:triple, v[:subject], v[:predicate], v[:object]]}
              add_prod_datum(:ConstructTemplate, triples)
            end
        
            # Append triples from ('.' ConstructTriples? )? 
            if data[:ConstructTemplate]
              add_prod_datum(:ConstructTemplate, data[:ConstructTemplate])
            end
          }
        }
      when :TriplesSameSubject
        # [32]    TriplesSameSubject ::= VarOrTerm PropertyListNotEmpty | TriplesNode PropertyList
        {
          :finish => lambda { |data| add_prod_datum(:triple, data[:triple]) }
        }
      when :PropertyListNotEmpty
        # [33]    PropertyListNotEmpty ::= Verb ObjectList ( ';' ( Verb ObjectList )? )*
        {
          :start => lambda {|data|
            subject = prod_data[:VarOrTerm] || prod_data[:TriplesNode] || prod_data[:GraphNode]
            error(nil, "Expected VarOrTerm or TriplesNode or GraphNode", :production => :PropertyListNotEmpty) if validate? && !subject
            data[:Subject] = subject
          },
          :finish => lambda {|data| add_prod_datum(:triple, data[:triple])}
        }
      when :ObjectList
        # [35]    ObjectList ::= Object ( ',' Object )*
        {
          :start => lambda { |data|
            # Called after Verb. The prod_data stack should have Subject and Verb elements
            if prod_data.has_key?(:Subject)
              data[:Subject] = prod_data[:Subject]
            else
              error(nil, "Expected Subject", :production => :ObjectList) if validate?
            end
            if prod_data.has_key?(:Verb)
              data[:Verb] = prod_data[:Verb].to_a.last
            else
              error(nil, "Expected Verb", :production => :ObjectList) if validate?
            end
          },
          :finish => lambda { |data| add_prod_datum(:triple, data[:triple]) }
        }
      when :Object
        # [36]    Object ::= GraphNode
        {
          :finish => lambda { |data|
            object = data[:VarOrTerm] || data[:TriplesNode] || data[:GraphNode]
            if object
              add_triple(:Object, :subject => prod_data[:Subject], :predicate => prod_data[:Verb], :object => object)
              add_prod_datum(:triple, data[:triple])
            end
          }
        }
      when :Verb
        # [37]    Verb ::=       VarOrIRIref | 'a'
        {
          :finish => lambda { |data| data.values.each {|v| add_prod_datum(:Verb, v)} }
        }
      when :TriplesNode
        # [38]    TriplesNode ::= Collection | BlankNodePropertyList
        #
        # Allocate Blank Node for () or []
        {
          :start => lambda { |data| data[:TriplesNode] = gen_node() },
          :finish => lambda { |data| 
            add_prod_datum(:triple, data[:triple])
            add_prod_datum(:TriplesNode, data[:TriplesNode])
          }
        }
      when :Collection
        # [40]    Collection ::= '(' GraphNode+ ')'
        {
          :start => lambda { |data| data[:Collection] = prod_data[:TriplesNode]},
          :finish => lambda { |data| expand_collection(data) }
        }
      when :GraphNode
        # [41]    GraphNode ::= VarOrTerm | TriplesNode
        {
          :finish => lambda { |data|
            term = data[:VarOrTerm] || data[:TriplesNode]
            add_prod_datum(:triple, data[:triple])
            add_prod_datum(:GraphNode, term)
          }
        }
      when :VarOrTerm
        # [42]    VarOrTerm ::= Var | GraphTerm
        {
          :finish => lambda { |data| data.values.each {|v| add_prod_datum(:VarOrTerm, v)} }
        }
      when :GraphTerm
        # [45]    GraphTerm ::= IRIref | RDFLiteral | NumericLiteral | BooleanLiteral | BlankNode | NIL
        {
          :finish => lambda { |data|
            add_prod_datum(:GraphTerm, data[:IRIref] || data[:literal] || data[:BlankNode] || data[:NIL])
          }
        }
      when :Expression
        # [46] Expression ::=       ConditionalOrExpression
        {
          :finish => lambda { |data| add_prod_datum(:Expression, data[:Expression]) }
        }
      when :ConditionalOrExpression
        # [47]    ConditionalOrExpression   ::=       ConditionalAndExpression ( '||' ConditionalAndExpression )*
        {
          :finish => lambda { |data| add_operator_expressions(:_OR, data) }
        }
      when :_OR_ConditionalAndExpression
        # This part handles the operator and the rhs of a ConditionalAndExpression
        {
          :finish => lambda { |data| accumulate_operator_expressions(:ConditionalOrExpression, :_OR, data) }
        }
      when :ConditionalAndExpression
        # [48]    ConditionalAndExpression  ::=       ValueLogical ( '&&' ValueLogical )*
        {
          :finish => lambda { |data| add_operator_expressions(:_AND, data) }
        }
      when :_AND_ValueLogical_Star
        # This part handles the operator and the rhs of a ConditionalAndExpression
        {
          :finish => lambda { |data| accumulate_operator_expressions(:ConditionalAndExpression, :_AND, data) }
        }
      when :RelationalExpression
        # [50] RelationalExpression ::= NumericExpression (
        #                                   '=' NumericExpression
        #                                 | '!=' NumericExpression
        #                                 | '<' NumericExpression
        #                                 | '>' NumericExpression
        #                                 | '<=' NumericExpression
        #                                 | '>=' NumericExpression )?
        # 
        {
          :finish => lambda { |data|
            if data[:_Compare_Numeric]
              add_prod_data(:Expression, data[:_Compare_Numeric].insert(1, *data[:Expression]))
            else
              add_prod_datum(:Expression, data[:Expression])
            end
          }
        }
      when :_Compare_NumericExpression_Opt  # ( '=' NumericExpression | '!=' NumericExpression | ... )?
        # This part handles the operator and the rhs of a RelationalExpression
        {
          :finish => lambda { |data|
            if data[:RelationalExpression]
              add_prod_datum(:_Compare_Numeric, data[:RelationalExpression] + data[:Expression])
            end
          }
        }
      when :AdditiveExpression
        # [52]    AdditiveExpression ::= MultiplicativeExpression ( '+' MultiplicativeExpression | '-' MultiplicativeExpression )*
        {
          :finish => lambda { |data| add_operator_expressions(:_Add_Sub, data) }
        }
      when :_Add_Sub_MultiplicativeExpression_Star  # ( '+' MultiplicativeExpression | '-' MultiplicativeExpression | ... )*
        # This part handles the operator and the rhs of a AdditiveExpression
        {
          :finish => lambda { |data| accumulate_operator_expressions(:AdditiveExpression, :_Add_Sub, data) }
        }
      when :MultiplicativeExpression
        # [53]    MultiplicativeExpression  ::=       UnaryExpression ( '*' UnaryExpression | '/' UnaryExpression )*
        {
          :finish => lambda { |data| add_operator_expressions(:_Mul_Div, data) }
        }
      when :_Mul_Div_UnaryExpression_Star # ( '*' UnaryExpression | '/' UnaryExpression )*
        # This part handles the operator and the rhs of a MultiplicativeExpression
        {
          # Mul or Div with prod_data[:Expression]
          :finish => lambda { |data| accumulate_operator_expressions(:MultiplicativeExpression, :_Mul_Div, data) }
        }
      when :UnaryExpression
        # [54] UnaryExpression ::=  '!' PrimaryExpression | '+' PrimaryExpression | '-' PrimaryExpression | PrimaryExpression
        {
          :finish => lambda { |data|
            case data[:UnaryExpression]
            when [:"!"], [:"+"]
              add_prod_data(:Expression, data[:UnaryExpression] + data[:Expression])
            when [:"-"]
              add_prod_data(:Expression, data[:UnaryExpression] + data[:Expression])
            else
              add_prod_datum(:Expression, data[:Expression])
            end
          }
        }
      when :PrimaryExpression
        # [55] PrimaryExpression ::= BrackettedExpression | BuiltInCall | IRIrefOrFunction | RDFLiteral | NumericLiteral | BooleanLiteral | Var
        {
          :finish => lambda { |data|
            if data[:Expression]
              add_prod_datum(:Expression, data[:Expression])
            elsif data[:BuiltInCall]
              add_prod_datum(:Expression, data[:BuiltInCall])
            elsif data[:IRIref]
              add_prod_datum(:Expression, data[:IRIref])
            elsif data[:Function]
              add_prod_datum(:Expression, data[:Function])
            elsif data[:literal]
              add_prod_datum(:Expression, data[:literal])
            elsif data[:Var]
              add_prod_datum(:Expression, data[:Var])
            end
            
            add_prod_datum(:UnaryExpression, data[:UnaryExpression]) # Keep track of this for parent UnaryExpression production
          }
        }
      when :BuiltInCall
        # [57] BuiltInCall ::= 'STR' '(' Expression ')'
        #                    | 'LANG' '(' Expression ')'
        #                    | 'LANGMATCHES' '(' Expression ',' Expression ')'
        #                    | 'DATATYPE' '(' Expression ')'
        #                    | 'BOUND' '(' Var ')'
        #                    | 'sameTerm' '(' Expression ',' Expression ')'
        #                    | 'isIRI' '(' Expression ')'
        #                    | 'isURI' '(' Expression ')'
        #                    | 'isBLANK' '(' Expression ')'
        #                    | 'isLITERAL' '(' Expression ')'
        #                    | RegexExpression
        {
          :finish => lambda { |data|
            if data[:regex]
              add_prod_datum(:BuiltInCall, [data[:regex].unshift(:regex)])
            elsif data[:BOUND]
              add_prod_datum(:BuiltInCall, [data[:Var].unshift(:bound)])
            elsif data[:BuiltInCall]
              add_prod_data(:BuiltInCall, data[:BuiltInCall] + data[:Expression])
            end
          }
        }
      when :RegexExpression
        # [58]    RegexExpression           ::=       'REGEX' '(' Expression ',' Expression ( ',' Expression )? ')'
        {
          :finish => lambda { |data| add_prod_datum(:regex, data[:Expression]) }
        }
      when :IRIrefOrFunction
        # [59]    IRIrefOrFunction          ::=       IRIref ArgList?
        {
          :finish => lambda { |data|
            if data.has_key?(:ArgList)
              # Function is (func arg1 arg2 ...)
              add_prod_data(:Function, data[:IRIref] + data[:ArgList])
            else
              add_prod_datum(:IRIref, data[:IRIref])
            end
          }
        }
      when :RDFLiteral
        # [60]    RDFLiteral ::= String ( LANGTAG | ( '^^' IRIref ) )?
        {
          :finish => lambda { |data|
            if data[:string]
              lit = data.dup
              str = lit.delete(:string).last 
              lit[:datatype] = lit.delete(:IRIref).last if lit[:IRIref]
              lit[:language] = lit.delete(:language).last if lit[:language]
              add_prod_datum(:literal, RDF::Literal.new(str, lit)) if str
            end
          }
        }
      when :NumericLiteralPositive
        # [63]    NumericLiteralPositive    ::=       INTEGER_POSITIVE | DECIMAL_POSITIVE | DOUBLE_POSITIVE
        {
          :finish => lambda { |data|
            add_prod_datum(:literal, data.values.flatten.last)
            add_prod_datum(:UnaryExpression, data[:UnaryExpression]) # Keep track of this for parent UnaryExpression production
          }
        }
      when :NumericLiteralNegative
        # [64]    NumericLiteralNegative ::= INTEGER_NEGATIVE | DECIMAL_NEGATIVE | DOUBLE_NEGATIVE
        {
          :finish => lambda { |data|
            add_prod_datum(:literal, -data.values.flatten.last)
            add_prod_datum(:UnaryExpression, data[:UnaryExpression]) # Keep track of this for parent UnaryExpression production
          }
        }
      when :IRIref
        # [67]    IRIref ::= IRI_REF | PrefixedName
        {
          :finish => lambda { |data| add_prod_datum(:IRIref, data[:iri]) }
        }
      when :PrefixedName
        # [68]    PrefixedName ::= PNAME_LN | PNAME_NS
        {
          :finish => lambda { |data| add_prod_datum(:iri, data[:PrefixedName]) }
        }
      end
    end

    # Start for production
    def onStart(prod)
      context = contexts(prod.to_sym)
      @productions << prod
      if context
        # Create a new production data element, potentially allowing handler to customize before pushing on the @prod_data stack
        progress("#{prod}(:start):#{@prod_data.length}", prod_data.to_a.to_sxp)
        data = {}
        context[:start].call(data) if context.has_key?(:start)
        @prod_data << data
      else
        progress("#{prod}(:start)", '')
      end
      #puts @prod_data.inspect
    end

    # Finish of production
    def onFinish
      prod = @productions.pop()
      context = contexts(prod.to_sym)
      if context
        # Pop production data element from stack, potentially allowing handler to use it
        data = @prod_data.pop
        context[:finish].call(data) if context.has_key?(:finish)
        progress("#{prod}(:finish):#{@prod_data.length}", prod_data.to_a.to_sxp, :depth => (@productions.length + 1))
      else
        progress("#{prod}(:finish)", '', :depth => (@productions.length + 1))
      end
    end

    # Handlers for individual tokens based on production
    def token_productions(parent_production, production)
      case parent_production
      when :_Add_Sub_MultiplicativeExpression_Star
        case production
        when :"+", :"-"
          lambda { |token| add_prod_datum(:AdditiveExpression, production) }
        end
      when :UnaryExpression
        case production
        when :"!", :"+", :"-"
          lambda { |token| add_prod_datum(:UnaryExpression, production) }
        end
      when :NumericLiteralPositive, :NumericLiteralNegative, :NumericLiteral
        case production
        when :"+", :"-"
          lambda { |token| add_prod_datum(:NumericLiteral, production) }
        end
      else
        # Generic tokens that don't depend on a particular production
        case production
        when :a
          lambda { |token| add_prod_datum(:Verb, RDF.type) }
        when :ANON
          lambda { |token| add_prod_datum(:BlankNode, gen_node()) }
        when :ASC, :DESC
          lambda { |token| add_prod_datum(:OrderDirection, token.downcase.to_sym) }
        when :BLANK_NODE_LABEL
          lambda { |token| add_prod_datum(:BlankNode, gen_node(token)) }
        when :BooleanLiteral
          lambda { |token|
            add_prod_datum(:literal, RDF::Literal.new(token, :datatype => RDF::XSD.boolean))
          }
        when :BOUND
          lambda { |token| add_prod_datum(:BOUND, :bound) }
        when :DATATYPE
          lambda { |token| add_prod_datum(:BuiltInCall, :datatype) }
        when :DECIMAL
          lambda { |token| add_prod_datum(:literal, RDF::Literal.new(token, :datatype => RDF::XSD.decimal)) }
        when :DISTINCT, :REDUCED
          lambda { |token| add_prod_datum(:DISTINCT_REDUCED, token.downcase.to_sym) }
        when :DOUBLE
          lambda { |token| add_prod_datum(:literal, RDF::Literal.new(token, :datatype => RDF::XSD.double)) }
        when :INTEGER
          lambda { |token| add_prod_datum(:literal, RDF::Literal.new(token, :datatype => RDF::XSD.integer)) }
        when :IRI_REF
          lambda { |token| add_prod_datum(:iri, uri(token)) }
        when :ISBLANK
          lambda { |token| add_prod_datum(:BuiltInCall, :isBLANK) }
        when :ISLITERAL
          lambda { |token| add_prod_datum(:BuiltInCall, :isLITERAL) }
        when :ISIRI
          lambda { |token| add_prod_datum(:BuiltInCall, :isIRI) }
        when :ISURI
          lambda { |token| add_prod_datum(:BuiltInCall, :isURI) }
        when :LANG
          lambda { |token| add_prod_datum(:BuiltInCall, :lang) }
        when :LANGMATCHES
          lambda { |token| add_prod_datum(:BuiltInCall, :langMatches) }
        when :LANGTAG
          lambda { |token| add_prod_datum(:language, token) }
        when :NIL
          lambda { |token| add_prod_datum(:NIL, RDF["nil"]) }
        when :PNAME_LN
          lambda { |token| add_prod_datum(:PrefixedName, ns(*token)) }
        when :PNAME_NS
          lambda { |token|
            add_prod_datum(:PrefixedName, ns(token, nil))    # [68] PrefixedName ::= PNAME_LN | PNAME_NS
            prod_data[:prefix] = token && token.to_sym      # [4]  PrefixDecl := 'PREFIX' PNAME_NS IRI_REF";
          }
        when :STR
          lambda { |token| add_prod_datum(:BuiltInCall, :str) }
        when :SAMETERM
          lambda { |token| add_prod_datum(:BuiltInCall, :sameTerm) }
        when :STRING_LITERAL1, :STRING_LITERAL2, :STRING_LITERAL_LONG1, :STRING_LITERAL_LONG2
          lambda { |token| add_prod_datum(:string, token) }
        when :VAR1, :VAR2       # [44]    Var ::= VAR1 | VAR2
          lambda { |token| add_prod_datum(:Var, RDF::Query::Variable.new(token)) }
        when :"*", :"/"
          lambda { |token| add_prod_datum(:MultiplicativeExpression, production) }
        when :"=", :"!=", :"<", :">", :"<=", :">="
          lambda { |token| add_prod_datum(:RelationalExpression, production) }
        when :"&&"
          lambda { |token| add_prod_datum(:ConditionalAndExpression, production) }
        when :"||"
          lambda { |token| add_prod_datum(:ConditionalOrExpression, production) }
        end
      end
    end
    
    # A token
    def onToken(prod, token)
      unless @productions.empty?
        parentProd = @productions.last
        token_production = token_productions(parentProd.to_sym, prod.to_sym)
        if token_production
          token_production.call(token)
          progress("#{prod}<#{parentProd}(:token)", "#{token}: #{prod_data.to_a.to_sxp}", :depth => (@productions.length + 1))
        else
          progress("#{prod}<#{parentProd}(:token)", token, :depth => (@productions.length + 1))
        end
      else
        error("#{parentProd}(:token)", "Token has no parent production", :production => prod)
      end
    end

    # Current ProdData element
    def prod_data; @prod_data.last; end
    
    # @param [String] str Error string
    # @param [Hash] options
    # @option options [URI, #to_s] :production
    # @option options [Token] :token
    def error(node, message, options = {})
      depth = options[:depth] || @productions.length
      node ||= options[:production]
      $stderr.puts("[#{@lineno}]#{' ' * depth}#{node}: #{message}")
      raise Error.new("Error on production #{options[:production].inspect}#{' with input ' + options[:token].inspect if options[:token]} at line #{@lineno}: #{message}", options)
    end

    ##
    # Progress output when parsing
    # @param [String] str
    def progress(node, message, options = {})
      depth = options[:depth] || @productions.length
      $stderr.puts("[#{@lineno}]#{' ' * depth}#{node}: #{message}") if @options[:progress]
    end

    ##
    # Progress output when debugging
    # @param [String] str
    def debug(node, message, options = {})
      depth = options[:depth] || @productions.length
      $stderr.puts("[#{@lineno}]#{' ' * depth}#{node}: #{message}") if @options[:debug]
    end

    # [1]     Query                     ::=       Prologue ( SelectQuery | ConstructQuery | DescribeQuery | AskQuery )
    #
    # Generate an S-Exp for the final query
    # Inputs are :BaseDecl, :PrefixDecl, and :Query
    def finalize_query(data)
      GRAPH_OUTPUTS.each do |key|
        next unless sxp = data[key]

        # Wrap in :base or :prefix or just use key
        if data[:PrefixDecl] && data[:BaseDecl] && !options[:expand_uris]
          add_prod_datum(:base, *data[:BaseDecl])
          add_prod_data(:base, data[:PrefixDecl].unshift(:prefix) + [sxp.unshift(key)])
        elsif data[:PrefixDecl] && !options[:expand_uris]
          add_prod_datum(:prefix, data[:PrefixDecl])
          add_prod_data(:prefix, sxp.unshift(key))
        elsif data[:BaseDecl] && !options[:expand_uris]
          add_prod_datum(:base, *data[:BaseDecl])
          add_prod_data(:base, sxp.unshift(key))
        else
          add_prod_datum(key, sxp)
        end
        return
      end
    end

    # [40]    Collection ::= '(' GraphNode+ ')'
    #
    # Take collection of objects and create RDF Collection using rdf:first, rdf:rest and rdf:nil
    # @param [Hash] data Production Data
    def expand_collection(data)
      # Add any triples generated from deeper productions
      add_prod_datum(:triple, data[:triple])
      
      # Create list items for each element in data[:GraphNode]
      first = col = data[:Collection]
      list = data[:GraphNode].to_a.flatten.compact
      last = list.pop

      list.each do |r|
        add_triple(:Collection, :subject => first, :predicate => RDF["first"], :object => r)
        rest = gen_node()
        add_triple(:Collection, :subject => first, :predicate => RDF["rest"], :object => rest)
        first = rest
      end
      
      if last
        add_triple(:Collection, :subject => first, :predicate => RDF["first"], :object => last)
      end
      add_triple(:Collection, :subject => first, :predicate => RDF["rest"], :object => RDF["nil"])
    end

  private

    def abbr(prodURI)
      prodURI.to_s.split('#').last
    end
  
    ##
    # @param  [Symbol, String] type_or_value
    # @return [Token]
    def accept(type_or_value)
      if (token = tokens.first) && token === type_or_value
        tokens.shift
      end
    end

    ##
    # @return [void]
    def fail
      false
    end
    alias_method :fail!, :fail

    # Add joined graphs similar to graph (union graph)* to form (union (union graph graph) graph)
    def add_graphs(production, data)
      # Iterate through expression to create binary operations
      input_prod = [:graph, :join, :leftjoin, :bgp].detect { |prod| data[prod] }
      res = data[input_prod]
      if data[production]
        while !data[production].empty?
          res = [res.unshift(input_prod), data[production].shift]
          input_prod = production
        end
      end
      add_prod_datum(input_prod, res)
    end

    # Accumulate joined graphs in for graph (union graph)* to form (union (union graph graph) graph)
    def accumulate_graphs(production, data)
      input_prod = [:graph, :join, :leftjoin, :bgp].detect { |prod| data[prod] }
      # Add [production rhs] to stack based on "production"
      add_prod_data(production, data[input_prod].unshift(input_prod)) if data[input_prod]
      add_prod_datum(production, data[production])
    end

    # Add joined expressions in for prod1 (op prod2)* to form (op (op 1 2) 3)
    def add_operator_expressions(production, data)
      # Iterate through expression to create binary operations
      res = data[:Expression]
      while data[production] && !data[production].empty?
        res = [data[production].shift + res + data[production].shift]
      end
      add_prod_datum(:Expression, res)
    end

    # Accumulate joined expressions in for prod1 (op prod2)* to form (op (op 1 2) 3)
    def accumulate_operator_expressions(operator, production, data)
      if data[operator]
        # Add [op data] to stack based on "production"
        add_prod_datum(production, [data[operator], data[:Expression]])
        # Add previous [op data] information
        add_prod_datum(production, data[production])
      else
        # No operator, forward :Expression
        add_prod_datum(:Expression, data[:Expression])
      end
    end

    # Add values to production data, values aranged as an array
    def add_prod_datum(sym, values)
      case values
      when Array
        prod_data[sym] ||= []
        debug "add_prod_datum(#{sym})", "#{prod_data[sym].inspect} += #{values.inspect}"
        prod_data[sym] += values
      when nil
        return
      else
        prod_data[sym] ||= []
        debug "add_prod_datum(#{sym})", "#{prod_data[sym].inspect} << #{values.inspect}"
        prod_data[sym] << values
      end
    end
    
    # Add values to production data, values aranged as an array
    def add_prod_data(sym, *values)
      return if values.compact.empty?
      
      prod_data[sym] ||= []
      prod_data[sym] += values
      debug "add_prod_data(#{sym})", "#{prod_data[sym].inspect} += #{values.inspect}"
    end
    
    # Generate a BNode identifier
    def gen_node(id = nil)
      unless id
        id = @options[:anon_base] = @options[:anon_base].succ
      end
      RDF::Node.new(id)
    end
    
    # Create URIs
    def uri(value, append = nil)
      value = self.base_uri ? (self.base_uri.join(value.to_s)) : RDF::URI(value)
      value = value.join(append) if append
      #value.validate! if validate? && value.respond_to?(:validate)
      #value.canonicalize! if canonicalize?
      #value = RDF::URI.intern(value) if intern?
      value
    end
    
    def ns(prefix, suffix)
      if options[:resolve_uris]
        base = prefix(prefix).to_s
        suffix = suffix.to_s.sub(/^\#/, "") if base.index("#")
        debug("ns(#{prefix.inspect})", "base: '#{base}', suffix: '#{suffix}'")
        uri(base + suffix.to_s)
      else
        "#{prefix}:#{suffix}".to_sym
      end
    end
    
    # add a statement
    #
    # @param [String] production:: Production generating triple
    # @param [RDF::Term] subject:: the subject of the statement
    # @param [RDF::Term] predicate:: the predicate of the statement
    # @param [RDF::Term, Node, Literal] object:: the object of the statement
    def add_triple(production, options)
      progress(production, "[:triple, #{options[:subject]}, #{options[:predicate]}, #{options[:object]}]")
      triples = {}
      options.each_pair do |r, v|
        if v.is_a?(Array) && v.flatten.length == 1
          v = v.flatten.first
        end
        if validate? && !v.is_a?(RDF::Term)
          error("add_triple", "Expected #{r} to be a resource, but it was #{v.inspect}",
            :production => production)
        end
        triples[r] = v
      end
      add_prod_data(:triple, triples)
    end

    instance_methods.each { |method| public method } # DEBUG

  public
    ##
    # Raised for errors during parsing.
    #
    # @example Raising a parser error
    #   raise SPARQL::Grammar::Parser::Error.new(
    #     "FIXME on line 10",
    #     :input => query, :production => '%', :lineno => 9)
    #
    # @see http://ruby-doc.org/core/classes/StandardError.html
    class Error < StandardError
      ##
      # The input string associated with the error.
      #
      # @return [String]
      attr_reader :input

      ##
      # The grammar production where the error was found.
      #
      # @return [String]
      attr_reader :production

      ##
      # The line number where the error occurred.
      #
      # @return [Integer]
      attr_reader :lineno

      ##
      # Position within line of error.
      #
      # @return [Integer]
      attr_reader :position

      ##
      # Initializes a new lexer error instance.
      #
      # @param  [String, #to_s]          message
      # @param  [Hash{Symbol => Object}] options
      # @option options [String]         :input  (nil)
      # @option options [String]         :production  (nil)
      # @option options [Integer]        :lineno (nil)
      # @option options [Integer]        :position (nil)
      def initialize(message, options = {})
        @input  = options[:input]
        @production  = options[:production]
        @lineno = options[:lineno]
        @position = options[:position]
        super(message.to_s)
      end
    end # class Error
  end # class Parser
end; end # module SPARQL::Grammar
