module Events
  module SeekerTrainingProviderCreated
    module Data
      class V1
        extend Core::Payload

        schema do
          id Uuid
          user_id String
          training_provider_id Uuid
        end
      end

      class V2
        extend Core::Payload

        schema do
          id Uuid
          user_id String
          program_id Either(String, nil)
          training_provider_id Uuid
        end
      end

      class V3
        extend Core::Payload

        schema do
          id Uuid
          status String
          program_id Either(String, nil)
          training_provider_id Uuid
        end
      end
    end

    V1 = Core::Schema.destroy!(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::TrainingProviders::SEEKER_TRAINING_PROVIDER_CREATED,
      version: 1
    )
    V2 = Core::Schema.destroy!(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Seeker,
      message_type: MessageTypes::TrainingProviders::SEEKER_TRAINING_PROVIDER_CREATED,
      version: 2
    )
    V3 = Core::Schema.destroy!(
      type: Core::EVENT,
      data: Data::V2,
      metadata: Core::Nothing,
      stream: Streams::Seeker,
      message_type: MessageTypes::TrainingProviders::SEEKER_TRAINING_PROVIDER_CREATED,
      version: 3
    )
    V4 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V3,
      metadata: Core::Nothing,
      stream: Streams::Seeker,
      message_type: MessageTypes::TrainingProviders::SEEKER_TRAINING_PROVIDER_CREATED,
      version: 4
    )
  end
end
