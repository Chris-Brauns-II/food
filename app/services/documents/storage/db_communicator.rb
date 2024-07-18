module Documents
  module Storage
    class DbCommunicator
      def store_document(id:, file_data:, file_name:)
        Document.create!(
          id:,
          file_data:,
          file_name:
        )

        StoreSuccess.new(
          storage_kind: StorageKind::POSTGRES,
          storage_identifier: id
        )
      end

      def retrieve_document(identifier:)
        document = Document.find(identifier)

        RetrievalSuccess.new(
          file_name: document.file_name,
          file_data: document.file_data,
          stored_at: document.created_at
        )
      end
    end
  end
end
