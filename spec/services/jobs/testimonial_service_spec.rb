require 'rails_helper'

RSpec.describe Jobs::TestimonialService do
  describe ".create" do
    subject { described_class.create(job_id:, name:, title:, testimonial:, photo_url:) }

    include_context "event emitter"

    let(:job) { create(:job) }
    let(:job_id) { job.id }
    let(:name) { "John Doe" }
    let(:title) { "CEO" }
    let(:testimonial) { "This is a testimonial" }
    let(:photo_url) { "https://example.com/photo.jpg" }

    it "publishes an event" do
      expect_any_instance_of(MessageService).to receive(:create!).with(
        schema: Events::TestimonialCreated::V1,
        job_id: job.id,
        data: {
          id: be_a(String),
          job_id: job.id,
          name:,
          title:,
          testimonial:,
          photo_url:
        }
      ).and_call_original

      subject
    end
  end

  describe ".destroy" do
    subject { described_class.destroy(testimonial) }

    include_context "event emitter"

    let!(:testimonial) { create(:testimonial) }

    it "publishes an event" do
      expect_any_instance_of(MessageService).to receive(:create!).with(
        schema: Events::TestimonialDestroyed::V1,
        job_id: testimonial.job_id,
        data: {
          id: testimonial.id
        }
      ).and_call_original

      subject
    end
  end
end
