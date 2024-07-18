require 'rails_helper'

RSpec.describe Infrastructure::Task do
  let(:instance) do
    create(
      :infrastructure__task,
      state:,
      id:,
      command:
    )
  end
  let(:state) { Infrastructure::TaskStates::ENQUEUED }
  let(:id) { SecureRandom.uuid }
  let(:command) do
    build(
      :message,
      schema: Commands::AssignCoach::V2,
      stream_id: SecureRandom.uuid,
      data: {
        coach_id: SecureRandom.uuid
      }
    )
  end

  describe "#command" do
    it "returns the message it was created with" do
      expect(instance.command).to eq(command)
    end
  end

  describe "#cancel!" do
    context "when state is not enqueued" do
      let(:state) { Infrastructure::TaskStates::EXECUTED }

      it "sets the state to cancelled" do
        instance.cancel!
        expect(instance.state).to eq(state)
      end
    end

    context "when state is enqueued" do
      let(:state) { Infrastructure::TaskStates::ENQUEUED }

      it "sets the state to cancelled" do
        instance.cancel!
        expect(instance.state).to eq(Infrastructure::TaskStates::CANCELLED)
      end
    end
  end

  describe "#execute!" do
    context "when state is enqueued" do
      let(:state) { Infrastructure::TaskStates::ENQUEUED }

      it "executes the command and sets the state to executed" do
        instance.execute!
        expect(instance.state).to eq(Infrastructure::TaskStates::EXECUTED)
      end
    end

    context "when state is not enqueued" do
      let(:state) { Infrastructure::TaskStates::CANCELLED }

      it "does nothing" do
        instance.execute!
        expect(instance.state).to eq(state)
      end
    end
  end
end
