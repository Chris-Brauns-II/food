module Jobs
  class JobPhotosService
    extend MessageEmitter

    def self.create(job, photo_url)
      message_service.create!(
        schema: Events::JobPhotoCreated::V1,
        job_id: job.id,
        data: {
          id: SecureRandom.uuid,
          job_id: job.id,
          photo_url:
        }
      )

      nil
    end

    def self.destroy(job_photo)
      message_service.create!(
        schema: Events::JobPhotoDestroyed::V1,
        job_id: job_photo.job_id,
        data: {
          id: job_photo.id
        }
      )
    end
  end
end
