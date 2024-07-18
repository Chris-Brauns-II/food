module Events
  module PassReasonAdded
    module Data
      class V1
        extend Core::Payload

        schema do
          description String
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::PassReason,
      message_type: MessageTypes::Jobs::PASS_REASON_ADDED,
      version: 1
    )
  end
end
