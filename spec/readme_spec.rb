require File.join(File.dirname(__FILE__), 'spec_helper')

describe "README" do
  [
    {
      :input => %q(SELECT * WHERE { ?a ?b ?c }),
      :result => 
          RDF::Query.new {
            pattern [RDF::Query::Variable.new("a"), RDF::Query::Variable.new("d"), RDF::Query::Variable.new("c")]
          },
      :sse => %q((bgp (triple ?a ?b ?c)))
    },

    {
      :input => %q(SELECT * FROM <a> WHERE { ?a ?b ?c }),
      :result =>
          RDF::Query.new {
            pattern [RDF::Query::Variable.new("a"), RDF::Query::Variable.new("d"), RDF::Query::Variable.new("c")]
          },
      :sse => %q((bgp (triple ?a ?b ?c)))
    },
    {
      :input => %q(SELECT * FROM NAMED <a> WHERE { ?a ?b ?c }),
      :result =>
          RDF::Query.new {
            pattern [RDF::Query::Variable.new("a"), RDF::Query::Variable.new("d"), RDF::Query::Variable.new("c")]
          },
      :sse => %q((bgp (triple ?a ?b ?c)))
    },
    {
      :input => %q(SELECT DISTINCT * WHERE {?a ?b ?c}),
      :result => [
        :distinct, 
        RDF::Query.new {
          pattern [RDF::Query::Variable.new("a"), RDF::Query::Variable.new("d"), RDF::Query::Variable.new("c")]
        }
      ],
      :sse => %q((distinct (bgp (triple ?a ?b ?c))))
    },
    {
      :input => %q(SELECT ?a ?b WHERE {?a ?b ?c}),
      :result => [
        :project, [RDF::Query::Variable.new("a"), RDF::Query::Variable.new("d")], 
        RDF::Query.new {
          pattern [RDF::Query::Variable.new("a"), RDF::Query::Variable.new("d"), RDF::Query::Variable.new("c")]
        }
      ],
      :sse => %q((project (?a ?b) (bgp (triple ?a ?b ?c))))
    },
    {
      :input => %q(CONSTRUCT {?a ?b ?c} WHERE {?a ?b ?c FILTER (?a)}),
      :result => [
        :fliter, RDF::Query::Variable.new("a"),
        RDF::Query.new {
          pattern [RDF::Query::Variable.new("a"), RDF::Query::Variable.new("d"), RDF::Query::Variable.new("c")]
        }
      ],
      :sse => %q((filter ?a (bgp (triple ?a ?b ?c))))
    },
    {
      :input => %q(SELECT * FROM <a> WHERE { ?a ?b ?c }),
      :result => [
        :dataset, RDF::URI("a"),
        RDF::Query.new {
          pattern [RDF::Query::Variable.new("a"), RDF::Query::Variable.new("d"), RDF::Query::Variable.new("c")]
        }
      ],
      :sse => %q((dataset <a> (bgp (triple ?a ?b ?c))))
    },
    {
      :input => %q(SELECT * FROM NAMED <a> WHERE { ?a ?b ?c }),
      :result => [
        :dataset, [:named, RDF::URI("a")],
        RDF::Query.new {
          pattern [RDF::Query::Variable.new("a"), RDF::Query::Variable.new("d"), RDF::Query::Variable.new("c")]
        }
      ],
      :sse => %q((dataset (named <a>) (bgp (triple ?a ?b ?c))))
    },
    {
      :input => %q(SELECT * WHERE {<a> <b> <c> OPTIONAL {<d> <e> <f>}}),
      :result => RDF::GroupQuery.new {
        operation = :leftjoin
        query RDF::Query.new {
          pattern [RDF::URI("a"), RDF::URI("d"), RDF::URI("c")]
        }
        query RDF::Query.new {
          pattern [RDF::URI("d"), RDF::URI("e"), RDF::URI("f")]
        },
      },
      :sse => %q((leftjoin (bgp (triple <a> <b> <c>)) (bgp (triple <d> <e> <f>))))
    },
    {
      :input => %q(SELECT * WHERE {<a> <b> <c> {<d> <e> <f>}}),
      :result => RDF::GroupQuery.new {
        query RDF::Query.new {
          pattern [RDF::URI("a"), RDF::URI("d"), RDF::URI("c")]
        }
        query RDF::Query.new {
          pattern [RDF::URI("d"), RDF::URI("e"), RDF::URI("f")]
        },
      },
      :sse => %q((join (bgp (triple <a> <b> <c>)) (bgp (triple <d> <e> <f>))))
    },
    {
      :input => %q(SELECT * WHERE {{<a> <b> <c>} UNION {<d> <e> <f>}}),
      :result => RDF::GroupQuery.new {
        operation = :union
        query RDF::Query.new {
          pattern [RDF::URI("a"), RDF::URI("d"), RDF::URI("c")]
        }
        query RDF::Query.new {
          pattern [RDF::URI("d"), RDF::URI("e"), RDF::URI("f")]
        },
      },
      :sse => %q((union (bgp (triple <a> <b> <c>)) (bgp (triple <d> <e> <f>))))
    },
  ].each do |example|
    describe "query #{example[:input]}" do
      subject { parse(example[:input])}
      if example[:sse] =~ /dataset/i
        specify { pending("Dataset output") {subject.result.should == example[:result]}}
        specify { pending("Dataset output") {subject.to_sse.should == example[:sse]}}
      elsif example[:sse] =~ /union|join/
        specify { subject.result.should == example[:result]}
        specify { subject.to_sse.should == example[:sse]}
      else
        specify { pending("#{subject.result.inspect} == #{example[:result].inspect} comparison problem") {subject.result.should == example[:result]}}
        specify { subject.to_sse.should == example[:sse]}
      end
    end
  end

  def parse(query, options = {})
    parser = SPARQL::Grammar::Parser.new(query, {:resolve_uris => true}.merge(options))
    parser.parse
    parser
  end
end