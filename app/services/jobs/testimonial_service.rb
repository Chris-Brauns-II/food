module Jobs
  class TestimonialService
    extend MessageEmitter

    def self.create(job_id:, name:, title:, testimonial:, photo_url:)
      message_service.create!(
        schema: Events::TestimonialCreated::V1,
        job_id:,
        data: {
          id: SecureRandom.uuid,
          job_id:,
          name:,
          title:,
          testimonial:,
          photo_url:
        }
      )

      nil
    end

    def self.destroy(testimonial)
      message_service.create!(
        schema: Events::TestimonialDestroyed::V1,
        job_id: testimonial.job_id,
        data: {
          id: testimonial.id
        }
      )
    end
  end
end
