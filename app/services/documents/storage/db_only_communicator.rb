module Documents
  module Storage
    class DbOnlyCommunicator
      def initialize
        @storage = DbCommunicator.new
      end

      def store_document(storage_kind:, id:, file_data:, file_name:) # rubocop:disable Lint/UnusedMethodArgument
        storage.store_document(id:, file_data:, file_name:)
      end

      def retrieve_document(storage_kind:, identifier:) # rubocop:disable Lint/UnusedMethodArgument
        storage.retrieve_document(identifier:)
      end

      private

      attr_reader :storage
    end
  end
end
