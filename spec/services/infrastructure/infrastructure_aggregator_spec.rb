require 'rails_helper'

RSpec.describe Infrastructure::InfrastructureAggregator do
  it_behaves_like "a replayable message consumer"

  describe "#handle_message" do
    subject { described_class.new.handle_message(message) }

    context "when the message is task scheduled" do
      let(:command) do
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
          schema: Events::TaskScheduled::V1,
          stream_id: SecureRandom.uuid,
          data: {
            execute_at: Time.zone.local(2000, 1, 1),
            command:
          },
          metadata: {
            requestor_type: Requestor::Kinds::USER,
            requestor_id: SecureRandom.uuid
          }
        )
      end

      it "creates a task" do
        expect { subject }.to change(Infrastructure::Task, :count).from(0).to(1)

        task = Infrastructure::Task.take(1).first

        expect(task.execute_at).to eq(Time.zone.local(2000, 1, 1))
        expect(task.command).to eq(command)
        expect(task.id).to eq(message.stream.task_id)
        expect(task.state).to eq(Infrastructure::TaskStates::ENQUEUED)
      end
    end

    context "when the message is task executed" do
      let!(:task) { create(:infrastructure__task, id: task_id) }

      let(:message) do
        build(
          :message,
          schema: Events::TaskExecuted::V1,
          stream_id: task_id,
          data: Core::Nothing
        )
      end
      let(:task_id) { SecureRandom.uuid }

      it "updates an existing command to status executed" do
        expect { subject }.not_to change(Infrastructure::Task, :count)

        task = Infrastructure::Task.take(1).first
        expect(task.state).to eq(Infrastructure::TaskStates::EXECUTED)
      end
    end

    context "when the message is task cancelled" do
      let!(:task) { create(:infrastructure__task, id: task_id) }

      let(:message) do
        build(
          :message,
          schema: Events::TaskCancelled::V1,
          stream_id: task_id,
          data: Core::Nothing,
          metadata: {
            requestor_type: Requestor::Kinds::USER,
            requestor_id: SecureRandom.uuid
          }
        )
      end
      let(:task_id) { SecureRandom.uuid }

      it "updates an existing command to status cancelled" do
        expect { subject }.not_to change(Infrastructure::Task, :count)

        task = Infrastructure::Task.take(1).first
        expect(task.state).to eq(Infrastructure::TaskStates::CANCELLED)
      end
    end
  end
end
