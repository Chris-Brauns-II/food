module Events
  module NotificationMarkedRead
    module Data
      class V1
        extend Core::Payload

        schema do
          notification_id Integer
        end
      end

      class V2
        extend Core::Payload

        schema do
          notification_ids ArrayOf(Uuid)
        end
      end
    end

    V1 = Core::Schema.destroy!(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::NOTIFICATIONS_MARKED_READ,
      version: 1
    )
    V2 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V2,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::NOTIFICATIONS_MARKED_READ,
      version: 2
    )
  end
end
