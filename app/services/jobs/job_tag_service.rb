module Jobs
  class JobTagService
    extend MessageEmitter

    def self.create(job, tag)
      message_service.create!(
        schema: Events::JobTagCreated::V1,
        job_id: job.id,
        data: {
          id: SecureRandom.uuid,
          job_id: job.id,
          tag_id: tag.id
        }
      )

      nil
    end

    def self.destroy(job_tag)
      message_service.create!(
        schema: Events::JobTagDestroyed::V2,
        job_id: job_tag.job_id,
        data: {
          job_id: job_tag.job_id,
          job_tag_id: job_tag.id,
          tag_id: job_tag.tag_id
        }
      )
    end
  end
end
