module Events
  module JobOwnerAssigned
    module Data
      class V1
        extend Core::Payload

        schema do
          job_id Uuid
          owner_email String
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::User,
      message_type: MessageTypes::Employers::JOB_OWNER_ASSIGNED,
      version: 1
    )
  end
end
