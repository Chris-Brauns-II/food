module Events
  module NotificationCreated
    module Data
      class V1
        extend Core::Payload

        schema do
          title String
          body String
          url String
        end
      end

      class V2
        extend Core::Payload

        schema do
          title String
          body String
          url String
          notification_id Uuid
        end
      end

      class V3
        extend Core::Payload

        schema do
          title String
          body String
          url String
          user_id String
          notification_id Uuid
        end
      end
    end

    V1 = Core::Schema.destroy!(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::NOTIFICATION_CREATED,
      version: 1
    )
    V2 = Core::Schema.destroy!(
      type: Core::EVENT,
      data: Data::V2,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::NOTIFICATION_CREATED,
      version: 2
    )
    V3 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V3,
      metadata: Core::Nothing,
      stream: Streams::Message,
      message_type: MessageTypes::NOTIFICATION_CREATED,
      version: 3
    )
  end
end
