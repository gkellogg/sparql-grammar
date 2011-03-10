require File.join(File.dirname(__FILE__), 'spec_helper')
require 'strscan'

describe "README" do
  def self.read_examples
    examples = []
    readme = File.join(File.expand_path(File.dirname(__FILE__)), "..", "README.md")
    scanner = StringScanner.new(File.read(readme))
    scanner.skip_until(/^SPARQL:$/)
    until scanner.eos?
      current = {}
      current[:sparql] = scanner.scan_until(/^Result:$/)[0..-8].strip
      current[:result] = scanner.scan_until(/^SSE:$/)[0..-5].strip
      current[:sse]    = scanner.scan_until(/^(SPARQL:|Implementation Notes)$/)[0..-8].strip
      examples << current
      break if scanner.matched =~ /Implementation Notes/
    end
    examples
  end

  read_examples.each do |example|
    describe "query #{example[:sparql]}" do
      subject { parse(example[:sparql])}
      
      it "parses to #{example[:sse]}" do
        subject.should == SPARQL::Algebra.parse(example[:sse])
      end
      
      it "reproduces object description" do
        subject.should == eval(example[:result])
      end
    end
  end

  def parse(query, options = {})
    parser = SPARQL::Grammar::Parser.new(query)
    parser.parse
  end
end