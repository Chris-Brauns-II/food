module Documents
  module Storage
    class RetrievalSuccess
      extend Record

      schema do
        file_name String
        file_data String
        stored_at ActiveSupport::TimeWithZone, coerce: Core::TimeZoneCoercer
      end
    end
  end
end
