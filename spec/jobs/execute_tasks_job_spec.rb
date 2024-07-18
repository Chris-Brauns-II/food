require 'rails_helper'

RSpec.describe ExecuteTasksJob do
  let!(:task1) { create(:infrastructure__task, command: message1) }
  let!(:task2) { create(:infrastructure__task, command: message2) }

  let(:message1) do
    build(
      :message,
      schema: Commands::AssignCoach::V2,
      stream_id: SecureRandom.uuid,
      data: {
        coach_id: SecureRandom.uuid
      }
    )
  end
  let(:message2) do
    build(
      :message,
      schema: Commands::AssignCoach::V2,
      stream_id: SecureRandom.uuid,
      data: {
        coach_id: SecureRandom.uuid
      }
    )
  end

  it "enqueues each ready to be executed command" do
    expect_any_instance_of(MessageService)
      .to receive(:create!)
      .with(
        schema: message1.schema,
        data: message1.data,
        trace_id: message1.trace_id,
        person_id: message1.stream.id,
        id: message1.id,
        metadata: message1.metadata
      )
      .and_call_original

    expect_any_instance_of(MessageService)
      .to receive(:create!)
      .with(
        schema: Events::TaskExecuted::V1,
        data: Core::Nothing,
        trace_id: message1.trace_id,
        task_id: task1.id
      )
      .and_call_original

    expect_any_instance_of(MessageService)
      .to receive(:create!)
      .with(
        schema: message2.schema,
        data: message2.data,
        trace_id: message2.trace_id,
        person_id: message2.stream.id,
        id: message2.id,
        metadata: message2.metadata
      )
      .and_call_original

    expect_any_instance_of(MessageService)
      .to receive(:create!)
      .with(
        schema: Events::TaskExecuted::V1,
        data: Core::Nothing,
        trace_id: message2.trace_id,
        task_id: task2.id
      )
      .and_call_original

    described_class.new.perform
  end
end
