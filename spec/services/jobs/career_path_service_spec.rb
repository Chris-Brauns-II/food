require 'rails_helper'

RSpec.describe Jobs::CareerPathService do
  describe ".create" do
    subject { described_class.create(job, title:, lower_limit:, upper_limit:) }

    include_context "event emitter"

    let(:job) { create(:job) }
    let(:title) { "title" }
    let(:lower_limit) { "1" }
    let(:upper_limit) { "2" }

    it "publishes an event" do
      expect_any_instance_of(MessageService).to receive(:create!).with(
        schema: Events::CareerPathCreated::V1,
        job_id: job.id,
        data: {
          id: be_a(String),
          job_id: job.id,
          title:,
          lower_limit:,
          upper_limit:,
          order: 0
        }
      ).and_call_original

      subject
    end
  end

  describe ".up" do
    subject { described_class.up(career_path) }

    include_context "event emitter"

    let!(:career_path) { create(:career_path, order:) }
    let!(:upper_career_path) { create(:career_path, job: career_path.job, order: career_path.order - 1) }
    let(:order) { 1 }

    context "career path is already at the top" do
      let(:order) { 0 }

      it "does not publish events" do
        expect_any_instance_of(MessageService).not_to receive(:create!)
      end
    end

    it "publishes events" do
      expect_any_instance_of(MessageService).to receive(:create!).with(
        schema: Events::CareerPathUpdated::V1,
        job_id: upper_career_path.job_id,
        data: {
          id: upper_career_path.id,
          order: 1
        }
      ).and_call_original

      expect_any_instance_of(MessageService).to receive(:create!).with(
        schema: Events::CareerPathUpdated::V1,
        job_id: career_path.job_id,
        data: {
          id: career_path.id,
          order: 0
        }
      ).and_call_original

      subject
    end
  end

  describe ".down" do
    subject { described_class.down(career_path) }

    include_context "event emitter"

    let!(:career_path) { create(:career_path) }

    context "career path is already at the bottom" do
      it "does not publish events" do
        expect_any_instance_of(MessageService).not_to receive(:create!)
      end
    end

    context "career path is not at the bottom" do
      let!(:lower_career_path) { create(:career_path, job: career_path.job, order: career_path.order + 1) }

      it "publishes events" do
        expect_any_instance_of(MessageService).to receive(:create!).with(
          schema: Events::CareerPathUpdated::V1,
          job_id: lower_career_path.job_id,
          data: {
            id: lower_career_path.id,
            order: 0
          }
        ).and_call_original

        expect_any_instance_of(MessageService).to receive(:create!).with(
          schema: Events::CareerPathUpdated::V1,
          job_id: career_path.job_id,
          data: {
            id: career_path.id,
            order: 1
          }
        ).and_call_original

        subject
      end
    end
  end

  describe ".destroy" do
    subject { described_class.destroy(career_path) }

    include_context "event emitter"

    let!(:career_path) { create(:career_path) }
    # let!(:higher_career_path) { create(:career_path, job: career_path.job, order: career_path.order + 1) }
    let!(:higher_career_path_created) do
      message = build(
        :message,
        schema: Events::CareerPathCreated::V1,
        stream_id: career_path.job_id,
        data: {
          id: SecureRandom.uuid,
          job_id: career_path.job_id,
          title: "title",
          lower_limit: "1",
          upper_limit: "2",
          order: career_path.order + 1
        }
      )

      Event.from_message!(message)
    end

    it "publishes events" do
      expect_any_instance_of(MessageService).to receive(:create!).with(
        schema: Events::CareerPathUpdated::V1,
        job_id: career_path.job_id,
        data: {
          id: be_a(String),
          order: career_path.order
        }
      ).and_call_original

      expect_any_instance_of(MessageService).to receive(:create!).with(
        schema: Events::CareerPathDestroyed::V1,
        job_id: career_path.job_id,
        data: {
          id: career_path.id
        }
      ).and_call_original

      subject
    end
  end
end
