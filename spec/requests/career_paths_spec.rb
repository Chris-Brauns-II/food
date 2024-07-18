require 'rails_helper'

RSpec.describe "CareerPaths", type: :request do
  describe "POST /create" do
    subject { post job_career_paths_path(job), params:, headers: }

    let(:job) { create(:job) }
    let(:params) do
      {
        career_path: {
          title: "Level 1",
          lower_limit: "10",
          upper_limit: "15"
        }
      }
    end

    it_behaves_like "admin secured endpoint"

    context "admin authenticated" do
      include_context "admin authenticated"

      it "calls Jobs::CareerPathService.create" do
        expect(Jobs::CareerPathService).to receive(:create).with(job, title: "Level 1", lower_limit: "10", upper_limit: "15").and_call_original

        subject
      end
    end
  end

  describe "POST /up" do
    subject { put job_career_path_up_path(job, path), headers: }

    let(:job) { create(:job) }
    let!(:path) { create(:career_path, job:, order: 1) }
    let!(:path_above) { create(:career_path, job:, order: 0) }

    it_behaves_like "admin secured endpoint"

    context "admin authenticated" do
      include_context "admin authenticated"

      it "calls Jobs::CareerPathService.up" do
        expect(Jobs::CareerPathService).to receive(:up).with(path).and_call_original

        subject
      end
    end
  end

  describe "POST /down" do
    subject { put job_career_path_down_path(job, path), headers: }

    let(:job) { create(:job) }
    let!(:path) { create(:career_path, job:, order: 0) }
    let!(:path_below) { create(:career_path, job:, order: 1) }

    it_behaves_like "admin secured endpoint"

    context "admin authenticated" do
      include_context "admin authenticated"

      it "calls Jobs::CareerPathService.down" do
        expect(Jobs::CareerPathService).to receive(:down).with(path).and_call_original

        subject
      end
    end
  end

  describe "DELETE /destroy" do
    subject { delete job_career_path_path(job, path), headers: }

    let(:job) { create(:job) }
    let!(:path) { create(:career_path, job:, order: 0) }

    it_behaves_like "admin secured endpoint"

    context "admin authenticated" do
      include_context "admin authenticated"

      it "calls Jobs::CareerPathService.destroy" do
        expect(Jobs::CareerPathService).to receive(:destroy).with(path).and_call_original

        subject
      end
    end
  end
end
