require 'rails_helper'

RSpec.describe Jobs::JobTagService do
  describe ".create" do
    subject { described_class.create(job, tag) }

    include_context "event emitter"

    let(:job) { create(:job) }
    let!(:tag) { create(:tag) }

    it "publishes an event" do
      expect_any_instance_of(MessageService).to receive(:create!).with(
        schema: Events::JobTagCreated::V1,
        job_id: be_present,
        data: {
          id: be_a(String),
          job_id: job.id,
          tag_id: tag.id
        }
      ).and_call_original

      subject
    end
  end

  describe ".destroy" do
    subject { described_class.destroy(job_tag) }

    include_context "event emitter"

    let!(:job_tag) { create(:job_tag) }

    it "publishes an event" do
      expect_any_instance_of(MessageService).to receive(:create!).with(
        schema: Events::JobTagDestroyed::V2,
        job_id: job_tag.job_id,
        data: {
          tag_id: job_tag.tag_id,
          job_tag_id: job_tag.id,
          job_id: job_tag.job_id
        }
      ).and_call_original

      subject
    end
  end
end
