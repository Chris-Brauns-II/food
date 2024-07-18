module Coaches
  class CoachesReactor < MessageReactor
    def can_replay?
      true
    end

    on_message Commands::AssignCoach::V2 do |message|
      return unless Projectors::Streams::HasOccurred.project(
        schema: Events::PersonAdded::V1,
        stream: message.stream
      )

      return if Events::CoachAdded::V1.all_messages.none? { |m| m.data.coach_id == message.data.coach_id }

      message_service.create_once_for_trace!(
        schema: Events::CoachAssigned::V3,
        stream: message.stream,
        data: {
          coach_id: message.data.coach_id
        }
      )
    end

    on_message Events::PersonAdded::V1 do |message|
      coach_id = CoachAssignmentService.round_robin_assignment

      return if coach_id.nil?

      message_service.create_once_for_trace!(
        trace_id: message.trace_id,
        stream: message.stream,
        schema: Commands::AssignCoach::V2,
        data: {
          coach_id:
        }
      )
    end

    on_message Events::PersonSourced::V1 do |message|
      return if message.data.source_kind != People::SourceKind::COACH

      message_service.create_once_for_trace!(
        trace_id: message.trace_id,
        stream: message.stream,
        schema: Commands::AssignCoach::V2,
        data: {
          coach_id: message.data.source_identifier
        }
      )
    end

    on_message Events::CoachReminderCompleted::V1 do |message|
      reminder = MessageService
                 .stream_events(message.stream)
                 .detect { |m| m.schema == Events::CoachReminderScheduled::V2 && message.data.reminder_id == m.data.reminder_id }

      return if reminder.nil?

      message_service.create_once_for_trace!(
        schema: Commands::CancelTask::V1,
        trace_id: message.trace_id,
        task_id: reminder.data.message_task_id,
        data: Core::Nothing,
        metadata: {
          requestor_type: Requestor::Kinds::COACH,
          requestor_id: message.stream.id
        }
      )
    end

    on_message Events::JobRecommended::V3 do |message|
      job_id = message.data.job_id

      message_service.create_once_for_trace!(
        schema: Commands::SendMessage::V2,
        message_id: SecureRandom.uuid,
        trace_id: message.trace_id,
        data: {
          person_id: message.stream.id,
          title: "From your SkillArc career coach",
          body: "Check out this job",
          url: "#{ENV.fetch('FRONTEND_URL', nil)}/jobs/#{job_id}"
        },
        metadata: {
          requestor_type: Requestor::Kinds::COACH,
          requestor_id: message.data.coach_id
        }
      )
    end
  end
end
