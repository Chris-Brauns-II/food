module Jobs
  class CareerPathService
    extend MessageEmitter

    def self.create(job, title:, lower_limit:, upper_limit:)
      career_paths_projection = Projectors::CareerPaths.new.project(job_messages(job))

      message_service.create!(
        schema: Events::CareerPathCreated::V1,
        job_id: job.id,
        data: {
          id: SecureRandom.uuid,
          job_id: job.id,
          title:,
          lower_limit:,
          upper_limit:,
          order: career_paths_projection.paths.count
        }
      )

      nil
    end

    def self.up(career_path)
      return if career_path.order.zero?

      upper_career_path = career_path.job.career_paths.find_by!(order: career_path.order - 1)

      message_service.create!(
        schema: Events::CareerPathUpdated::V1,
        job_id: upper_career_path.job_id,
        data: {
          id: upper_career_path.id,
          order: upper_career_path.order + 1
        }
      )

      message_service.create!(
        schema: Events::CareerPathUpdated::V1,
        job_id: career_path.job_id,
        data: {
          id: career_path.id,
          order: career_path.order - 1
        }
      )
    end

    def self.down(career_path)
      return if career_path.order == career_path.job.career_paths.count - 1

      lower_career_path = career_path.job.career_paths.find_by!(order: career_path.order + 1)

      message_service.create!(
        schema: Events::CareerPathUpdated::V1,
        job_id: lower_career_path.job_id,
        data: {
          id: lower_career_path.id,
          order: lower_career_path.order - 1
        }
      )

      message_service.create!(
        schema: Events::CareerPathUpdated::V1,
        job_id: career_path.job_id,
        data: {
          id: career_path.id,
          order: career_path.order + 1
        }
      )
    end

    def self.destroy(career_path)
      job = career_path.job
      career_paths_projection = Projectors::CareerPaths.new.project(job_messages(job))
      paths = career_paths_projection.paths.select { |path| path.order > career_path.order }

      paths.each do |path|
        message_service.create!(
          schema: Events::CareerPathUpdated::V1,
          job_id: job.id,
          data: {
            id: path.id,
            order: path.order - 1
          }
        )
      end

      message_service.create!(
        schema: Events::CareerPathDestroyed::V1,
        job_id: career_path.job_id,
        data: {
          id: career_path.id
        }
      )
    end

    class << self
      private

      def job_messages(job)
        MessageService.stream_events(Streams::Job.new(job_id: job.id))
      end
    end
  end
end
