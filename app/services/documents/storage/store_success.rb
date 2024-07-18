module Documents
  module Storage
    class StoreSuccess
      extend Record

      schema do
        storage_kind Either(*StorageKind::ALL)
        storage_identifier String
      end
    end
  end
end
