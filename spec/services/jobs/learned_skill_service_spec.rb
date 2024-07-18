require 'rails_helper'

RSpec.describe Jobs::LearnedSkillService do
  describe ".create" do
    subject { described_class.create(job, master_skill_id) }

    include_context "event emitter"

    let(:job) { create(:job) }
    let(:master_skill_id) { create(:master_skill).id }

    it "publishes an event" do
      expect_any_instance_of(MessageService).to receive(:create!).with(
        schema: Events::LearnedSkillCreated::V1,
        job_id: job.id,
        data: {
          id: be_present,
          job_id: job.id,
          master_skill_id:
        }
      ).and_call_original

      subject
    end
  end

  describe ".destroy" do
    subject { described_class.destroy(learned_skill) }

    include_context "event emitter"

    let!(:learned_skill) { create(:learned_skill) }

    it "publishes an event" do
      expect_any_instance_of(MessageService).to receive(:create!).with(
        schema: Events::LearnedSkillDestroyed::V1,
        job_id: learned_skill.job_id,
        data: {
          id: learned_skill.id
        }
      )

      subject
    end
  end
end
