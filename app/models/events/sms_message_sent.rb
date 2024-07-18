module Events
  module SmsMessageSent
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
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Phone,
      message_type: MessageTypes::Contact::SMS_MESSAGE_SENT,
      version: 1
    )
    V2 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Message,
      message_type: MessageTypes::Contact::SMS_MESSAGE_SENT,
      version: 2
    )
  end
end
