module Coaches
  class CoachesAggregator < MessageConsumer
    def reset_for_replay
      PersonNote.delete_all
      PersonApplication.delete_all
      PersonJobRecommendation.delete_all
      Reminder.delete_all
      Coaches::PersonAttribute.delete_all
      PersonContext.delete_all
      Barrier.delete_all
      Coach.delete_all
      Job.delete_all
      FeedEvent.delete_all
    end

    on_message Events::BarrierAdded::V1, :sync do |message|
      Barrier.create!(
        barrier_id: message.data.barrier_id,
        name: message.data.name
      )
    end

    on_message Events::CoachAdded::V1, :sync do |message|
      Coach.create!(
        id: message.data.coach_id,
        user_id: message.stream.id,
        email: message.data.email,
        assignment_weight: 0
      )
    end

    on_message Events::CoachAssignmentWeightAdded::V1 do |message|
      coach = Coach.find(message.stream.id)
      coach.update!(assignment_weight: message.data.weight)
    end

    on_message Events::CoachReminderScheduled::V2, :sync do |message|
      coach = Coach.find(message.stream.id)

      Reminder.create!(
        id: message.data.reminder_id,
        coach:,
        person_id: message.data.person_id,
        note: message.data.note,
        state: ReminderState::SET,
        message_task_id: message.data.message_task_id,
        reminder_at: message.data.reminder_at
      )
    end

    on_message Events::CoachReminderCompleted::V1, :sync do |message|
      reminder = Reminder.find(message.data.reminder_id)

      reminder.update!(
        state: ReminderState::COMPLETE
      )
    end

    on_message Events::PersonAttributeAdded::V1, :sync do |message|
      person_context = PersonContext.find(message.stream.id)
      seeker_attribute = PersonAttribute.find_or_initialize_by(id: message.data.id)

      seeker_attribute.update!(
        person_context:,
        attribute_id: message.data.attribute_id,
        name: message.data.attribute_name,
        values: message.data.attribute_values
      )
    end

    on_message Events::PersonAttributeRemoved::V1, :sync do |message|
      PersonAttribute.find(message.data.id).destroy!
    end

    on_message Events::JobCreated::V3 do |message|
      Job.create!(
        job_id: message.stream_id,
        employment_title: message.data.employment_title,
        employer_name: message.data.employer_name,
        hide_job: message.data.hide_job
      )
    end

    on_message Events::JobUpdated::V2 do |message|
      job = Job.find_by!(job_id: message.stream_id)

      job.update!(
        employment_title: message.data.employment_title,
        hide_job: message.data.hide_job
      )
    end

    on_message Events::ApplicantStatusUpdated::V6 do |message|
      data = message.data
      person_context = PersonContext.find(data.seeker_id)

      first_name = data.applicant_first_name
      last_name = data.applicant_last_name
      email = data.applicant_email
      status = data.status

      application = PersonApplication.find_or_initialize_by(
        person_context:,
        id: message.stream.id
      )

      application.update!(
        status: data.status,
        employer_name: data.employer_name,
        job_id: data.job_id,
        employment_title: data.employment_title
      )

      FeedEvent.create!(
        context_id: person_context.id,
        occurred_at: message.occurred_at,
        seeker_email: email,
        description:
          "#{first_name} #{last_name}'s application for #{data.employment_title} at #{data.employer_name} has been updated to #{status}."
      )
    end

    on_message Events::BarrierUpdated::V3, :sync do |message|
      person_context = PersonContext.find(message.stream.id)

      person_context.update!(barriers: message.data.barriers)
    end

    on_message Events::CoachAssigned::V3, :sync do |message|
      person_context = PersonContext.find(message.stream.id)
      coach = Coach.find(message.data.coach_id)

      person_context.update!(assigned_coach: coach.email)
    end

    on_message Events::JobRecommended::V3, :sync do |message|
      person_context = PersonContext.find(message.stream.id)
      job = Coaches::Job.find_by!(job_id: message.data.job_id)

      PersonJobRecommendation.create!(
        person_context:,
        coaches_coaches_id: message.data.coach_id,
        job:
      )
    end

    on_message Events::PersonCertified::V1, :sync do |message|
      person_context = PersonContext.find(message.stream.id)
      person_context.update!(certified_by: Coach.find(message.data.coach_id).email)
    end

    on_message Events::NoteDeleted::V4, :sync do |message|
      PersonNote.find(message.data.note_id).destroy
    end

    on_message Events::NoteModified::V4, :sync do |message|
      PersonNote.find(message.data.note_id).update!(note: message.data.note)
    end

    on_message Events::NoteAdded::V4, :sync do |message|
      person_context = PersonContext.find(message.stream.id)
      person_context.update!(last_contacted_at: message.occurred_at)

      PersonNote.create!(
        person_context:,
        note_taken_at: message.occurred_at,
        note_taken_by: message.data.originator,
        id: message.data.note_id,
        note: message.data.note
      )
    end

    on_message Events::BasicInfoAdded::V1 do |message|
      person_context = PersonContext.find(message.stream.id)

      person_context.update!(
        first_name: message.data.first_name,
        last_name: message.data.last_name,
        phone_number: message.data.phone_number,
        email: message.data.email
      )
    end

    on_message Events::PersonAdded::V1 do |message|
      PersonContext.create!(
        id: message.stream_id,
        email: message.data.email,
        phone_number: message.data.phone_number,
        person_captured_at: message.occurred_at,
        first_name: message.data.first_name,
        last_name: message.data.last_name,
        last_active_on: message.occurred_at,
        kind: PersonContext::Kind::LEAD
      )
    end

    on_message Events::PersonSourced::V1 do |message|
      return if message.data.source_kind != People::SourceKind::COACH

      person_context = PersonContext.find(message.stream.id)
      coach = Coach.find(message.data.source_identifier)

      person_context.update!(
        captured_by: coach.email
      )
    end

    on_message Events::PersonAssociatedToUser::V1 do |message|
      person_context = PersonContext.find(message.stream.id)

      person_context.update!(
        user_id: message.data.user_id,
        kind: PersonContext::Kind::SEEKER
      )
    end

    on_message Events::SessionStarted::V1 do |message|
      person_context = PersonContext.find_by(user_id: message.stream.id)
      return if person_context.nil?

      person_context.update!(last_active_on: message.occurred_at)
    end
  end
end
