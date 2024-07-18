module Events
  module ReferenceCreated
    module Data
      class V1
        extend Core::Payload

        schema do
          author_training_provider_profile_id Uuid
          reference_text String
          seeker_id Uuid
        end
      end

      class V2
        extend Core::Payload

        schema do
          author_training_provider_profile_id Uuid
          training_provider_id Uuid
          reference_text String
          seeker_id Uuid
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Reference,
      message_type: MessageTypes::TrainingProviders::REFERENCE_CREATED,
      version: 1
    )
    V2 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V2,
      metadata: Core::Nothing,
      stream: Streams::Reference,
      message_type: MessageTypes::TrainingProviders::REFERENCE_CREATED,
      version: 2
    )
  end
end
