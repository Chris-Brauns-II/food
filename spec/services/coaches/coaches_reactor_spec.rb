require 'rails_helper'

RSpec.describe Coaches::CoachesReactor do
  let(:trace_id) { "42000038-7e82-48ca-ac18-72ebc08bdbeb" }
  let(:person_id) { SecureRandom.uuid }
  let(:coach_id) { SecureRandom.uuid }
  let(:consumer) { described_class.new(message_service:) }
  let(:message_service) { MessageService.new }
  let(:messages) { [] }

  before do
    messages.each do |m|
      Event.from_message!(m)
    end
  end

  it_behaves_like "a replayable message consumer"

  describe "#handle_message" do
    subject do
      consumer.handle_message(message)
      consumer.handle_message(message)
    end

    context "when the message is a assign_coach command" do
      let(:message) do
        build(
          :message,
          stream_id: person_id,
          schema: Commands::AssignCoach::V2,
          data: {
            coach_id:
          }
        )
      end

      let(:person_added) do
        build(
          :message,
          stream_id: person_id,
          schema: Events::PersonAdded::V1,
          data: {
            first_name: "Jim",
            last_name: "Jim",
            email: "A@B.com",
            phone_number: "333-333-3333",
            date_of_birth: nil
          }
        )
      end
      let(:coach_added) do
        build(
          :message,
          schema: Events::CoachAdded::V1,
          data: {
            coach_id:,
            email: "coach@B.com"
          }
        )
      end

      context "When person added as not occurred" do
        let(:message_service) { double }
        let(:messages) { [] }

        it "does nothing" do
          expect(message_service)

          subject
        end
      end

      context "When person added has occured" do
        context "when the coach does not exist" do
          let(:message_service) { double }
          let(:messages) { [person_added] }

          it "does nothing" do
            expect(message_service)

            subject
          end
        end

        context "when the coach exists" do
          let(:messages) { [person_added, coach_added] }

          it "emits a coach assigned event" do
            expect(message_service)
              .to receive(:create_once_for_trace!)
              .with(
                schema: Events::CoachAssigned::V3,
                stream: message.stream,
                data: {
                  coach_id: message.data.coach_id
                }
              )
              .twice
              .and_call_original

            subject
          end
        end
      end
    end

    context "when the message is a job_recommended event" do
      let(:message) do
        build(
          :message,
          schema: Events::JobRecommended::V3,
          stream_id: person_id,
          data: {
            job_id:,
            coach_id:
          }
        )
      end

      let(:job_id) { SecureRandom.uuid }
      let(:coach_id) { SecureRandom.uuid }
      let(:person_id) { SecureRandom.uuid }

      it "emits a send message command" do
        expect(message_service)
          .to receive(:create_once_for_trace!)
          .with(
            schema: Commands::SendMessage::V2,
            message_id: be_a(String),
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
          .twice
          .and_call_original

        subject
      end
    end

    context "when the message is coach reminder completed" do
      let(:message) do
        build(
          :message,
          schema: Events::CoachReminderCompleted::V1,
          stream_id: coach_id,
          data: {
            reminder_id:
          }
        )
      end

      let(:coach_id) { SecureRandom.uuid }
      let(:reminder_id) { SecureRandom.uuid }

      context "when the reminder scheduled is found" do
        let(:messages) do
          [
            build(
              :message,
              schema: Events::CoachReminderScheduled::V2,
              stream_id: coach_id,
              data: {
                reminder_id:,
                person_id: nil,
                note: "dude",
                message_task_id:,
                reminder_at: Time.zone.now
              }
            )
          ]
        end
        let(:message_task_id) { SecureRandom.uuid }

        it "fires off a cancel task command" do
          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              schema: Commands::CancelTask::V1,
              trace_id: message.trace_id,
              task_id: message_task_id,
              data: Core::Nothing,
              metadata: {
                requestor_type: Requestor::Kinds::COACH,
                requestor_id: coach_id
              }
            )
            .twice
            .and_call_original

          subject
        end
      end

      context "when the reminder scheduled is not found" do
        let(:messages) { [] }
        let(:message_service) { double }

        it "does nothing" do
          subject
        end
      end
    end

    context "when the message is person added" do
      let(:message) do
        build(
          :message,
          schema: Events::PersonAdded::V1,
          stream_id: person_id,
          data: {
            first_name: "John",
            last_name: "Chabot",
            email: "john@skillarc.com",
            phone_number: "333-333-3333",
            date_of_birth: "10/09/1990"
          }
        )
      end

      before do
        allow(Coaches::CoachAssignmentService)
          .to receive(:round_robin_assignment)
          .and_return(coach_id)
      end

      let(:person_id) { SecureRandom.uuid }

      context "when no coach is provided" do
        let(:message_service) { double }
        let(:coach_id) { nil }

        it "does nothing" do
          subject
        end
      end

      context "when coach is provided" do
        let(:coach_id) { SecureRandom.uuid }

        it "emits a assign coach command" do
          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              trace_id: message.trace_id,
              stream: message.stream,
              schema: Commands::AssignCoach::V2,
              data: {
                coach_id:
              }
            )
            .twice
            .and_call_original

          subject
        end
      end
    end

    context "when the message is person sourced" do
      let(:message) do
        build(
          :message,
          schema: Events::PersonSourced::V1,
          stream_id: person_id,
          data: {
            source_kind:,
            source_identifier:
          }
        )
      end

      let(:person_id) { SecureRandom.uuid }

      context "when the source kind is not coach" do
        let(:message_service) { double }
        let(:source_identifier) { SecureRandom.uuid }
        let(:source_kind) { People::SourceKind::USER }

        it "does nothing" do
          subject
        end
      end

      context "when the source kind is coach" do
        let(:source_identifier) { SecureRandom.uuid }
        let(:source_kind) { People::SourceKind::COACH }

        it "calls the assign coach command" do
          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              trace_id: message.trace_id,
              stream: message.stream,
              schema: Commands::AssignCoach::V2,
              data: {
                coach_id: message.data.source_identifier
              }
            )
            .twice
            .and_call_original

          subject
        end
      end
    end
  end
end
