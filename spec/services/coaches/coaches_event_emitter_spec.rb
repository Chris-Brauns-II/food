require 'rails_helper'

RSpec.describe Coaches::CoachesEventEmitter do
  let(:user_id) { "9f769972-c41c-4b58-a056-bffb714ea24d" }
  let(:seeker_id) { "75372772-49dc-4884-b4ae-1d408e030aa4" }
  let(:note_id) { "78f22f6c-a770-46fc-a83c-1ad6cda4b8f9" }
  let(:trace_id) { "42000038-7e82-48ca-ac18-72ebc08bdbeb" }
  let(:person_id) { SecureRandom.uuid }
  let(:coach_id) { SecureRandom.uuid }
  let(:updated_note) { "This note was updated" }
  let(:instance) { described_class.new(message_service:) }
  let(:message_service) { MessageService.new }

  describe "#add_attribute" do
    subject { instance.add_attribute(person_id:, person_attribute_id:, attribute_id:, attribute_name:, attribute_values:, trace_id:) }

    let(:person_attribute_id) { SecureRandom.uuid }
    let(:attribute_id) { SecureRandom.uuid }
    let(:attribute_name) { "Cool factor" }
    let(:attribute_values) { ["Cool"] }

    it "creates an event" do
      expect(message_service).to receive(:create!).with(
        schema: Events::PersonAttributeAdded::V1,
        person_id:,
        trace_id:,
        data: {
          id: person_attribute_id,
          attribute_id:,
          attribute_name:,
          attribute_values:
        }
      ).and_call_original

      subject
    end
  end

  describe "#remove_attribute" do
    subject { instance.remove_attribute(person_id:, person_attribute_id:, trace_id:) }

    let(:person_attribute_id) { SecureRandom.uuid }

    it "creates an event" do
      expect(message_service).to receive(:create!).with(
        schema: Events::PersonAttributeRemoved::V1,
        person_id:,
        trace_id:,
        data: {
          id: person_attribute_id
        }
      ).and_call_original

      subject
    end
  end

  describe "#add_note" do
    subject { instance.add_note(person_id:, originator:, note: "This is a new note", note_id:, trace_id:) }

    let(:originator) { "someone" }

    it "creates an event" do
      expect(message_service).to receive(:create!).with(
        schema: Events::NoteAdded::V4,
        person_id:,
        trace_id:,
        data: {
          originator:,
          note: "This is a new note",
          note_id:
        }
      ).and_call_original

      subject
    end
  end

  describe "#delete_note" do
    subject { instance.delete_note(originator:, person_id:, note_id:, trace_id:) }

    let(:originator) { "someone" }

    it "creates an event" do
      expect(message_service).to receive(:create!).with(
        schema: Events::NoteDeleted::V4,
        person_id:,
        trace_id:,
        data: {
          originator:,
          note_id:
        }
      ).and_call_original

      subject
    end
  end

  describe "#modify_note" do
    subject { instance.modify_note(person_id:, originator:, note_id:, note: updated_note, trace_id:) }

    let(:originator) { "someone" }

    it "creates an event" do
      expect(message_service).to receive(:create!).with(
        schema: Events::NoteModified::V4,
        person_id:,
        trace_id:,
        data: {
          originator:,
          note_id:,
          note: updated_note
        }
      ).and_call_original

      subject
    end
  end

  describe "#create_reminder" do
    subject { instance.create_reminder(coach:, note:, reminder_at:, trace_id:, person_id:) }

    let(:coach) { create(:coaches__coach, user_id: user.id) }
    let(:user) { create(:user, person_id: coach_person_id) }
    let(:coach_person_id) { SecureRandom.uuid }
    let(:note) { "Do this thing" }
    let(:reminder_at) { Time.zone.local(2020, 1, 1) }
    let(:trace_id) { SecureRandom.uuid }
    let(:person_id) { nil }

    it "creates an coach reminder event and schedules a future reminder message" do
      expect(message_service)
        .to receive(:create!).with(
          schema: Events::CoachReminderScheduled::V2,
          coach_id: coach.id,
          trace_id:,
          data: {
            reminder_id: be_a(String),
            person_id:,
            note:,
            message_task_id: be_a(String),
            reminder_at:
          }
        ).and_call_original

      expect(message_service)
        .to receive(:create!).with(
          schema: Commands::ScheduleTask::V1,
          task_id: be_a(String),
          trace_id:,
          data: {
            execute_at: reminder_at - 1.hour,
            command: be_a(Message)
          },
          metadata: {
            requestor_type: Requestor::Kinds::USER,
            requestor_id: coach.user_id
          }
        ).and_call_original

      subject
    end

    context "when the coach doesn't have a person_id" do
      let(:coach_person_id) { nil }

      it "raises a NoPersonForCoachError" do
        expect { subject }.to raise_error(described_class::NoPersonForCoachError)
      end
    end

    context "when context_id is nil" do
      it "The message does not includes a link to the context page" do
        allow(message_service)
          .to receive(:build)
          .and_call_original

        expect(message_service)
          .to receive(:build).with(
            schema: Commands::SendMessage::V2,
            trace_id:,
            message_id: be_a(String),
            data: {
              person_id: coach_person_id,
              title: "Reminder",
              body: "At January 01, 2020 00:00: Do this thing",
              url: nil
            },
            metadata: {
              requestor_type: Requestor::Kinds::USER,
              requestor_id: coach.user_id
            }
          ).and_call_original

        subject
      end
    end

    context "when context_id is present" do
      let(:person_id) { SecureRandom.uuid }

      it "The message includes a link to the context page" do
        allow(message_service)
          .to receive(:build)
          .and_call_original

        expect(message_service)
          .to receive(:build).with(
            schema: Commands::SendMessage::V2,
            trace_id:,
            message_id: be_a(String),
            data: {
              person_id: coach_person_id,
              title: "Reminder",
              body: "At January 01, 2020 00:00: Do this thing",
              url: "#{ENV.fetch('FRONTEND_URL', nil)}/coaches/contexts/#{person_id}"
            },
            metadata: {
              requestor_type: Requestor::Kinds::USER,
              requestor_id: coach.user_id
            }
          ).and_call_original

        subject
      end
    end
  end

  describe "#complete_reminder" do
    subject { instance.complete_reminder(coach:, reminder_id:, trace_id:) }

    let(:coach) { create(:coaches__coach) }
    let(:reminder_id) { SecureRandom.uuid }
    let(:trace_id) { SecureRandom.uuid }

    it "fires off a coach reminder completed" do
      expect(message_service)
        .to receive(:create!).with(
          schema: Events::CoachReminderCompleted::V1,
          coach_id: coach.id,
          trace_id:,
          data: {
            reminder_id:
          }
        ).and_call_original

      subject
    end
  end

  describe "#recommend_job" do
    subject { instance.recommend_job(person_id:, job_id:, coach:, trace_id:) }

    let(:coach) { create(:coaches__coach) }
    let(:job_id) { create(:coaches__job).job_id }

    it "creates an event" do
      expect(message_service).to receive(:create!).with(
        schema: Events::JobRecommended::V3,
        person_id:,
        trace_id:,
        data: {
          job_id:,
          coach_id: coach.id
        }
      ).and_call_original

      subject
    end
  end

  describe "#certify" do
    subject { instance.certify(person_id:, coach:, trace_id:) }

    let(:coach) { create(:coaches__coach, user_id: user.id) }
    let(:user) { create(:user) }

    it "creates an event" do
      expect(message_service).to receive(:create!).with(
        schema: Events::PersonCertified::V1,
        person_id:,
        trace_id:,
        data: {
          coach_id: coach.id,
          coach_email: coach.email,
          coach_first_name: user.first_name,
          coach_last_name: user.last_name
        }
      ).and_call_original

      subject
    end
  end

  describe "#update_barriers" do
    subject { instance.update_barriers(person_id:, barriers: [barrier.barrier_id], trace_id:) }

    let(:barrier) { create(:barrier) }

    it "creates an event" do
      expect(message_service).to receive(:create!).with(
        schema: Events::BarrierUpdated::V3,
        person_id:,
        trace_id:,
        data: {
          barriers: [barrier.barrier_id]
        }
      ).and_call_original

      subject
    end
  end

  describe "#assign_coach" do
    subject { instance.assign_coach(person_id:, coach_id:, trace_id:) }

    let(:coach_id) { SecureRandom.uuid }

    it "creates an event" do
      expect(message_service).to receive(:create!).with(
        schema: Events::CoachAssigned::V3,
        person_id:,
        trace_id:,
        data: {
          coach_id:
        }
      ).and_call_original

      subject
    end
  end

  describe "#update_skill_level" do
    subject { instance.update_skill_level(person_id:, skill_level: "advanced", trace_id:) }

    it "creates an event" do
      expect(message_service).to receive(:create!).with(
        schema: Events::SkillLevelUpdated::V3,
        person_id:,
        trace_id:,
        data: {
          skill_level: "advanced"
        }
      ).and_call_original

      subject
    end
  end
end
