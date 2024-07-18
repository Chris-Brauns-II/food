module Events
  module PersonSearchExecuted
    module Data
      class V1
        extend Core::Payload

        schema do
          search_terms Either(String, nil)
          attributes HashOf(String => ArrayOf(String)), default: {}
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::PersonSearch,
      message_type: MessageTypes::PersonSearch::PERSON_SEARCH_EXECUTED,
      version: 1
    )
  end
end
