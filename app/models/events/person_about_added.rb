module Events
  module PersonAboutAdded
    module Data
      class V1
        extend Core::Payload

        schema do
          about Either(String, nil)
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::Person::PERSON_ABOUT_ADDED,
      version: 1
    )
  end
end
