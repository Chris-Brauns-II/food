module Events
  module JobTagCreated
    module Data
      class V1
        extend Core::Payload

        schema do
          id Uuid
          job_id Uuid
          tag_id Uuid
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Job,
      message_type: MessageTypes::Jobs::JOB_TAG_CREATED,
      version: 1
    )
  end
end
