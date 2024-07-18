require 'rails_helper'

RSpec.describe Projectors::Streams::GetFirst do
  describe ".project" do
    subject { described_class.project(stream:, schema:) }

    let(:task_id) { SecureRandom.uuid }
    let(:stream) { Streams::Task.new(task_id:) }
    let(:schema) { Events::TaskExecuted::V1 }

    context "when the event does not exist for the stream" do
      before do
        Event.from_message!(message1)
        Event.from_message!(message2)
      end

      let(:message1) do
        build(
          :message,
          schema: Events::TaskExecuted::V1,
          stream_id: SecureRandom.uuid
        )
      end
      let(:message2) do
        build(
          :message,
          schema: Events::ZipAdded::V2,
          stream_id: task_id,
          data: {
            zip_code: "43202"
          }
        )
      end

      it "returns nil" do
        expect(subject).to eq(nil)
      end
    end

    context "when the event does exist for the stream" do
      before do
        Event.from_message!(message1)
        Event.from_message!(message2)
      end

      let(:message1) do
        build(
          :message,
          schema: Events::TaskExecuted::V1,
          stream_id: task_id,
          occurred_at: Time.zone.local(2000, 10, 10)
        )
      end
      let(:message2) do
        build(
          :message,
          schema: Events::TaskExecuted::V1,
          stream_id: task_id,
          occurred_at: Time.zone.local(2000, 10, 11)
        )
      end

      it "returns the first message" do
        expect(subject).to eq(message1)
      end
    end
  end
end
