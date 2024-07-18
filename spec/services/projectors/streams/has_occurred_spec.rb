require 'rails_helper'

RSpec.describe Projectors::Streams::HasOccurred do
  describe ".project" do
    subject { described_class.project(stream:, schema:) }

    let(:task_id) { SecureRandom.uuid }
    let(:stream) { Streams::Task.new(task_id:) }
    let(:schema) { Events::TaskExecuted::V1 }

    context "when the event does not exist for the stream" do
      before do
        Event.from_message!(
          build(
            :message,
            schema: Events::TaskExecuted::V1,
            stream_id: SecureRandom.uuid
          )
        )
        Event.from_message!(
          build(
            :message,
            schema: Events::ZipAdded::V2,
            stream_id: task_id,
            data: {
              zip_code: "43202"
            }
          )
        )
      end

      it "returns false" do
        expect(subject).to eq(false)
      end
    end

    context "when the event does exist for the stream" do
      before do
        Event.from_message!(
          build(
            :message,
            schema: Events::TaskExecuted::V1,
            stream_id: task_id
          )
        )
        Event.from_message!(
          build(
            :message,
            schema: Events::ZipAdded::V2,
            stream_id: task_id,
            data: {
              zip_code: "43202"
            }
          )
        )
      end

      it "returns true" do
        expect(subject).to eq(true)
      end
    end
  end
end
