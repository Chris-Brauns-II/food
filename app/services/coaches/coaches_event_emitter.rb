module Coaches
  class CoachesEventEmitter
    NoPersonForCoachError = Class.new(StandardError)

    def initialize(message_service:)
      @message_service = message_service
    end

    def add_attribute(person_id:, person_attribute_id:, attribute_id:, attribute_name:, attribute_values:, trace_id:) # rubocop:disable Metrics/ParameterLists
      message_service.create!(
        schema: Events::PersonAttributeAdded::V1,
        person_id:,
        trace_id:,
        data: {
          id: person_attribute_id,
          attribute_id:,
          attribute_name:,
          attribute_values:
        }
      )
    end

    def remove_attribute(person_id:, person_attribute_id:, trace_id:)
      message_service.create!(
        schema: Events::PersonAttributeRemoved::V1,
        person_id:,
        trace_id:,
        data: {
          id: person_attribute_id
        }
      )
    end

    def add_note(person_id:, originator:, note:, note_id:, trace_id:)
      message_service.create!(
        schema: Events::NoteAdded::V4,
        person_id:,
        trace_id:,
        data: {
          originator:,
          note:,
          note_id:
        }
      )
    end

    def delete_note(person_id:, originator:, note_id:, trace_id:)
      message_service.create!(
        schema: Events::NoteDeleted::V4,
        person_id:,
        trace_id:,
        data: {
          originator:,
          note_id:
        }
      )
    end

    def modify_note(person_id:, originator:, note_id:, note:, trace_id:)
      message_service.create!(
        schema: Events::NoteModified::V4,
        person_id:,
        trace_id:,
        data: {
          originator:,
          note_id:,
          note:
        }
      )
    end

    def certify(person_id:, coach:, trace_id:)
      user = User.find(coach.user_id)

      message_service.create!(
        schema: Events::PersonCertified::V1,
        person_id:,
        trace_id:,
        data: {
          coach_id: coach.id,
          coach_email: coach.email,
          coach_first_name: user.first_name,
          coach_last_name: user.last_name
        }
      )
    end

    def recommend_job(person_id:, job_id:, coach:, trace_id:)
      message_service.create!(
        schema: Events::JobRecommended::V3,
        person_id:,
        trace_id:,
        data: {
          coach_id: coach.id,
          job_id:
        }
      )
    end

    def update_barriers(person_id:, barriers:, trace_id:)
      message_service.create!(
        schema: Events::BarrierUpdated::V3,
        person_id:,
        trace_id:,
        data: {
          barriers:
        }
      )
    end

    def assign_coach(person_id:, coach_id:, trace_id:)
      message_service.create!(
        schema: Events::CoachAssigned::V3,
        person_id:,
        trace_id:,
        data: {
          coach_id:
        }
      )
    end

    def update_skill_level(person_id:, skill_level:, trace_id:)
      message_service.create!(
        schema: Events::SkillLevelUpdated::V3,
        person_id:,
        trace_id:,
        data: {
          skill_level:
        }
      )
    end

    def create_reminder(coach:, note:, reminder_at:, trace_id:, person_id: nil)
      message_task_id = SecureRandom.uuid
      coach_person_id = User.find(coach.user_id)&.person_id

      raise NoPersonForCoachError if coach_person_id.blank?

      message_service.create!(
        schema: Events::CoachReminderScheduled::V2,
        coach_id: coach.id,
        trace_id:,
        data: {
          reminder_id: SecureRandom.uuid,
          person_id:,
          note:,
          message_task_id:,
          reminder_at:
        }
      )

      message_service.create!(
        schema: Commands::ScheduleTask::V1,
        task_id: message_task_id,
        trace_id:,
        data: {
          execute_at: reminder_at - 1.hour,
          command: message_service.build(
            schema: Commands::SendMessage::V2,
            trace_id:,
            message_id: SecureRandom.uuid,
            data: {
              person_id: coach_person_id,
              title: "Reminder",
              body: "At #{reminder_at.to_fs(:long)}: #{note}",
              url: person_id && "#{ENV.fetch('FRONTEND_URL', nil)}/coaches/contexts/#{person_id}"
            },
            metadata: {
              requestor_type: Requestor::Kinds::USER,
              requestor_id: coach.user_id
            }
          )
        },
        metadata: {
          requestor_type: Requestor::Kinds::USER,
          requestor_id: coach.user_id
        }
      )
    end

    def complete_reminder(coach:, reminder_id:, trace_id:)
      message_service.create!(
        schema: Events::CoachReminderCompleted::V1,
        coach_id: coach.id,
        trace_id:,
        data: {
          reminder_id:
        }
      )
    end

    private

    attr_reader :message_service
  end
end
