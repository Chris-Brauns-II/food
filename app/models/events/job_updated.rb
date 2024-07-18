module Events
  module JobUpdated
    module Data
      class V1
        extend Core::Payload

        schema do
          employment_title Either(String, nil), default: nil
          benefits_description Either(String, nil), default: nil
          responsibilities_description Either(String, nil), default: nil
          location Either(String, nil), default: nil
          employment_type Either(*Job::EmploymentTypes::ALL, nil), default: nil
          hide_job Either(Bool(), nil), default: nil
          schedule Either(String, nil), default: nil
          work_days Either(String, nil), default: nil
          requirements_description Either(String, nil), default: nil
          industry Either(ArrayOf(Either(*Job::Industries::ALL)), nil), default: nil
        end
      end

      class V2
        extend Core::Payload

        schema do
          category Either(*Job::Categories::ALL)
          employment_title Either(String, nil), default: nil
          benefits_description Either(String, nil), default: nil
          responsibilities_description Either(String, nil), default: nil
          location Either(String, nil), default: nil
          employment_type Either(*Job::EmploymentTypes::ALL, nil), default: nil
          hide_job Either(Bool(), nil), default: nil
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
      message_type: MessageTypes::Jobs::JOB_UPDATED,
      version: 1
    )

    V2 = Core::Schema.active(
      type: Core::EVENT,
      data: Data::V2,
      metadata: Core::Nothing,
      stream: Streams::Job,
      message_type: MessageTypes::Jobs::JOB_UPDATED,
      version: 2
    )
  end
end
