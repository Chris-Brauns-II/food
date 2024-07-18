module Documents
  module Storage
    class RealCommunicator
      UnknownStorageKindError = Class.new(StandardError)

      def initialize
        @db_storage = DbCommunicator.new
      end

      def store_document(id:, storage_kind:, file_data:, file_name:)
        get_storage(storage_kind).store_document(id:, file_data:, file_name:)
      end

      def retrieve_document(identifier:, storage_kind:)
        get_storage(storage_kind).retrieve_document(identifier:)
      end

      private

      def get_storage(storage_kind)
        case storage_kind
        when StorageKind::POSTGRES
          @db_storage
        else
          raise UnknownStorageKindError, storage_kind
        end
      end
    end
  end
end
