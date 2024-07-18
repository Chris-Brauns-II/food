module Events
  module JobTagDestroyed
    module Data
      class V1
        extend Core::Payload

        schema do
          job_tag_id Uuid
        end
      end

      class V2
        extend Core::Payload

        schema do
          job_id Uuid
          job_tag_id Uuid
          tag_id Uuid
        end
      end
    end

    V1 = Core::Schema.destroy!(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Job,
      message_type: MessageTypes::Jobs::JOB_TAG_DELETED,
      version: 1
    )
    V2 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V2,
      metadata: Core::Nothing,
      stream: Streams::Job,
      message_type: MessageTypes::Jobs::JOB_TAG_DELETED,
      version: 2
    )
  end
end
