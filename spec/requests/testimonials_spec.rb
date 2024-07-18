require 'rails_helper'

RSpec.describe "Testimonials", type: :request do
  describe "POST /create" do
    subject { post job_testimonials_path(job_id: job.id), params:, headers: }

    let(:params) do
      {
        name: "Tom",
        testimonial: "This is a testimonial",
        title: "CEO",
        photo_url: "image.png"
      }
    end
    let(:job) { create(:job) }

    it_behaves_like "admin secured endpoint"

    context "admin authenticated" do
      include_context "admin authenticated"

      it "calls Jobs::TestimonialService.create" do
        expect(Jobs::TestimonialService).to receive(:create).with(
          job_id: job.id,
          name: "Tom",
          testimonial: "This is a testimonial",
          title: "CEO",
          photo_url: "image.png"
        ).and_call_original

        subject
      end
    end
  end

  describe "DELETE /destroy" do
    subject { delete job_testimonial_path(job_id: job.id, id: testimonial.id), headers: }

    let(:job) { create(:job) }
    let!(:testimonial) { create(:testimonial, job:) }

    it_behaves_like "admin secured endpoint"

    context "admin authenticated" do
      include_context "admin authenticated"

      it "calls Jobs::TestimonialService.destroy" do
        expect(Jobs::TestimonialService).to receive(:destroy).with(testimonial).and_call_original

        subject
      end
    end
  end
end
