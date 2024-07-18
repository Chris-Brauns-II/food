module Commands
  module ScheduleTask
    module Data
      class V1
        extend Core::Payload

        schema do
          execute_at ActiveSupport::TimeWithZone, coerce: Core::TimeZoneCoercer
          command Message
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::COMMAND,
      data: Data::V1,
      metadata: Core::RequestorMetadata::V1,
      stream: Streams::Task,
      message_type: MessageTypes::Infrastructure::SCHEDULE_TASK,
      version: 1
    )
  end
end
