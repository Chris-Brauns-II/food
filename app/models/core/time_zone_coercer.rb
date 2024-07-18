module Core
  module TimeZoneCoercer
    def self.call(value)
      if value.is_a?(DateTime) || value.is_a?(Time)
        value.in_time_zone
      elsif value.is_a?(String)
        Time.zone.parse(value)
      else
        value
      end
    end
  end
end
