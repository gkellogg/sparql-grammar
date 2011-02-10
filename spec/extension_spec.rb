require File.join(File.dirname(__FILE__), 'spec_helper')

describe "RDF::Node#to_sxp" do
  specify { RDF::Node.new("a").to_sxp.should == %q("_:a")}
end

describe "RDF::Literal#to_sxp" do
  specify { RDF::Literal.new("a").to_sxp.should == %q("a")}
  specify { RDF::Literal.new("a", :language => "en-us").to_sxp.should == %q("a"@en-us)}
  specify { RDF::Literal.new("a", :datatype => RDF::XSD.string).to_sxp.should == %q("a"^^<http://www.w3.org/2001/XMLSchema#string>)}
end

describe "RDF::URI#to_sxp" do
  specify { RDF::URI("http://example.com").to_sxp.should == %q(<http://example.com>)}
end

describe "RDF::Query::Variable#to_sxp" do
  specify { RDF::Query::Variable.new("a").to_sxp.should == %q(?a)}
end

describe "RDF::Statement#to_sxp" do
  {
    RDF::Statement.new(RDF::URI("a"), RDF::URI("b"), RDF::URI("c")) => %q((triple <a> <b> <c>)),
    RDF::Statement.new(RDF::URI("a"), RDF::Query::Variable.new("b"), RDF::Literal.new("c")) =>
      %q((triple <a> ?b "c"))
  }.each_pair do |st, sxp|
    it "generates #{sxp} given #{st}" do
      st.to_sxp.should == sxp
    end
  end
end

describe RDF::Query do
  subject { RDF::Query.new }

  describe "#context" do
    it "returns nil by default" do
      subject.context.should be_nil
    end
    
    it "sets and returns a context" do
      subject.context = RDF.first
      subject.context.should == RDF.first
    end
  end
  
  describe "#named?" do
    it "returns false with no context" do
      subject.named?.should be_false
    end
    
    it "returns true with a context" do
      subject.context = RDF.first
      subject.named?.should be_true
    end
  end
  
  describe "#unnamed?" do
    it "returns true with no context" do
      subject.unnamed?.should be_true
    end
    
    it "returns false with a context" do
      subject.context = RDF.first
      subject.unnamed?.should be_false
    end
  end
  
  describe "#+" do
    it "returns a new RDF::Query" do
      rhs = RDF::Query.new
      q = subject + rhs
      q.should_not be_equal(subject)
      q.should_not be_equal(rhs)
    end
    
    it "contains patterns from each query in order" do
      subject.pattern [RDF.first, RDF.second, RDF.third]
      rhs = RDF::Query.new
      subject.pattern [RDF.a, RDF.b, RDF.c]
      q = subject + rhs
      q.patterns.should == [[RDF.first, RDF.second, RDF.third], [RDF.a, RDF.b, RDF.c]]
    end
  end
  
  describe "#to_sxp" do
    {
      RDF::Query.new {
        pattern [RDF::URI("a"), RDF::URI("b"), RDF::URI("c")]
      } => %q((bgp (triple <a> <b> <c>))),
      RDF::Query.new {
        pattern [RDF::URI("a"), RDF::URI("b"), RDF::URI("c")]
        pattern [RDF::URI("d"), RDF::URI("e"), RDF::URI("f")]
      } => %q((bgp (triple <a> <b> <c>) (triple <d> <e> <f>))),
      RDF::Query.new(nil, :context => RDF::URI("http://example.com/")) {
        pattern [RDF::URI("a"), RDF::URI("b"), RDF::URI("c")]
      } => %q((graph <http://example.com/> (bgp (triple <a> <b> <c>)))),
      RDF::Query.new() {} => %q((bgp))
    }.each_pair do |st, sxp|
      it "generates #{sxp} given #{st.inspect}" do
        st.to_sxp.should == sxp
      end
    end
  end
end

describe RDF::GroupQuery do
  subject { RDF::GroupQuery.new }
  before(:each) do
    @q1 = RDF::Query.new(nil, :context => "foo")
    @q2 = RDF::Query.new(nil, :context => "bar")
  end

  describe ".new" do
    it "sets operation to :join by default" do
      subject.operation.should == :join
    end
    
    it "contains no queries by default" do
      subject.queries.should == []
    end
    
    it "contains queries" do
      gq = RDF::GroupQuery.new([@q1, @q2])
      gq.queries.should == [@q1, @q2]
    end
    
    it "adds filter" do
      gq = RDF::GroupQuery.new([@q1, @q2], :join, :filter => [:foo])
      gq.queries.should == [@q1, @q2]
      gq.filter.should == [:foo]
    end
  end
  
  describe "#query" do
    it "adds a query" do
      subject.query(@q1)
      subject.queries.should == [@q1]
    end
  end
  
  describe "#<<" do
    it "adds a query" do
      subject << @q1
      subject.queries.should == [@q1]
    end
  end
  
  describe "#unshift" do
    it "prepends a query" do
      subject << @q2
      subject.unshift(@q1)
      subject.queries.should == [@q1, @q2]
    end
  end
  
  describe "#to_sxp" do
    {
      RDF::GroupQuery.new {
        query RDF::Query.new([RDF::Statement.new(RDF::URI("a"), RDF::URI("b"), RDF::URI("c"))])
      } => %q((join (bgp (triple <a> <b> <c>)))),
      RDF::GroupQuery.new {
        query RDF::Query.new([RDF::Statement.new(RDF::URI("a"), RDF::URI("b"), RDF::URI("c"))])
        query RDF::Query.new([RDF::Statement.new(RDF::URI("d"), RDF::URI("e"), RDF::URI("f"))])
      } => %q((join (bgp (triple <a> <b> <c>)) (bgp (triple <d> <e> <f>)))),
      RDF::GroupQuery.new([], :union) {
        query RDF::Query.new([RDF::Statement.new(RDF::URI("a"), RDF::URI("b"), RDF::URI("c"))])
        query RDF::Query.new([RDF::Statement.new(RDF::URI("d"), RDF::URI("e"), RDF::URI("f"))])
      } => %q((union (bgp (triple <a> <b> <c>)) (bgp (triple <d> <e> <f>)))),
      RDF::GroupQuery.new {
        query RDF::Query.new(nil, :context => "foo")
      } => %q((join (graph "foo" (bgp)))),
      RDF::GroupQuery.new() {} => %q((join))
    }.each_pair do |st, sxp|
      it "generates #{sxp} given #{st.inspect}" do
        st.to_sxp.should == sxp
      end
    end
  end
end

