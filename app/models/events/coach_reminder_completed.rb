module Events
  module CoachReminderCompleted
    module Data
      class V1
        extend Core::Payload

        schema do
          reminder_id Uuid
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Coach,
      message_type: MessageTypes::Coaches::COACH_REMINDER_COMPLETED,
      version: 1
    )
  end
end
