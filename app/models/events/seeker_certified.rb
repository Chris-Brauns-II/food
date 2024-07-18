module Events
  module SeekerCertified
    module Data
      class V1
        extend Core::Payload

        schema do
          coach_first_name Either(String, nil), default: nil
          coach_last_name Either(String, nil), default: nil
          coach_email String
          coach_id Uuid
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Seeker,
      message_type: MessageTypes::Coaches::SEEKER_CERTIFIED,
      version: 1
    )
  end
end
