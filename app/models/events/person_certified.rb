module Events
  module PersonCertified
    module Data
      class V1
        extend Core::Payload

        schema do
          coach_first_name Either(String, nil)
          coach_last_name Either(String, nil)
          coach_email String
          coach_id Uuid
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::Person::PERSON_CERTIFIED,
      version: 1
    )
  end
end
