require 'rails_helper'

RSpec.describe Infrastructure::InfrastructureReactor do
  it_behaves_like "a non replayable message consumer"

  describe "#handle_message" do
    subject { described_class.new(message_service:).handle_message(message) }

    let(:message_service) { MessageService.new }

    context "when the message is schedule task" do
      let(:inner_message) do
        build(
          :message,
          schema: Commands::ScreenApplicant::V1,
          stream_id: SecureRandom.uuid,
          data: Core::Nothing
        )
      end

      let(:message) do
        build(
          :message,
          schema: Commands::ScheduleTask::V1,
          stream_id: task_id,
          data: {
            execute_at: Time.zone.local(2000, 1, 1),
            command: inner_message
          },
          metadata: {
            requestor_type: Requestor::Kinds::USER,
            requestor_id: SecureRandom.uuid
          }
        )
      end
      let(:task_id) { SecureRandom.uuid }

      context "if a task id already exists" do
        before do
          create(:infrastructure__task, id: task_id)
        end

        it "does nothing" do
          expect(message_service)
            .to_not receive(:create!)

          subject
        end
      end

      context "if a task id doesn't already exists" do
        it "fires off a task scheduled event" do
          expect(message_service)
            .to receive(:create!)
            .with(
              schema: Events::TaskScheduled::V1,
              trace_id: message.trace_id,
              task_id: message.stream.task_id,
              data: {
                execute_at: message.data.execute_at,
                command: message.data.command
              },
              metadata: {
                requestor_type: message.metadata.requestor_type,
                requestor_id: message.metadata.requestor_id
              }
            ).and_call_original

          subject
        end
      end
    end

    context "when the message is cancel task" do
      let(:message) do
        build(
          :message,
          schema: Commands::CancelTask::V1,
          stream_id: task_id,
          data: Core::Nothing,
          metadata: {
            requestor_type: Requestor::Kinds::USER,
            requestor_id: SecureRandom.uuid
          }
        )
      end
      let(:task_id) { SecureRandom.uuid }

      context "when there isn't an existing task" do
        it "does nothing" do
          expect(message_service)
            .not_to receive(:create!)

          subject
        end
      end

      context "when there is an existing task" do
        let!(:task) { create(:infrastructure__task, id: task_id, state:) }

        context "when the state is enqueued" do
          let(:state) { Infrastructure::TaskStates::ENQUEUED }

          it "emits the cancelled event" do
            expect(message_service)
              .to receive(:create!)
              .with(
                schema: Events::TaskCancelled::V1,
                trace_id: message.trace_id,
                task_id: message.stream.task_id,
                data: Core::Nothing,
                metadata: {
                  requestor_type: message.metadata.requestor_type,
                  requestor_id: message.metadata.requestor_id
                }
              )

            subject
          end
        end

        context "when the state is not enqueued" do
          let(:state) { Infrastructure::TaskStates::EXECUTED }

          it "does nothing" do
            expect(message_service)
              .not_to receive(:create!)

            subject
          end
        end
      end
    end
  end
end
