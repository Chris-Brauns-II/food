module Seekers
  class SkillService
    include MessageEmitter

    def initialize(seeker)
      @seeker = seeker
    end

    def create(master_skill_id:, description:)
      master_skill = MasterSkill.find(master_skill_id)

      message_service.create!(
        schema: Events::PersonSkillAdded::V1,
        person_id: seeker.id,
        data: {
          description:,
          skill_id: master_skill.id,
          name: master_skill.skill,
          type: master_skill.type
        }
      )
    end

    def update(skill, description:)
      message_service.create!(
        schema: Events::PersonSkillUpdated::V1,
        person_id: seeker.id,
        data: {
          description:,
          skill_id: skill.master_skill_id,
          name: skill.master_skill.skill,
          type: skill.master_skill.type
        }
      )
    end

    def destroy(skill)
      message_service.create!(
        schema: Events::PersonSkillRemoved::V1,
        person_id: seeker.id,
        data: {
          description: skill.description,
          skill_id: skill.master_skill_id,
          name: skill.master_skill.skill,
          type: skill.master_skill.type
        }
      )
    end

    private

    attr_reader :seeker
  end
end
