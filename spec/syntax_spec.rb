$:.unshift "."
require File.join(File.dirname(__FILE__), 'spec_helper')
require 'sparql/spec'

describe SPARQL::Grammar::Parser do
  describe "w3c dawg SPARQL syntax tests" do
    SPARQL::Spec.load_sparql1_0_syntax_tests.group_by(&:manifest).each do |man, tests|
      describe man.to_s.split("/")[-2] do
        tests.each do |t|
          case t.type
          when MF.PositiveSyntaxTest
            it "parses #{t.name}" do
              SPARQL::Grammar.parse(t.action.query_string).should be_a(SPARQL::Algebra::Operator)
            end
          when MF.NegativeSyntaxTest
            it "throws error for #{t.name}" do
              lambda {SPARQL::Grammar.parse(t.action.query_string)}.should raise_error(SPARQL::Grammar::Parser::Error)
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