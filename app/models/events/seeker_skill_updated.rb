module Events
  module SeekerSkillUpdated
    module Data
      class V1
        extend Core::Payload

        schema do
          skill_id Uuid
          name String
          description Either(String, nil)
          type Either(*MasterSkill::SkillTypes::ALL)
        end
      end
    end

    V1 = Core::Schema.inactive(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Seeker,
      message_type: MessageTypes::Seekers::SEEKER_SKILL_UPDATED,
      version: 1
    )
  end
end
