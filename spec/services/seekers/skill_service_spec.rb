require 'rails_helper'

RSpec.describe Seekers::SkillService do
  describe "#create" do
    subject { described_class.new(seeker).create(master_skill_id:, description:) }

    include_context "event emitter"

    let(:seeker) { create(:seeker) }
    let(:description) { "This is a description" }
    let(:master_skill_id) { master_skill.id }
    let(:master_skill) do
      create(
        :master_skill,
        skill: "Skill",
        type: MasterSkill::SkillTypes::TECHNICAL
      )
    end

    it "publishes an event" do
      expect_any_instance_of(MessageService).to receive(:create!).with(
        schema: Events::PersonSkillAdded::V1,
        person_id: seeker.id,
        data: {
          skill_id: master_skill.id,
          name: "Skill",
          description: "This is a description",
          type: MasterSkill::SkillTypes::TECHNICAL
        }
      ).and_call_original

      subject
    end
  end

  describe "#update" do
    subject { described_class.new(seeker).update(skill, description:) }

    include_context "event emitter"

    let(:seeker) { create(:seeker) }
    let(:skill) { create(:profile_skill, seeker:) }
    let(:description) { "This is a new description" }

    it "publishes an event" do
      expect_any_instance_of(MessageService).to receive(:create!).with(
        schema: Events::PersonSkillUpdated::V1,
        person_id: seeker.id,
        data: {
          skill_id: skill.master_skill.id,
          description: "This is a new description",
          type: skill.master_skill.type,
          name: skill.master_skill.skill
        }
      ).and_call_original

      subject
    end
  end

  describe "#destroy" do
    subject { described_class.new(seeker).destroy(skill) }

    include_context "event emitter"

    let(:seeker) { create(:seeker) }
    let!(:skill) { create(:profile_skill, seeker:) }

    it "publishes an event" do
      expect_any_instance_of(MessageService).to receive(:create!).with(
        schema: Events::PersonSkillRemoved::V1,
        person_id: seeker.id,
        data: {
          skill_id: skill.master_skill.id,
          description: skill.description,
          type: skill.master_skill.type,
          name: skill.master_skill.skill
        }
      ).and_call_original

      subject
    end
  end
end
