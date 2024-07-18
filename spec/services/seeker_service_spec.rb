require 'rails_helper'

RSpec.describe SeekerService do
  describe "#get" do
    subject { described_class.new(seeker).get(user_id:, seeker_editor: true) }

    include_context "event emitter"

    let(:user_id) { SecureRandom.uuid }
    let(:seeker) do
      create(
        :seeker,
        user_id: user.id,
        email: "seeker@blocktrainapp.com",
        first_name: "First",
        last_name: "Last",
        phone_number: "1234567890",
        zip_code: "43210"
      )
    end
    let(:user) do
      create(
        :user,
        sub: "sub"
      )
    end

    before do
      create(
        :onboarding_session,
        seeker:,
        responses: {
          "opportunityInterests" => {
            "response" => %w[
              Manufacturing
              Healthcare
            ]
          }
        }
      )

      create(
        :education_experience,
        seeker:,
        organization_name: "University of Cincinnati",
        title: "Student",
        graduation_date: Date.new(2019, 5, 1),
        gpa: 3.5,
        activities: "Activities"
      )

      create(
        :other_experience,
        seeker:,
        organization_name: "Turner Construction",
        position: "Laborer",
        start_date: Date.new(2015, 1, 1),
        end_date: Date.new(2019, 1, 1),
        is_current: false,
        description: "Description"
      )

      create(
        :personal_experience,
        seeker:,
        activity: "Babysitting",
        start_date: Date.new(2019, 1, 1),
        end_date: Date.new(2020, 1, 1),
        description: "I babysat for my neighbor's kids."
      )

      create(
        :profile_skill,
        seeker:,
        description: "I'm good at welding.",
        master_skill_id: create(:master_skill, skill: "Welding", type: MasterSkill::SkillTypes::TECHNICAL).id
      )

      create(
        :story,
        seeker:,
        prompt: "Prompt",
        response: "Response"
      )

      tp = create(:training_provider, name: "Training Provider")
      create(
        :seeker_training_provider,
        seeker_id: seeker.id,
        training_provider: tp,
        program: create(:program, name: "Program", training_provider: tp)
      )

      second_tp = create(:training_provider, name: "Second Training Provider")

      create(
        :seeker_training_provider,
        seeker_id: seeker.id,
        training_provider: second_tp,
        program: nil
      )
    end

    it "returns the expanded seeker" do
      expect(subject[:education_experiences]).to contain_exactly({
                                                                   id: be_a(String),
                                                                   organization_name: "University of Cincinnati",
                                                                   title: "Student",
                                                                   graduation_date: "2019-05-01",
                                                                   gpa: "3.5",
                                                                   activities: "Activities"
                                                                 })
      expect(subject[:other_experiences]).to contain_exactly({
                                                               id: anything,
                                                               organization_name: "Turner Construction",
                                                               position: "Laborer",
                                                               start_date: "2015-01-01",
                                                               end_date: "2019-01-01",
                                                               is_current: false,
                                                               description: "Description"
                                                             })

      expect(subject[:personal_experience]).to contain_exactly({
                                                                 id: anything,
                                                                 activity: "Babysitting",
                                                                 start_date: "2019-01-01",
                                                                 end_date: "2020-01-01",
                                                                 description: "I babysat for my neighbor's kids."
                                                               })

      expect(subject[:profile_skills]).to contain_exactly(
        {
          id: be_a(String),
          description: "I'm good at welding.",
          master_skill: {
            id: be_a(String),
            skill: "Welding",
            type: MasterSkill::SkillTypes::TECHNICAL
          }
        }
      )

      expect(subject[:stories]).to contain_exactly(
        {
          id: anything,
          prompt: "Prompt",
          response: "Response"
        }
      )

      user = subject[:user]

      expect(user[:id]).to be_a(String)
      expect(user[:email]).to eq("seeker@blocktrainapp.com")
      expect(user[:first_name]).to eq("First")
      expect(user[:last_name]).to eq("Last")
      expect(user[:phone_number]).to eq("1234567890")
      expect(user[:zip_code]).to eq("43210")

      expect(subject[:is_profile_editor]).to eq(true)
    end

    context "when the user_id is missing" do
      let(:user_id) { nil }

      it "does not emits a SeekerViewed event" do
        expect_any_instance_of(MessageService)
          .not_to receive(:create!)

        subject
      end
    end

    context "when the user_id is for the seeker" do
      let(:user_id) { seeker.user_id }

      it "does not emits a SeekerViewed event" do
        expect_any_instance_of(MessageService)
          .not_to receive(:create!)

        subject
      end
    end

    context "when the user_id not for the seeker" do
      let(:user_id) { SecureRandom.uuid }

      it "emits a SeekerViewed event" do
        expect_any_instance_of(MessageService)
          .to receive(:create!)
          .with(
            schema: Events::PersonViewed::V1,
            user_id:,
            data: {
              person_id: seeker.id
            }
          )

        subject
      end
    end
  end
end
