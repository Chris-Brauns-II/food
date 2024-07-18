module Events
  module PersonAssociatedToPhoneNumber
    module Data
      class V1
        extend Core::Payload

        schema do
          person_id Uuid
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Phone,
      message_type: MessageTypes::Phone::PERSON_ASSOCIATED_TO_PHONE_NUMBER,
      version: 1
    )
  end
end
