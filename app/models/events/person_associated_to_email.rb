module Events
  module PersonAssociatedToEmail
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
      stream: Streams::Email,
      message_type: MessageTypes::Email::PERSON_ASSOCIATED_TO_EMAIL,
      version: 1
    )
  end
end
