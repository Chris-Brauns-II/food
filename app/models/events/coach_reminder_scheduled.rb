module Events
  module CoachReminderScheduled
    module Data
      class V1
        extend Core::Payload

        schema do
          reminder_id Uuid
          context_id Either(String, nil)
          note String
          message_task_id Uuid
          reminder_at ActiveSupport::TimeWithZone, coerce: Core::TimeZoneCoercer
        end
      end

      class V2
        extend Core::Payload

        schema do
          reminder_id Uuid
          person_id Either(Uuid, nil)
          note String
          message_task_id Uuid
          reminder_at ActiveSupport::TimeWithZone, coerce: Core::TimeZoneCoercer
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Coach,
      message_type: MessageTypes::Coaches::COACH_REMINDER_SCHEDULED,
      version: 1
    )
    V2 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V2,
      metadata: Core::Nothing,
      stream: Streams::Coach,
      message_type: MessageTypes::Coaches::COACH_REMINDER_SCHEDULED,
      version: 2
    )
  end
end
