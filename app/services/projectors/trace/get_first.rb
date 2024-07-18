module Projectors
  module Trace
    class GetFirst
      def project(messages)
        messages
          .select { |m| m.schema == schema }
          .first
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

      attr_reader :schema
    end
  end
end
