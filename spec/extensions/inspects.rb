# override several inspect functions to improve output for what we're doing

class RDF::Literal
  require 'rdf/ntriples'
  def inspect
    RDF::NTriples::Writer.serialize(self) + " R:L:(#{self.class.to_s.match(/([^:]*)$/)})"
  end
end

class RDF::URI
  def inspect
    RDF::NTriples::Writer.serialize(self)
  end
end

class RDF::Node
  def inspect
    RDF::NTriples::Writer.serialize(self) + "(#{object_id})"
  end
end

module RSpec
  module Matchers
    class MatchArray
      private
      def safe_sort(array)
        case
          when array.all?{|item| item.respond_to?(:<=>) && !item.is_a?(Hash)}
            array.sort
          else
            array
        end
      end
    end
  end
end

class RDF::Graph
  def inspect
    "\n" + dump(:n3) + "\n"
  end
end

class RDF::Query
  # Equivalence for Queries:
  #   Same Patterns
  #   Same Context
  def ==(other)
    other.is_a?(RDF::Query) && patterns == other.patterns && context == context
  end

  def inspect
    "RDF::Query(#{context ? context.to_sxp : 'nil'})#{patterns.inspect}"
  end
end

class RDF::Query::Solution
  def pretty_print(o)
#    puts "pp: #{o.inspect}"
#    o.inspect
  end
end
