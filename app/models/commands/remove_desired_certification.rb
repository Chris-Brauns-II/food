module Commands
  module RemoveDesiredCertification
    module Data
      class V1
        extend Core::Payload

        schema do
          id Uuid
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::COMMAND,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Job,
      message_type: MessageTypes::Jobs::REMOVE_DESIRED_CERTIFICATION,
      version: 1
    )
  end
end
