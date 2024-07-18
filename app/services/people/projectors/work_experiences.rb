module People
  module Projectors
    class WorkExperiences < Projector
      projection_stream ::Streams::Person

      class WorkExperience
        extend Record

        schema do
          organization_name Either(String, nil)
          position Either(String, nil)
          start_date Either(String, nil)
          end_date Either(String, nil)
          description Either(String, nil)
          is_current Bool()
        end
      end

      class Projection
        extend Record

        schema do
          work_experiences HashOf(String => WorkExperience)
        end
      end

      def init
        Projection.new(
          work_experiences: {}
        )
      end

      on_message Events::ExperienceAdded::V2 do |message, accumulator|
        new_work_experience = WorkExperience.new(
          organization_name: message.data.organization_name,
          position: message.data.position,
          start_date: message.data.start_date,
          end_date: message.data.end_date,
          is_current: message.data.is_current || false,
          description: message.data.description
        )

        accumulator.with(work_experiences: accumulator.work_experiences.merge({ message.data.id => new_work_experience }))
      end

      on_message Events::ExperienceRemoved::V2 do |message, accumulator|
        accumulator.with(work_experiences: accumulator.work_experiences.except(message.data.id))
      end
    end
  end
end
