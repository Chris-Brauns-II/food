module Projectors
  module Streams
    class GetFirst
      def project(messages)
        messages
          .select { |m| m.schema == schema }
          .first
      end

      def initialize(schema:)
        @schema = schema
      end

      def self.project(stream:, schema:)
        messages = MessageService.stream_events(stream)
        instance = new(schema:)
        instance.project(messages)
      end

      private

      attr_reader :schema
    end
  end
end
