module Attributes
  class AttributesQuery
    def self.all
      Attribute.all
    end

    def self.find(attribute_id)
      Attribute.find(attribute_id)
    end
  end
end
