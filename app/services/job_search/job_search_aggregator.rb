module JobSearch
  class JobSearchAggregator < MessageConsumer
    def reset_for_replay
      SavedJob.delete_all
      Application.delete_all
      Job.delete_all
      Employer.delete_all
    end

    on_message Events::EmployerCreated::V1 do |message|
      Employer.create!(
        id: message.stream.id,
        logo_url: message.data.logo_url
      )
    end

    on_message Events::EmployerUpdated::V1 do |message|
      Employer.update!(
        message.stream.id,
        logo_url: message.data.logo_url
      )

      Job.where(employer_id: message.stream.id).update_all(employer_logo_url: message.data.logo_url) # rubocop:disable Rails/SkipsModelValidations
    end

    on_message Events::JobCreated::V3 do |message|
      data = message.data

      employer = Employer.find(data.employer_id)

      Job.create!(
        category: data.category,
        employer_logo_url: employer.logo_url,
        employment_title: data.employment_title,
        employment_type: data.employment_type,
        employer_name: data.employer_name,
        hidden: data.hide_job,
        location: data.location,
        industries: data.industry,
        job_id: message.stream.job_id,
        employer_id: data.employer_id
      )
    end

    on_message Events::JobUpdated::V2 do |message|
      job = Job.find_by!(job_id: message.stream.job_id)

      data = message.data
      job.update!(
        category: data.category,
        employment_title: data.employment_title,
        employment_type: data.employment_type,
        hidden: data.hide_job,
        location: data.location,
        industries: data.industry
      )
    end

    on_message Events::JobTagCreated::V1 do |message|
      job = Job.find_by!(job_id: message.stream.job_id)

      # TODO: we should probably aggregate these tags as well
      tag_name = Projectors::Streams::GetFirst.project(
        schema: Events::TagCreated::V1,
        stream: Streams::Tag.new(tag_id: message.data.tag_id)
      ).data.name

      job.update!(tags: job.tags.to_set.add(tag_name).to_a)
    end

    on_message Events::JobTagDestroyed::V2 do |message|
      job = Job.find_by!(job_id: message.stream.job_id)
      tag_name = Projectors::Streams::GetFirst.project(
        schema: Events::TagCreated::V1,
        stream: Streams::Tag.new(tag_id: message.data.tag_id)
      ).data.name

      job.update!(tags: job.tags.to_set.delete(tag_name).to_a)
    end

    on_message Events::CareerPathCreated::V1 do |message|
      messages = MessageService.stream_events(message.stream)
      starting_path = Jobs::Projectors::CareerPaths.new.project(messages).paths.detect { |m| m.order.zero? }
      job = Job.find_by!(job_id: message.stream.job_id)

      job.update!(
        starting_lower_pay: starting_path&.lower_limit.to_i,
        starting_upper_pay: starting_path&.upper_limit.to_i
      )
    end

    on_message Events::CareerPathUpdated::V1 do |message|
      messages = MessageService.stream_events(message.stream)
      starting_path = Jobs::Projectors::CareerPaths.new.project(messages).paths.detect { |m| m.order.zero? }
      job = Job.find_by!(job_id: message.stream.job_id)

      job.update!(
        starting_lower_pay: starting_path&.lower_limit.to_i,
        starting_upper_pay: starting_path&.upper_limit.to_i
      )
    end

    on_message Events::ApplicantStatusUpdated::V6, :sync do |message|
      data = message.data
      job = Job.find_by!(job_id: data.job_id)
      application = Application.find_or_initialize_by(application_id: message.stream.application_id, search_job: job)

      application.update!(
        status: data.status,
        job_id: data.job_id,
        seeker_id: data.seeker_id
      )
    end

    on_message Events::ElevatorPitchCreated::V2, :sync do |message|
      data = message.data
      application = Application.find_by(job_id: data.job_id, seeker_id: message.stream.id)
      return unless application

      application.update!(elevator_pitch: data.pitch)
    end

    on_message Events::JobSaved::V1, :sync do |message|
      data = message.data
      job = Job.find_by!(job_id: data.job_id)
      SavedJob.find_or_create_by(search_job_id: job.id, user_id: message.stream.user_id)
    end

    on_message Events::JobUnsaved::V1, :sync do |message|
      data = message.data
      job = Job.find_by!(job_id: data.job_id)
      SavedJob.find_by(search_job_id: job.id, user_id: message.stream.user_id)&.destroy
    end
  end
end
