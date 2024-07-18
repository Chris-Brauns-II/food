module Events
  module PersonTrainingProviderAdded
    module Data
      class V1
        extend Core::Payload

        schema do
          id Uuid
          status String
          program_id Either(String, nil)
          training_provider_id Uuid
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::TrainingProviders::PERSON_TRAINING_PROVIDER_ADDED,
      version: 1
    )
  end
end
