module Events
  module SkillLevelUpdated
    module Data
      class V1
        extend Core::Payload

        schema do
          skill_level String
        end
      end
    end

    V1 = Core::Schema.destroy!(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Seeker,
      message_type: MessageTypes::Coaches::SKILL_LEVEL_UPDATED,
      version: 1
    )
    V2 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Coaches::SeekerContext,
      message_type: MessageTypes::Coaches::SKILL_LEVEL_UPDATED,
      version: 2
    )
    V3 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Person,
      message_type: MessageTypes::Coaches::SKILL_LEVEL_UPDATED,
      version: 3
    )
  end
end
