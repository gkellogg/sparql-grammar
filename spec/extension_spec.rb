require File.join(File.dirname(__FILE__), 'spec_helper')

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
  
end
