module Events
  module ChatRead
    module Data
      class V1
        extend Core::Payload

        schema do
          read_by_user_id String
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Application,
      message_type: MessageTypes::Chats::CHAT_READ,
      version: 1
    )
  end
end
