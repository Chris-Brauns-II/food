module Analytics
  class AnalyticsAggregator < MessageConsumer
    def reset_for_replay
      FactCandidate.delete_all
      FactApplication.delete_all
      FactJobVisibility.delete_all
      FactPersonViewed.delete_all
      FactCoachAction.delete_all
      DimPerson.delete_all
      DimJobOrder.delete_all
      DimJob.delete_all
      DimUser.delete_all
      DimEmployer.delete_all
    end

    on_message Events::PersonAssociatedToUser::V1 do |message|
      user = DimUser.find_by!(user_id: message.data.user_id)

      DimPerson.where(person_id: message.stream.person_id).update_all(analytics_dim_user_id: user.id, kind: DimPerson::Kind::SEEKER)
    end

    on_message Events::UserCreated::V1 do |message|
      data = message.data

      DimUser.create!(
        user_id: message.stream.user_id,
        email: data.email,
        kind: DimUser::Kind::USER,
        first_name: data.first_name,
        last_name: data.last_name,
        user_created_at: message.occurred_at
      )
    end

    on_message Events::BasicInfoAdded::V1 do |message|
      DimPerson.where(person_id: message.stream.person_id).update_all(
        first_name: message.data.first_name,
        last_name: message.data.last_name,
        phone_number: message.data.phone_number,
        email: message.data.email
      )
    end

    on_message Events::PersonAdded::V1 do |message|
      DimPerson.create!(
        person_id: message.stream.person_id,
        email: message.data.email,
        first_name: message.data.first_name,
        last_name: message.data.last_name,
        person_added_at: message.occurred_at,
        kind: DimPerson::Kind::LEAD
      )
    end

    on_message Events::OnboardingCompleted::V3 do |message|
      DimPerson.where(person_id: message.stream.person_id).update_all(onboarding_completed_at: message.occurred_at)
    end

    on_message Events::SessionStarted::V1 do |message|
      DimUser.where(user_id: message.stream.user_id).update_all(last_active_at: message.occurred_at)
    end

    on_message Events::CoachAdded::V1 do |message|
      DimUser.where(user_id: message.stream.user_id).update_all(kind: DimUser::Kind::COACH, coach_id: message.data.coach_id)
    end

    on_message Events::EmployerInviteAccepted::V2 do |message|
      DimUser.where(user_id: message.data.user_id).update_all(kind: DimUser::Kind::RECRUITER)
    end

    on_message Events::TrainingProviderInviteAccepted::V2 do |message|
      DimUser.where(user_id: message.data.user_id).update_all(kind: DimUser::Kind::TRAINING_PROVIDER)
    end

    on_message Events::JobCreated::V3 do |message|
      employer = DimEmployer.find_by(employer_id: message.data.employer_id)

      dim_job = DimJob.create!(
        job_id: message.stream.job_id,
        category: message.data.category,
        employer_name: message.data.employer_name,
        employment_title: message.data.employment_title,
        employment_type: message.data.employment_type,
        job_created_at: message.occurred_at,
        dim_employer: employer
      )

      unless message.data.hide_job
        Analytics::FactJobVisibility.create!(
          dim_job:,
          visible_starting_at: message.occurred_at
        )
      end
    end

    on_message Events::JobUpdated::V2 do |message|
      dim_job = Analytics::DimJob.find_by!(job_id: message.stream.job_id)

      dim_job.update!(
        category: message.data.category,
        employment_title: message.data.employment_title,
        employment_type: message.data.employment_type
      )

      job_visibility = Analytics::FactJobVisibility.find_by(dim_job:, visible_ending_at: nil)

      return if message.data.hide_job.nil?

      # If we have an existing visible job fact without and end date
      # and we now have an update for hiding the job, we update the end date
      if job_visibility.present? && message.data.hide_job == true # rubocop:disable Style/IfUnlessModifier
        job_visibility.update!(visible_ending_at: message.occurred_at)
      end

      # If we don't ahve an existing visible job fact without and end date
      # and we now have an update where we are showing the job we create
      # a new visibility record
      if job_visibility.blank? && message.data.hide_job == false # rubocop:disable Style/IfUnlessModifier
        Analytics::FactJobVisibility.create!(dim_job:, visible_starting_at: message.occurred_at)
      end
    end

    on_message JobOrders::Events::Added::V1 do |message|
      dim_job = DimJob.find_by!(job_id: message.data.job_id)

      DimJobOrder.create!(
        job_order_id: message.stream.id,
        order_opened_at: message.occurred_at,
        employer_name: dim_job.employer_name,
        employment_title: dim_job.employment_title,
        dim_job:
      )
    end

    on_message JobOrders::Events::Stalled::V1 do |message|
      DimJobOrder.where(job_order_id: message.stream.id).update_all(closed_at: nil, closed_status: nil)
    end

    on_message JobOrders::Events::CandidatesScreened::V1 do |message|
      DimJobOrder.where(job_order_id: message.stream.id).update_all(closed_at: nil, closed_status: nil)
    end

    on_message JobOrders::Events::Filled::V1 do |message|
      DimJobOrder.where(job_order_id: message.stream.id).update_all(closed_at: message.occurred_at, closed_status: JobOrders::ClosedStatus::FILLED)
    end

    on_message JobOrders::Events::NotFilled::V1 do |message|
      DimJobOrder.where(job_order_id: message.stream.id).update_all(closed_at: message.occurred_at, closed_status: JobOrders::ClosedStatus::NOT_FILLED)
    end

    on_message JobOrders::Events::OrderCountAdded::V1 do |message|
      DimJobOrder.where(job_order_id: message.stream.id).update_all(order_count: message.data.order_count)
    end

    on_message JobOrders::Events::CandidateAdded::V3 do |message|
      dim_person = DimPerson.find_by!(person_id: message.data.person_id)
      dim_job_order = DimJobOrder.find_by!(job_order_id: message.stream.id)

      fact_candidate = FactCandidate.find_or_initialize_by(dim_job_order:, dim_person:)
      fact_candidate.status = JobOrders::CandidateStatus::ADDED
      fact_candidate.first_name = dim_person.first_name
      fact_candidate.last_name = dim_person.last_name
      fact_candidate.email = dim_person.email
      fact_candidate.employer_name = dim_job_order.employer_name
      fact_candidate.employment_title = dim_job_order.employment_title
      fact_candidate.terminal_status_at = nil

      if fact_candidate.new_record?
        fact_candidate.order_candidate_number = dim_job_order.fact_candidates.count + 1
        fact_candidate.added_at = message.occurred_at
      end

      fact_candidate.save!
    end

    on_message JobOrders::Events::CandidateHired::V2 do |message|
      dim_person = DimPerson.find_by!(person_id: message.data.person_id)
      dim_job_order = DimJobOrder.find_by!(job_order_id: message.stream.id)

      FactCandidate.find_by!(dim_job_order:, dim_person:).update!(status: JobOrders::CandidateStatus::HIRED, terminal_status_at: message.occurred_at)
    end

    on_message JobOrders::Events::CandidateRecommended::V2 do |message|
      dim_person = DimPerson.find_by!(person_id: message.data.person_id)
      dim_job_order = DimJobOrder.find_by!(job_order_id: message.stream.id)

      FactCandidate.find_by!(dim_job_order:, dim_person:).update!(status: JobOrders::CandidateStatus::RECOMMENDED, terminal_status_at: nil)
    end

    on_message JobOrders::Events::CandidateScreened::V1 do |message|
      dim_person = DimPerson.find_by!(person_id: message.data.person_id)
      dim_job_order = DimJobOrder.find_by!(job_order_id: message.stream.id)

      FactCandidate.find_by!(dim_job_order:, dim_person:).update!(status: JobOrders::CandidateStatus::SCREENED, terminal_status_at: nil)
    end

    on_message JobOrders::Events::CandidateRescinded::V2 do |message|
      dim_person = DimPerson.find_by!(person_id: message.data.person_id)
      dim_job_order = DimJobOrder.find_by!(job_order_id: message.stream.id)

      FactCandidate.find_by!(dim_job_order:, dim_person:).update!(status: JobOrders::CandidateStatus::RESCINDED, terminal_status_at: message.occurred_at)
    end

    on_message Events::EmployerCreated::V1 do |message|
      DimEmployer.create!(
        employer_id: message.stream.employer_id,
        name: message.data.name
      )
    end

    on_message Events::EmployerUpdated::V1 do |message|
      DimEmployer.where(employer_id: message.stream.id).update_all(name: message.data.name)
    end

    on_message Events::ApplicantStatusUpdated::V6 do |message|
      data = message.data
      fact_application = Analytics::FactApplication.find_by(application_id: message.stream.id)

      if fact_application.present?
        fact_application.update!(status: data.status, application_updated_at: message.occurred_at)
      else
        dim_person = Analytics::DimPerson.find_by!(person_id: data.seeker_id)
        dim_job = Analytics::DimJob.find_by!(job_id: data.job_id)
        application_number = (dim_person.fact_applications.pluck(:application_number).max || 0) + 1

        Analytics::FactApplication.create!(
          dim_job:,
          dim_person:,
          application_number:,
          status: data.status,
          application_opened_at: message.occurred_at,
          application_id: message.stream.id,
          application_updated_at: message.occurred_at
        )
      end
    end

    on_message Events::PersonViewed::V1 do |message|
      dim_user_viewer = Analytics::DimUser.find_by!(user_id: message.stream.user_id)
      dim_person_viewed = Analytics::DimPerson.find_by!(person_id: message.data.person_id)

      Analytics::FactPersonViewed.create!(
        dim_user_viewer:,
        dim_person_viewed:,
        viewed_at: message.occurred_at,
        viewing_context: Analytics::FactPersonViewed::Contexts::PUBLIC_PROFILE
      )
    end

    on_message Events::PersonViewedInCoaching::V1 do |message|
      dim_user_viewer = Analytics::DimUser.find_by!(coach_id: message.stream.coach_id)
      dim_person_viewed = DimPerson.find_by(person_id: message.data.person_id)

      Analytics::FactPersonViewed.create!(
        dim_user_viewer:,
        dim_person_viewed:,
        viewed_at: message.occurred_at,
        viewing_context: Analytics::FactPersonViewed::Contexts::COACHES_DASHBOARD
      )
    end

    on_message Events::NoteAdded::V4 do |message|
      note_action(
        person_id: message.stream.person_id,
        originator: message.data.originator,
        action: Analytics::FactCoachAction::Actions::NOTE_ADDED,
        occurred_at: message.occurred_at
      )
    end

    on_message Events::NoteModified::V4 do |message|
      note_action(
        person_id: message.stream.person_id,
        originator: message.data.originator,
        action: Analytics::FactCoachAction::Actions::NOTE_MODIFIED,
        occurred_at: message.occurred_at
      )
    end

    on_message Events::NoteDeleted::V4 do |message|
      note_action(
        person_id: message.stream.person_id,
        originator: message.data.originator,
        action: Analytics::FactCoachAction::Actions::NOTE_DELETED,
        occurred_at: message.occurred_at
      )
    end

    on_message Events::JobRecommended::V3 do |message|
      dim_user_executor = Analytics::DimUser.find_by!(coach_id: message.data.coach_id)
      dim_person_target = Analytics::DimPerson.find_by!(person_id: message.stream.person_id)

      Analytics::FactCoachAction.create!(
        dim_user_executor:,
        dim_person_target:,
        action: Analytics::FactCoachAction::Actions::JOB_RECOMMENDED,
        action_taken_at: message.occurred_at
      )
    end

    on_message Events::PersonCertified::V1 do |message|
      dim_user_executor = Analytics::DimUser.find_by!(coach_id: message.data.coach_id)
      dim_person_target = Analytics::DimPerson.find_by!(person_id: message.stream.person_id)

      Analytics::FactCoachAction.create!(
        dim_user_executor:,
        dim_person_target:,
        action: Analytics::FactCoachAction::Actions::SEEKER_CERTIFIED,
        action_taken_at: message.occurred_at
      )
    end

    private

    def note_action(person_id:, originator:, action:, occurred_at:)
      dim_user_executor = Analytics::DimUser.find_by(email: originator)
      return if dim_user_executor.blank?

      dim_person_target = DimPerson.find_by!(person_id:)
      return if dim_person_target.blank?

      Analytics::FactCoachAction.create!(
        dim_user_executor:,
        dim_person_target:,
        action:,
        action_taken_at: occurred_at
      )
    end
  end
end
