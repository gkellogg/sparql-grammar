# Extensions for RDF classes
module RDF
  class URI
    ##
    # Returns the SXP representation of this object.
    #
    # @return [String]
    def to_sxp; "<#{self}>"; end
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
        text = value.gsub(/[\n\t\r\b\f\"\'\\]/) do |c|
          case c
          when "\n" then "\\n"
          when "\t" then "\\t"
          when "\r" then "\\r"
          when "\b" then "\\b"
          when "\f" then "\\f"
          when "\"" then "\\\""
          when "\'" then "\\'"
          when "\\" then "\\\\"
          else c
          end
        end
        text << "@#{language}" if self.has_language?
        text << "^^#{datatype.to_sxp}" if self.has_datatype?
        text
      end
    end
  end
end