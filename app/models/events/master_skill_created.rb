module Events
  module MasterSkillCreated
    module Data
      class V1
        extend Core::Payload

        schema do
          skill String
          type Either(*MasterSkill::SkillTypes::ALL)
        end
      end
    end

    V1 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::MasterSkill,
      message_type: MessageTypes::Qualifications::MASTER_SKILL_CREATED,
      version: 1
    )
  end
end
