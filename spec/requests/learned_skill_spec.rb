require 'rails_helper'

RSpec.describe "LearnedSkills", type: :request do
  let(:job) { create(:job) }

  describe "POST /create" do
    subject { post job_learned_skills_path(job), params:, headers: }

    let(:params) do
      {
        master_skill_id: master_skill.id
      }
    end
    let(:master_skill) { create(:master_skill) }

    it_behaves_like "admin secured endpoint"

    context "admin authenticated" do
      include_context "admin authenticated"

      it "calls Jobs::LearnedSkillService.create" do
        expect(Jobs::LearnedSkillService).to receive(:create).with(job, master_skill.id).and_call_original

        subject
      end
    end
  end

  describe "DELETE /destroy" do
    subject { delete job_learned_skill_path(job, learned_skill), headers: }

    let!(:learned_skill) { create(:learned_skill, job:) }

    it_behaves_like "admin secured endpoint"

    context "admin authenticated" do
      include_context "admin authenticated"

      it "calls Jobs::LearnedSkillService.destroy" do
        expect(Jobs::LearnedSkillService).to receive(:destroy).with(learned_skill).and_call_original

        subject
      end
    end
  end
end
