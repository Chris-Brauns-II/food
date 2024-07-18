module Commands
  module StartOnboarding
    module Data
      class V1
        extend Core::Payload

        schema do
          user_id String
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::COMMAND,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Seeker,
      message_type: MessageTypes::Person::START_ONBOARDING,
      version: 1
    )
    V2 = Core::Schema.active(
      type: Core::COMMAND,
      data: Core::Nothing,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::Person::START_ONBOARDING,
      version: 2
    )
  end
end
