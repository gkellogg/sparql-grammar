$:.unshift "."
require File.join(File.dirname(__FILE__), 'spec_helper')

describe SPARQL::Grammar::Parser do
  describe "w3c dawg SPARQL syntax tests" do
    require 'dawg_test'

    {
      :syntax1  => Fixtures::SPARQL::Syn1,
      :syntax2  => Fixtures::SPARQL::Syn2,
      :syntax3  => Fixtures::SPARQL::Syn3,
      :syntax4  => Fixtures::SPARQL::Syn4,
      :syntax5  => Fixtures::SPARQL::Syn5,
    }.each_pair do |suite, tests|
      describe suite do
        tests.each do |t|
          specify "#{t.name}" do
            #puts t.inspect
            SPARQL::Grammar::Parser.new(Kernel.open(t.action)).parse
          end
        end
      end
    end
  end
end