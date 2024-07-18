require 'rails_helper'

RSpec.describe People::PersonAggregator do
  it_behaves_like "a replayable message consumer"

  let(:consumer) { described_class.new }

  let(:user) { create(:user) }

  describe "#handle_message" do
    subject { consumer.handle_message(message) }

    context "when the message is person added" do
      let(:message) do
        build(
          :message,
          schema: Events::PersonAdded::V1,
          stream_id: SecureRandom.uuid,
          data: {
            first_name: "John",
            last_name: "Skillz",
            email: "john@skillarc.com",
            date_of_birth: "10/09/1990",
            phone_number: "2222222222"
          }
        )
      end

      it "creates the seeker" do
        expect { subject }.to change(Seeker, :count).from(0).to(1)

        seeker = Seeker.take(1).first
        expect(seeker.id).to eq(message.stream.id)
        expect(seeker.first_name).to eq(message.data.first_name)
        expect(seeker.last_name).to eq(message.data.last_name)
        expect(seeker.email).to eq(message.data.email)
        expect(seeker.phone_number).to eq(message.data.phone_number)
      end
    end

    context "when the person exists" do
      let(:seeker) { create(:seeker) }

      context "when the message is person associated with user" do
        let(:message) do
          build(
            :message,
            schema: Events::PersonAssociatedToUser::V1,
            stream_id: seeker.id,
            data: {
              user_id: user.id
            }
          )
        end

        it "updates the seekers user id" do
          subject

          seeker.reload
          expect(seeker.user_id).to eq(message.data.user_id)
        end
      end

      context "when the message is basic info added" do
        let(:message) do
          build(
            :message,
            schema: Events::BasicInfoAdded::V1,
            stream_id: seeker.id,
            data: {
              first_name: "John",
              last_name: "Chabot",
              phone_number: "333-333-3333",
              email: "A@B.com"
            }
          )
        end

        it "updates the seekers basic info" do
          subject

          seeker.reload
          expect(seeker.email).to eq(message.data.email)
          expect(seeker.first_name).to eq(message.data.first_name)
          expect(seeker.last_name).to eq(message.data.last_name)
          expect(seeker.phone_number).to eq(message.data.phone_number)
        end
      end

      context "when the message is zip added" do
        let(:message) do
          build(
            :message,
            schema: Events::ZipAdded::V2,
            stream_id: seeker.id,
            data: {
              zip_code: "43202"
            }
          )
        end

        it "updates the zip code" do
          subject

          seeker.reload
          expect(seeker.zip_code).to eq(message.data.zip_code)
        end
      end

      context "when the message person about added" do
        let(:message) do
          build(
            :message,
            schema: Events::PersonAboutAdded::V1,
            stream_id: seeker.id,
            data: {
              about: "I'm pretty cool"
            }
          )
        end

        it "updates about" do
          subject

          seeker.reload
          expect(seeker.about).to eq(message.data.about)
        end
      end

      context "when the message is experience added" do
        let(:message) do
          build(
            :message,
            schema: Events::ExperienceAdded::V2,
            stream_id: seeker.id,
            data: {
              id: SecureRandom.uuid,
              organization_name: "Org",
              position: "Position",
              start_date: "A",
              end_date: "$$$",
              description: "{}",
              is_current: false
            }
          )
        end

        context "when the event updates a record" do
          let!(:other_experience) { create(:other_experience, seeker_id: message.stream.id, id: message.data.id) }

          it "updates an other session" do
            expect { subject }.not_to change(OtherExperience, :count)

            other_experience.reload
            expect(other_experience.id).to eq(message.data.id)
            expect(other_experience.seeker_id).to eq(message.stream.id)
            expect(other_experience.organization_name).to eq(message.data.organization_name)
            expect(other_experience.position).to eq(message.data.position)
            expect(other_experience.start_date).to eq(message.data.start_date)
            expect(other_experience.end_date).to eq(message.data.end_date)
            expect(other_experience.description).to eq(message.data.description)
            expect(other_experience.is_current).to eq(message.data.is_current)
          end
        end

        context "when the event creates a record" do
          it "creates an other experience" do
            expect { subject }.to change(OtherExperience, :count).from(0).to(1)

            other_experience = OtherExperience.take(1).first
            expect(other_experience.id).to eq(message.data.id)
            expect(other_experience.seeker_id).to eq(message.stream.id)
            expect(other_experience.organization_name).to eq(message.data.organization_name)
            expect(other_experience.position).to eq(message.data.position)
            expect(other_experience.start_date).to eq(message.data.start_date)
            expect(other_experience.end_date).to eq(message.data.end_date)
            expect(other_experience.description).to eq(message.data.description)
            expect(other_experience.is_current).to eq(message.data.is_current)
          end
        end
      end

      context "when the message is experience removed" do
        let(:message) do
          build(
            :message,
            schema: Events::ExperienceRemoved::V2,
            stream_id: seeker.id,
            data: {
              id:
            }
          )
        end
        let(:id) { SecureRandom.uuid }
        let!(:other_experience) { create(:other_experience, seeker_id: seeker.id, id:) }

        it "remove the other experience" do
          expect { subject }.to change(OtherExperience, :count).from(1).to(0)
        end
      end

      context "when the message is story created" do
        let(:message) do
          build(
            :message,
            schema: Events::StoryCreated::V2,
            stream_id: seeker.id,
            data: {
              id: SecureRandom.uuid,
              prompt: "Disk Golf?",
              response: "Yeah dawg"
            }
          )
        end

        it "creates a story" do
          expect { subject }.to change(Story, :count).from(0).to(1)

          story = Story.take(1).first
          expect(story.id).to eq(message.data.id)
          expect(story.seeker_id).to eq(message.stream.id)
          expect(story.prompt).to eq(message.data.prompt)
          expect(story.response).to eq(message.data.response)
        end
      end

      context "when the message is story updated" do
        let(:message) do
          build(
            :message,
            schema: Events::StoryUpdated::V2,
            stream_id: seeker.id,
            data: {
              id: story.id,
              prompt: "Disk Golf?",
              response: "Yeah dawg"
            }
          )
        end

        let!(:story) { create(:story) }

        it "updates a story" do
          expect { subject }.not_to change(Story, :count)

          story.reload
          expect(story.prompt).to eq(message.data.prompt)
          expect(story.response).to eq(message.data.response)
        end
      end

      context "when the message is applicant status updated" do
        let(:message) do
          build(
            :message,
            schema: Events::ApplicantStatusUpdated::V6,
            stream_id: application_id,
            data: {
              applicant_first_name: "First",
              applicant_last_name: "Last",
              applicant_email: "a@b.c",
              applicant_phone_number: "333-333-3333",
              seeker_id: seeker.id,
              user_id: SecureRandom.uuid,
              job_id: SecureRandom.uuid,
              employer_name: "Employer",
              employment_title: "Job",
              status: ApplicantStatus::StatusTypes::NEW,
              reasons: []
            },
            metadata: {
              user_id: SecureRandom.uuid
            }
          )
        end

        let(:application_id) { SecureRandom.uuid }

        context "when an 'Applicant' already exists" do
          let(:application_id) { applicant.id }
          let!(:applicant) { create(:applicant) }

          it "creates a new status for the existing applicant" do
            expect do
              expect do
                subject
              end.not_to change(Applicant, :count)
            end.to change(ApplicantStatus, :count).from(1).to(2)

            applicant.reload
            expect(applicant.status.status).to eq(ApplicantStatus::StatusTypes::NEW)
          end
        end

        context "when an 'Applicant' does not exists" do
          let(:application_id) { SecureRandom.uuid }

          it "creates a new status for the existing applicant" do
            expect do
              expect do
                subject
              end.to change(Applicant, :count).from(0).to(1)
            end.to change(ApplicantStatus, :count).from(0).to(1)

            applicant = Applicant.take(1).first
            expect(applicant.status.status).to eq(ApplicantStatus::StatusTypes::NEW)
          end
        end
      end

      context "when the message is story destoryed" do
        let(:message) do
          build(
            :message,
            schema: Events::StoryDestroyed::V2,
            stream_id: seeker.id,
            data: {
              id: story.id
            }
          )
        end

        let!(:story) { create(:story) }

        it "removes a story" do
          expect { subject }.to change(Story, :count).from(1).to(0)
        end
      end

      context "when the message is education experience added" do
        let(:message) do
          build(
            :message,
            schema: Events::EducationExperienceAdded::V2,
            stream_id: seeker.id,
            data: {
              id: SecureRandom.uuid,
              organization_name: "Org",
              title: "Position",
              activities: "A",
              graduation_date: "$$$",
              gpa: "{}"
            }
          )
        end

        context "when the event updates a record" do
          let!(:education_experience) { create(:education_experience, seeker_id: message.stream.id, id: message.data.id) }

          it "updates and education experience" do
            expect { subject }.not_to change(EducationExperience, :count)

            education_experience.reload
            expect(education_experience.id).to eq(message.data.id)
            expect(education_experience.seeker_id).to eq(seeker.id)
            expect(education_experience.organization_name).to eq(message.data.organization_name)
            expect(education_experience.title).to eq(message.data.title)
            expect(education_experience.activities).to eq(message.data.activities)
            expect(education_experience.graduation_date).to eq(message.data.graduation_date)
            expect(education_experience.gpa).to eq(message.data.gpa)
          end
        end

        context "when the event creates a record" do
          it "creates a education experience" do
            expect { subject }.to change(EducationExperience, :count).from(0).to(1)

            education_experience = EducationExperience.take(1).first
            expect(education_experience.id).to eq(message.data.id)
            expect(education_experience.seeker_id).to eq(seeker.id)
            expect(education_experience.organization_name).to eq(message.data.organization_name)
            expect(education_experience.title).to eq(message.data.title)
            expect(education_experience.activities).to eq(message.data.activities)
            expect(education_experience.graduation_date).to eq(message.data.graduation_date)
            expect(education_experience.gpa).to eq(message.data.gpa)
          end
        end
      end

      context "when the message is education experience removed" do
        let(:message) do
          build(
            :message,
            schema: Events::EducationExperienceDeleted::V2,
            stream_id: seeker.id,
            data: {
              id:
            }
          )
        end
        let(:id) { SecureRandom.uuid }
        let!(:education_experience) { create(:education_experience, seeker_id: seeker.id, id:) }

        it "remove the education experience" do
          expect { subject }.to change(EducationExperience, :count).from(1).to(0)
        end
      end

      context "when the message is personal experience added" do
        let(:message) do
          build(
            :message,
            schema: Events::PersonalExperienceAdded::V2,
            stream_id: seeker.id,
            data: {
              id: SecureRandom.uuid,
              activity: "Org",
              description: "Position",
              start_date: "A",
              end_date: "$$$"
            }
          )
        end

        context "when the event updates a record" do
          let!(:personal_experience) { create(:personal_experience, seeker_id: message.stream.id, id: message.data.id) }

          it "updates and personal experience" do
            expect { subject }.not_to change(PersonalExperience, :count)

            personal_experience.reload
            expect(personal_experience.id).to eq(message.data.id)
            expect(personal_experience.seeker_id).to eq(seeker.id)
            expect(personal_experience.activity).to eq(message.data.activity)
            expect(personal_experience.description).to eq(message.data.description)
            expect(personal_experience.start_date).to eq(message.data.start_date)
            expect(personal_experience.end_date).to eq(message.data.end_date)
          end
        end

        context "when the event creates a record" do
          it "creates a personal experience" do
            expect { subject }.to change(PersonalExperience, :count).from(0).to(1)

            personal_experience = PersonalExperience.take(1).first
            expect(personal_experience.id).to eq(message.data.id)
            expect(personal_experience.seeker_id).to eq(seeker.id)
            expect(personal_experience.activity).to eq(message.data.activity)
            expect(personal_experience.description).to eq(message.data.description)
            expect(personal_experience.start_date).to eq(message.data.start_date)
            expect(personal_experience.end_date).to eq(message.data.end_date)
          end
        end
      end

      context "when the message is personal experience removed" do
        let(:message) do
          build(
            :message,
            schema: Events::PersonalExperienceRemoved::V2,
            stream_id: seeker.id,
            data: {
              id:
            }
          )
        end
        let(:id) { SecureRandom.uuid }
        let!(:personal_experience) { create(:personal_experience, seeker_id: seeker.id, id:) }

        it "remove the personal experience" do
          expect { subject }.to change(PersonalExperience, :count).from(1).to(0)
        end
      end

      context "when the message is onboarding started" do
        let(:message) do
          build(
            :message,
            schema: Events::OnboardingStarted::V2,
            stream_id: seeker.id,
            data: Core::Nothing
          )
        end

        it "creates a onboarding session" do
          expect { subject }.to change(OnboardingSession, :count).from(0).to(1)

          onboarding_session = OnboardingSession.last_created
          expect(onboarding_session.seeker_id).to eq(message.stream.id)
          expect(onboarding_session.started_at).to eq(message.occurred_at)
        end
      end

      context "when the message is elevator pitch created" do
        let(:message) do
          build(
            :message,
            schema: Events::ElevatorPitchCreated::V2,
            stream_id: seeker.id,
            data: {
              job_id: applicant.job_id,
              pitch: "pitch"
            }
          )
        end

        let(:applicant) { create(:applicant, seeker:) }

        it "update the applicant" do
          subject

          applicant.reload
          expect(applicant.elevator_pitch).to eq("pitch")
        end
      end

      context "when the message is onboarding completed" do
        let(:message) do
          build(
            :message,
            schema: Events::OnboardingCompleted::V3,
            stream_id: seeker.id,
            data: Core::Nothing
          )
        end

        context "when an onboarding session exists" do
          let!(:onboarding_session) { create(:onboarding_session, seeker:) }

          it "updates the completed at time" do
            subject

            expect(onboarding_session.reload.completed_at).to eq(message.occurred_at)
          end
        end

        context "when an onboarding session doesn't exist" do
          it "updates the completed at time" do
            expect { subject }.to change(OnboardingSession, :count).from(0).to(1)

            onboarding_session = OnboardingSession.take(1).first
            expect(onboarding_session.completed_at).to eq(message.occurred_at)
          end
        end
      end

      context "when the message is person skill created" do
        let(:message) do
          build(
            :message,
            schema: Events::PersonSkillAdded::V1,
            stream_id: seeker.id,
            data: {
              skill_id: master_skill.id,
              description: "some descriptions",
              name: "Bob",
              type: MasterSkill::SkillTypes::TECHNICAL
            }
          )
        end

        let(:master_skill) { create(:master_skill) }

        it "creates a profile skill" do
          expect { subject }.to change(ProfileSkill, :count).from(0).to(1)

          profile_skill = ProfileSkill.take(1).first
          expect(profile_skill.seeker_id).to eq(message.stream.id)
          expect(profile_skill.description).to eq(message.data.description)
          expect(profile_skill.master_skill_id).to eq(message.data.skill_id)
        end
      end

      context "when the message is person skill update" do
        let(:message) do
          build(
            :message,
            schema: Events::PersonSkillUpdated::V1,
            stream_id: seeker.id,
            data: {
              skill_id: master_skill.id,
              description: "some descriptions",
              name: "Bob",
              type: MasterSkill::SkillTypes::TECHNICAL
            }
          )
        end

        let(:master_skill) { create(:master_skill) }
        let!(:profile_skill) { create(:profile_skill, seeker:, master_skill_id: master_skill.id) }

        it "updates a profile skill" do
          subject

          profile_skill.reload
          expect(profile_skill.description).to eq(message.data.description)
        end
      end

      context "when the message is person skill removed" do
        let(:message) do
          build(
            :message,
            schema: Events::PersonSkillRemoved::V1,
            stream_id: seeker.id,
            data: {
              skill_id: master_skill.id,
              description: "some descriptions",
              name: "Bob",
              type: MasterSkill::SkillTypes::TECHNICAL
            }
          )
        end

        let(:master_skill) { create(:master_skill) }
        let!(:profile_skill) { create(:profile_skill, seeker:, master_skill_id: master_skill.id) }

        it "updates a profile skill" do
          expect { subject }.to change(ProfileSkill, :count).from(1).to(0)
        end
      end
    end
  end
end
