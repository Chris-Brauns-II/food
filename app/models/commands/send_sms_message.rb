module Commands
  module SendSmsMessage
    module Data
      class V1
        extend Core::Payload

        schema do
          phone_number String
          message String
        end
      end
    end

    V1 = Core::Schema.destroy!(
      type: Core::COMMAND,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Seeker,
      message_type: MessageTypes::Contact::SEND_SMS_MESSAGE,
      version: 1
    )
    V2 = Core::Schema.destroy!(
      type: Core::COMMAND,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Phone,
      message_type: MessageTypes::Contact::SEND_SMS_MESSAGE,
      version: 2
    )
    V3 = Core::Schema.active(
      type: Core::COMMAND,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Message,
      message_type: MessageTypes::Contact::SEND_SMS_MESSAGE,
      version: 3
    )
  end
end
