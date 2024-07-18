module Events
  module JobAttributeUpdated
    module Data
      class V1
        extend Core::Payload

        schema do
          id Uuid
          acceptible_set ArrayOf(String)
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Job,
      message_type: MessageTypes::Jobs::JOB_ATTRIBUTE_UPDATED,
      version: 1
    )
  end
end
