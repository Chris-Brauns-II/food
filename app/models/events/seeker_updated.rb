module Events
  module SeekerUpdated
    module Data
      class V1
        extend Core::Payload

        schema do
          about Either(String, nil), default: nil
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Seeker,
      message_type: MessageTypes::Seekers::SEEKER_UPDATED,
      version: 1
    )
  end
end
