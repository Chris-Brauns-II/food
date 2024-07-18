module Projectors
  module Streams
    class HasOccurred
      def project(messages)
        messages.detect { |m| m.schema == schema }.present?
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
