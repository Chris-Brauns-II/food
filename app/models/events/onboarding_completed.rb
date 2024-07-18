module Events
  module OnboardingCompleted
    module Data
      class V1
        extend Core::Payload

        schema do
          name Either(Hash, nil), default: nil
          experience Either(Hash, nil), default: nil
          education Either(Hash, nil), default: nil
          trainingProvider Either(Hash, nil), default: nil
          other Either(Hash, nil), default: nil
          opportunityInterests Either(Hash, nil), default: nil
        end
      end
    end

    V1 = Core::Schema.destroy!(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::Person::ONBOARDING_COMPLETED,
      version: 1
    )
    V2 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Core::Nothing,
      metadata: Core::Nothing,
      stream: Streams::Seeker,
      message_type: MessageTypes::Person::ONBOARDING_COMPLETED,
      version: 2
    )
    V3 = Core::Schema.active(
      type: Core::EVENT,
      data: Core::Nothing,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::Person::ONBOARDING_COMPLETED,
      version: 3
    )
  end
end
