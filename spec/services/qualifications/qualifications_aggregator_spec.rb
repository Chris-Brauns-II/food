require 'rails_helper'

RSpec.describe Qualifications::QualificationsAggregator do
  it_behaves_like "a replayable message consumer"

  describe "#handle_message" do
    subject { instance.handle_message(message) }

    let(:instance) { described_class.new }

    context "when the message is master skill created" do
      let(:message) do
        build(
          :message,
          schema: Events::MasterSkillCreated::V1,
          data: {
            skill: "Juggling",
            type: MasterSkill::SkillTypes::TECHNICAL
          }
        )
      end

      it "creates a master skill record" do
        expect { subject }.to change(MasterSkill, :count).from(0).to(1)

        master_skill = MasterSkill.first
        expect(master_skill.id).to eq(message.stream.id)
        expect(master_skill.skill).to eq(message.data.skill)
        expect(master_skill.type).to eq(message.data.type)
      end
    end

    context "when the message is master certification created" do
      let(:message) do
        build(
          :message,
          schema: Events::MasterCertificationCreated::V1,
          data: {
            certification: "Juggling OSHA 10"
          }
        )
      end

      it "creates a master skill record" do
        expect { subject }.to change(MasterCertification, :count).from(0).to(1)

        master_skill = MasterCertification.first
        expect(master_skill.id).to eq(message.stream.id)
        expect(master_skill.certification).to eq(message.data.certification)
      end
    end
  end
end
