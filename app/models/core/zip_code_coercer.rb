module Core
  class ZipCodeCoercer
    def self.call(value)
      return nil if value == ""

      value
    end
  end
end
