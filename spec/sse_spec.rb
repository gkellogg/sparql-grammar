$:.unshift "."
require File.join(File.dirname(__FILE__), 'spec_helper')
require 'sparql/spec'

describe SPARQL::Grammar::Parser do
  describe "w3c dawg SPARQL syntax tests" do
    SPARQL::Spec.load_sparql1_0_tests.group_by(&:manifest).each do |man, tests|
      describe man.to_s.split("/")[-2] do
        tests.each do |t|
          case t.type
          when MF.QueryEvaluationTest
            it "parses #{t.name} to correct SSE" do
              query = SPARQL::Grammar.parse(t.action.query_string)
              sse = SPARQL::Algebra.parse(t.action.sse_string)
              query.should == sse
            end
          else
            it "??? #{t.name}" do
              puts t.inspect
              fail "Unknown test type #{t.type}"
            end
          end
        end
      end
    end
  end
end