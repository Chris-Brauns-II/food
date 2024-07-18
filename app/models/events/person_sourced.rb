module Events
  module PersonSourced
    module Data
      class V1
        extend Core::Payload

        schema do
          source_kind Either(*People::SourceKind::ALL)
          source_identifier String
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::Person::PERSON_SOURCED,
      version: 1
    )
  end
end
