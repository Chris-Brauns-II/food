module Events
  module CareerPathUpdated
    module Data
      class V1
        extend Core::Payload

        schema do
          id Uuid
          order Either(0.., nil), default: nil
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Job,
      message_type: MessageTypes::Jobs::CAREER_PATH_UPDATED,
      version: 1
    )
  end
end
