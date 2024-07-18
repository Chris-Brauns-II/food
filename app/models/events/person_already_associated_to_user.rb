module Events
  module PersonAlreadyAssociatedToUser
    module Data
      class V1
        extend Core::Payload

        schema do
          user_id String
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::Person::PERSON_ALREADY_ASSOCIATED_TO_USER,
      version: 1
    )
  end
end
