require 'rails_helper'

RSpec.describe "JobTags", type: :request do
  describe "POST /create" do
    subject { post job_job_tags_path(job), params:, headers: }

    let(:params) do
      {
        tag: tag.name
      }
    end
    let(:tag) { create(:tag) }
    let(:job) { create(:job) }

    it_behaves_like "admin secured endpoint"

    context "admin authenticated" do
      include_context "admin authenticated"

      it "calls Jobs::JobTagService.create" do
        expect(Jobs::JobTagService).to receive(:create).with(job, tag)

        subject
      end
    end
  end

  describe "DELETE /destroy" do
    subject { delete job_job_tag_path(job, job_tag), headers: }

    let(:job_tag) { create(:job_tag, job:) }
    let(:job) { create(:job) }

    it_behaves_like "admin secured endpoint"

    context "admin authenticated" do
      include_context "admin authenticated"

      it "calls Jobs::JobTagService.create" do
        expect(Jobs::JobTagService).to receive(:destroy).with(job_tag)

        subject
      end
    end
  end
end
