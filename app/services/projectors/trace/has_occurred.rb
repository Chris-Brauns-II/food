module Projectors
  module Trace
    class HasOccurred
      def project(messages)
        messages.detect { |m| m.schema == schema }.present?
      end

      def initialize(schema:)
        @schema = schema
      end

      def self.project(trace_id:, schema:)
        messages = MessageService.trace_id_events(trace_id)
        instance = new(schema:)
        instance.project(messages)
      end

      private

      attr_reader :schema, :trace_id
    end
  end
end
