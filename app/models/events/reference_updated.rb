module Events
  module ReferenceUpdated
    module Data
      class V1
        extend Core::Payload

        schema do
          reference_text String
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Reference,
      message_type: MessageTypes::TrainingProviders::REFERENCE_UPDATED,
      version: 1
    )
  end
end
