module People
  module Projectors
    class EducationExperiences < Projector
      projection_stream Streams::Person

      class EducationExperience
        extend Record

        schema do
          organization_name Either(String, nil)
          title Either(String, nil)
          activities Either(String, nil)
          graduation_date Either(String, nil)
          gpa Either(String, nil)
        end
      end

      class Projection
        extend Record

        schema do
          education_experiences HashOf(String => EducationExperience)
        end
      end

      def init
        Projection.new(
          education_experiences: {}
        )
      end

      on_message Events::EducationExperienceAdded::V2 do |message, accumulator|
        new_education_experience = EducationExperience.new(
          organization_name: message.data.organization_name,
          title: message.data.title,
          activities: message.data.activities,
          graduation_date: message.data.graduation_date,
          gpa: message.data.gpa
        )

        accumulator.with(education_experiences: accumulator.education_experiences.merge({ message.data.id => new_education_experience }))
      end

      on_message Events::EducationExperienceDeleted::V2 do |message, accumulator|
        accumulator.with(education_experiences: accumulator.education_experiences.except(message.data.id))
      end
    end
  end
end
