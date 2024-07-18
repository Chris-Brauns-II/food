module Commands
  module SendSlackMessage
    module Data
      class V1
        extend Core::Payload

        schema do
          channel String
          text String
        end
      end

      class V2
        extend Core::Payload

        schema do
          channel String
          text Either(String, nil), default: nil
          blocks Either(ArrayOf(Hash), nil), default: nil
        end

        def initialize(attributes)
          super
          raise ArgumentError unless text.present? || blocks.present?
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::COMMAND,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Message,
      message_type: MessageTypes::Contact::SEND_SLACK_MESSAGE,
      version: 1
    )
    V2 = Core::Schema.active(
      type: Core::COMMAND,
      data: Data::V2,
      metadata: Core::Nothing,
      stream: Streams::Message,
      message_type: MessageTypes::Contact::SEND_SLACK_MESSAGE,
      version: 2
    )
  end
end
