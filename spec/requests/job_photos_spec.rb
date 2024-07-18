require 'rails_helper'

RSpec.describe "JobPhotos", type: :request do
  let(:job) { create(:job) }

  describe "POST /create" do
    subject { post job_job_photos_path(job), params:, headers: }

    let(:params) do
      {
        job_photo: {
          photo_url:
        }
      }
    end
    let(:photo_url) { "https://www.google.com" }

    it_behaves_like "admin secured endpoint"

    context "admin authorized" do
      include_context "admin authenticated"

      it "calls Jobs::JobPhotosService.create" do
        expect(Jobs::JobPhotosService).to receive(:create).with(job, photo_url).and_call_original

        subject
      end
    end
  end

  describe "DELETE /destroy" do
    subject { delete job_job_photo_path(job, job_photo), headers: }

    let!(:job_photo) { create(:job_photo, job:) }

    it_behaves_like "admin secured endpoint"

    context "admin authorized" do
      include_context "admin authenticated"

      it "calls Jobs::JobPhotosService.destroy" do
        expect(Jobs::JobPhotosService).to receive(:destroy).with(job_photo).and_call_original

        subject
      end
    end
  end
end
