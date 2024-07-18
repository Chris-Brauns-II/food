module Events
  module JobCreated
    module Data
      class V1
        extend Core::Payload

        schema do
          employment_title String
          employer_id Uuid
          benefits_description String
          responsibilities_description Either(String, nil)
          location String
          employment_type Either(*Job::EmploymentTypes::ALL)
          hide_job Bool()
          schedule Either(String, nil)
          work_days Either(String, nil)
          requirements_description Either(String, nil)
          industry Either(ArrayOf(Either(*Job::Industries::ALL)), nil)
        end
      end

      class V2
        extend Core::Payload

        schema do
          employment_title String
          employer_name String
          employer_id Uuid
          benefits_description String
          responsibilities_description Either(String, nil)
          location String
          employment_type Either(*Job::EmploymentTypes::ALL)
          hide_job Bool()
          schedule Either(String, nil)
          work_days Either(String, nil)
          requirements_description Either(String, nil)
          industry Either(ArrayOf(Either(*Job::Industries::ALL)), nil)
        end
      end

      class V3
        extend Core::Payload

        schema do
          category Either(*Job::Categories::ALL)
          employment_title String
          employer_name String
          employer_id Uuid
          benefits_description String
          responsibilities_description Either(String, nil), default: nil
          location String
          employment_type Either(*Job::EmploymentTypes::ALL)
          hide_job Bool()
          schedule Either(String, nil), default: nil
          work_days Either(String, nil), default: nil
          requirements_description Either(String, nil), default: nil
          industry Either(ArrayOf(Either(*Job::Industries::ALL)), nil), default: nil
        end
      end
    end

    V1 = Core::Schema.destroy!(
      type: Core::EVENT,
      data: Data::V1,
      metadata: Core::Nothing,
      stream: Streams::Job,
      message_type: MessageTypes::Jobs::JOB_CREATED,
      version: 1
    )

    V2 = Core::Schema.destroy!(
      type: Core::EVENT,
      data: Data::V2,
      metadata: Core::Nothing,
      stream: Streams::Job,
      message_type: MessageTypes::Jobs::JOB_CREATED,
      version: 2
    )

    V3 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V3,
      metadata: Core::Nothing,
      stream: Streams::Job,
      message_type: MessageTypes::Jobs::JOB_CREATED,
      version: 3
    )
  end
end
