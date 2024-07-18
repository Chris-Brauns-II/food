module Jobs
  class JobsReactor < MessageReactor
    def can_replay?
      true
    end

    def create_job_attribute(job_id:, attribute_id:, acceptible_set:)
      attribute_name = Attributes::Attribute.find(attribute_id).name

      message_service.create!(
        schema: Events::JobAttributeCreated::V1,
        job_id:,
        data: {
          id: SecureRandom.uuid,
          attribute_name:,
          attribute_id:,
          acceptible_set:
        }
      )
    end

    def update_job_attribute(job_id:, job_attribute_id:, acceptible_set:)
      job_attribute = JobAttribute.find(job_attribute_id)

      message_service.create!(
        schema: Events::JobAttributeUpdated::V1,
        job_id:,
        data: {
          id: job_attribute.id,
          acceptible_set:
        }
      )
    end

    def destroy_job_attribute(job_id:, job_attribute_id:)
      job_attribute = JobAttribute.find(job_attribute_id)

      message_service.create!(
        schema: Events::JobAttributeDestroyed::V1,
        job_id:,
        data: {
          id: job_attribute.id
        }
      )
    end

    on_message Commands::AddDesiredCertification::V1, :sync do |message|
      messages = MessageService.stream_events(message.stream).select { |m| m.occurred_at <= message.occurred_at }

      return unless ::Projectors::Streams::HasOccurred.new(schema: Events::JobCreated::V3).project(messages)

      status = Projectors::CertificationStatus.new.project(messages)

      return if status.current_certifications.any? { |_, value| value == message.data.master_certification_id }

      message_service.create_once_for_trace!(
        trace_id: message.trace_id,
        stream: message.stream,
        schema: Events::DesiredCertificationCreated::V1,
        data: {
          id: message.data.id,
          job_id: message.stream.id,
          master_certification_id: message.data.master_certification_id
        }
      )
    end

    on_message Commands::RemoveDesiredCertification::V1, :sync do |message|
      messages = MessageService.stream_events(message.stream).select { |m| m.occurred_at <= message.occurred_at }

      return unless ::Projectors::Streams::HasOccurred.new(schema: Events::JobCreated::V3).project(messages)

      status = Projectors::CertificationStatus.new.project(messages)

      return unless status.current_certifications.any? { |key, _| key == message.data.id }

      message_service.create_once_for_trace!(
        trace_id: message.trace_id,
        stream: message.stream,
        schema: Events::DesiredCertificationDestroyed::V1,
        data: {
          id: message.data.id
        }
      )
    end

    on_message Commands::CreateEmployer::V1, :sync do |message|
      message_service.create_once_for_stream!(
        trace_id: message.trace_id,
        stream: message.stream,
        schema: Events::EmployerCreated::V1,
        data: {
          name: message.data.name,
          location: message.data.location,
          bio: message.data.bio,
          logo_url: message.data.logo_url
        }
      )
    end

    on_message Commands::UpdateEmployer::V1, :sync do |message|
      messages = MessageService.stream_events(message.stream).select { |m| m.occurred_at <= message.occurred_at }

      return unless ::Projectors::Streams::HasOccurred.new(schema: Events::EmployerCreated::V1).project(messages)

      message_service.create_once_for_trace!(
        trace_id: message.trace_id,
        stream: message.stream,
        schema: Events::EmployerUpdated::V1,
        data: {
          name: message.data.name,
          location: message.data.location,
          bio: message.data.bio,
          logo_url: message.data.logo_url
        }
      )
    end
  end
end
