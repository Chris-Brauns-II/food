module Events
  module CareerPathCreated
    module Data
      class V1
        extend Core::Payload

        schema do
          id Uuid
          job_id Uuid
          title Either(String, nil), default: nil
          lower_limit Either(String, nil), default: nil
          upper_limit Either(String, nil), default: nil
          order 0..
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Job,
      message_type: MessageTypes::Jobs::CAREER_PATH_CREATED,
      version: 1
    )
  end
end
