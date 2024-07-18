module People
  class PersonAggregator < MessageConsumer
    def reset_for_replay
      OtherExperience.delete_all
      EducationExperience.delete_all
      PersonalExperience.delete_all
      ApplicantStatus.delete_all
      Applicant.delete_all
      ProfileSkill.delete_all
      Story.delete_all
      OnboardingSession.delete_all
      Seeker.delete_all
    end

    on_message Events::PersonAdded::V1 do |message|
      Seeker.create!(
        id: message.stream.id,
        first_name: message.data.first_name,
        last_name: message.data.last_name,
        email: message.data.email,
        phone_number: message.data.phone_number
      )
    end

    on_message Events::PersonAssociatedToUser::V1 do |message|
      Seeker.update!(message.stream.id, user_id: message.data.user_id)
    end

    on_message Events::PersonAboutAdded::V1, :sync do |message|
      Seeker.update!(message.stream.id, about: message.data.about)
    end

    on_message Events::ZipAdded::V2, :sync do |message|
      Seeker.update!(message.stream.id, zip_code: message.data.zip_code)
    end

    on_message Events::BasicInfoAdded::V1, :sync do |message|
      Seeker.update!(
        message.stream.id,
        first_name: message.data.first_name,
        last_name: message.data.last_name,
        phone_number: message.data.phone_number,
        email: message.data.email
      )
    end

    # Job experience
    on_message Events::ExperienceAdded::V2, :sync do |message|
      other_expereince = OtherExperience.find_or_initialize_by(id: message.data.id)

      other_expereince.update!(
        seeker_id: message.stream.id,
        organization_name: message.data.organization_name,
        position: message.data.position,
        start_date: message.data.start_date,
        end_date: message.data.end_date,
        description: message.data.description,
        is_current: message.data.is_current
      )
    end

    on_message Events::ExperienceRemoved::V2, :sync do |message|
      OtherExperience.find(message.data.id).destroy!
    end

    # Stories
    on_message Events::StoryCreated::V2, :sync do |message|
      Story.create!(
        id: message.data.id,
        prompt: message.data.prompt,
        seeker_id: message.stream.id,
        response: message.data.response
      )
    end

    on_message Events::StoryUpdated::V2, :sync do |message|
      story = Story.find(message.data.id)

      story.update!(
        prompt: message.data.prompt,
        response: message.data.response
      )
    end

    on_message Events::StoryDestroyed::V2, :sync do |message|
      Story.find(message.data.id).destroy!
    end

    on_message Events::ApplicantStatusUpdated::V6, :sync do |message|
      application = Applicant.find_or_initialize_by(
        id: message.stream.id
      )

      application.update!(
        job_id: message.data.job_id,
        seeker_id: message.data.seeker_id
      )

      application.applicant_statuses.create!(
        id: SecureRandom.uuid,
        status: message.data.status
      )
    end

    on_message Events::ElevatorPitchCreated::V2, :sync do |message|
      applicant = Applicant.find_by!(
        job_id: message.data.job_id,
        seeker_id: message.stream_id
      )

      applicant.update!(
        elevator_pitch: message.data.pitch
      )
    end

    # Ed experience
    on_message Events::EducationExperienceAdded::V2, :sync do |message|
      education_experience = EducationExperience.find_or_initialize_by(id: message.data.id)

      education_experience.update!(
        seeker_id: message.stream.id,
        id: message.data.id,
        organization_name: message.data.organization_name,
        title: message.data.title,
        activities: message.data.activities,
        graduation_date: message.data.graduation_date,
        gpa: message.data.gpa
      )
    end

    on_message Events::EducationExperienceDeleted::V2, :sync do |message|
      EducationExperience.find(message.data.id).destroy!
    end

    # Personal experience
    on_message Events::PersonalExperienceAdded::V2, :sync do |message|
      personal_experience = PersonalExperience.find_or_initialize_by(id: message.data.id)

      personal_experience.update!(
        seeker_id: message.stream.id,
        activity: message.data.activity,
        description: message.data.description,
        start_date: message.data.start_date,
        end_date: message.data.end_date
      )
    end

    on_message Events::PersonalExperienceRemoved::V2, :sync do |message|
      PersonalExperience.find(message.data.id).destroy!
    end

    on_message Events::PersonSkillAdded::V1, :sync do |message|
      ProfileSkill.create!(
        id: SecureRandom.uuid,
        seeker_id: message.stream.id,
        description: message.data.description,
        master_skill_id: message.data.skill_id
      )
    end

    on_message Events::PersonSkillUpdated::V1, :sync do |message|
      skill = ProfileSkill.find_by!(seeker_id: message.stream.id, master_skill_id: message.data.skill_id)

      skill.update!(description: message.data.description)
    end

    on_message Events::PersonSkillRemoved::V1, :sync do |message|
      ProfileSkill.find_by!(seeker_id: message.stream.id, master_skill_id: message.data.skill_id).destroy!
    end

    on_message Events::OnboardingStarted::V2, :sync do |message|
      OnboardingSession.create!(
        id: SecureRandom.uuid,
        seeker_id: message.stream.id,
        started_at: message.occurred_at
      )
    end

    on_message Events::OnboardingCompleted::V3, :sync do |message|
      onboarding_session = OnboardingSession.find_by(seeker_id: message.stream.id)

      if onboarding_session.present?
        onboarding_session.update!(
          completed_at: message.occurred_at
        )
      else
        OnboardingSession.create!(
          id: SecureRandom.uuid,
          seeker_id: message.stream.id,
          started_at: message.occurred_at,
          completed_at: message.occurred_at
        )
      end
    end
  end
end
