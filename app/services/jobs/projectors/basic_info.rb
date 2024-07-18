module Jobs
  module Projectors
    class BasicInfo < Projector
      projection_stream Streams::Job

      class Projection
        extend Record

        schema do
          category Either(*Job::Categories::ALL, nil)
          employment_title Either(String, nil)
          employer_name Either(String, nil)
          employer_id Either(Uuid, nil)
          benefits_description Either(String, nil)
          responsibilities_description Either(String, nil), default: nil
          location Either(String, nil)
          employment_type Either(*Job::EmploymentTypes::ALL, nil)
          hide_job Bool()
          schedule Either(String, nil), default: nil
          work_days Either(String, nil), default: nil
          requirements_description Either(String, nil), default: nil
          industry Either(ArrayOf(Either(*Job::Industries::ALL)), nil), default: nil
        end
      end

      def init
        Projection.new(
          category: nil,
          employment_title: nil,
          employer_name: nil,
          employer_id: nil,
          benefits_description: nil,
          responsibilities_description: nil,
          location: nil,
          employment_type: nil,
          hide_job: false,
          schedule: nil,
          work_days: nil,
          requirements_description: nil,
          industry: nil
        )
      end

      on_message Events::JobCreated::V3 do |message, accumulator|
        accumulator.with(
          category: message.data.category,
          employment_title: message.data.employment_title,
          employer_name: message.data.employer_name,
          employer_id: message.data.employer_id,
          benefits_description: message.data.benefits_description,
          responsibilities_description: message.data.responsibilities_description,
          location: message.data.location,
          employment_type: message.data.employment_type,
          hide_job: message.data.hide_job,
          schedule: message.data.schedule,
          work_days: message.data.work_days,
          requirements_description: message.data.requirements_description,
          industry: message.data.industry
        )
      end

      on_message Events::JobUpdated::V2 do |message, accumulator|
        accumulator.with(
          category: message.data.category,
          employment_title: message.data.employment_title,
          benefits_description: message.data.benefits_description,
          responsibilities_description: message.data.responsibilities_description,
          location: message.data.location,
          employment_type: message.data.employment_type,
          hide_job: message.data.hide_job,
          schedule: message.data.schedule,
          work_days: message.data.work_days,
          requirements_description: message.data.requirements_description,
          industry: message.data.industry
        )
      end
    end
  end
end
