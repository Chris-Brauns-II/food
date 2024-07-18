module Events
  module StoryUpdated
    module Data
      class V1
        extend Core::Payload

        schema do
          id Uuid
          prompt String
          response String
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Seeker,
      message_type: MessageTypes::Person::STORY_UPDATED,
      version: 1
    )
    V2 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::Person::STORY_UPDATED,
      version: 2
    )
  end
end
