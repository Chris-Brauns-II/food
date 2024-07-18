module Jobs
  class LearnedSkillService
    extend MessageEmitter

    def self.create(job, master_skill_id)
      message_service.create!(
        schema: Events::LearnedSkillCreated::V1,
        job_id: job.id,
        data: {
          id: SecureRandom.uuid,
          job_id: job.id,
          master_skill_id:
        }
      )

      nil
    end

    def self.destroy(learned_skill)
      message_service.create!(
        schema: Events::LearnedSkillDestroyed::V1,
        job_id: learned_skill.job_id,
        data: {
          id: learned_skill.id
        }
      )
    end
  end
end
