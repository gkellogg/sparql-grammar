# Extensions for RDF classes

module RDF
  class URI
    ##
    # Returns the SXP representation of this object.
    #
    # @return [String]
    def to_sxp; qname || "<#{self}>"; end
    
    # Override qname to save value for SXP serialization
    def qname=(value); @qname = value; end
    def qname; @qname; end
  end

  class Literal
    ##
    # Returns the SXP representation of a Literal.
    #
    # @return [String]
    def to_sxp
      case datatype
      when XSD.boolean, XSD.integer, XSD.double, XSD.decimal, XSD.time
        object.to_sxp
      else
        text = value.dump
        text << "@#{language}" if self.has_language?
        text << "^^#{datatype.to_sxp}" if self.has_datatype?
        text
      end
    end
  end

  class Statement
    # Transform Query into an Array form of an SXP
    # @return [Statement]
    def to_sxa
      [:triple, subject, predicate, object]
    end

    # Transform Statement into an SXP
    # @return [String]
    def to_sxp
      to_sxa.to_sxp
    end
  end
  
  class Query
    # Transform Query into an Array form of an SXP
    #
    # If Query is named, it's treated as a GroupGraphPattern, otherwise, a BGP
    #
    # @return [Array]
    def to_sxa
      res = [:bgp] + patterns
      named? ? [:graph, context, res] : res
    end
    
    # Transform Query into an SXP
    # @return [String]
    def to_sxp
      to_sxa.to_sxp
    end
  end
  
  class Query::Variable
    def to_sxp; to_s; end
  end
end