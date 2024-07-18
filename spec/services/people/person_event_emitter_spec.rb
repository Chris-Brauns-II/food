require 'rails_helper'

RSpec.describe People::PersonEventEmitter do
  let(:instance) { described_class.new(message_service:) }
  let(:message_service) { MessageService.new }
  let(:person_id) { SecureRandom.uuid }
  let(:trace_id) { SecureRandom.uuid }
  let(:user_id) { SecureRandom.uuid }

  describe "add_education_experience" do
    subject do
      instance.add_education_experience(
        person_id:,
        organization_name:,
        title:,
        graduation_date:,
        gpa:,
        activities:,
        trace_id:,
        id:
      )
    end

    let(:organization_name) { "Some org" }
    let(:title) { "Scholar" }
    let(:graduation_date) { "Some date" }
    let(:gpa) { "3.9" }
    let(:activities) { "Picking my nose" }
    let(:id) { SecureRandom.uuid }

    it "emits an experience added event" do
      expect(message_service)
        .to receive(:create!)
        .with(
          schema: Events::EducationExperienceAdded::V2,
          trace_id:,
          person_id:,
          data: {
            id:,
            activities:,
            organization_name:,
            title:,
            graduation_date:,
            gpa:
          }
        )

      subject
    end
  end

  describe "add_person_training_provider" do
    subject do
      instance.add_person_training_provider(
        person_id:,
        status:,
        trace_id:,
        training_provider_id:,
        program_id:,
        id:
      )
    end

    let(:id) { SecureRandom.uuid }
    let(:training_provider_id) { SecureRandom.uuid }
    let(:program_id) { SecureRandom.uuid }
    let(:status) { "Doing greate" }

    it "emits an seeker training provider created event" do
      expect(message_service)
        .to receive(:create!)
        .with(
          person_id:,
          trace_id:,
          schema: Events::PersonTrainingProviderAdded::V1,
          data: {
            id:,
            status:,
            program_id:,
            training_provider_id:
          }
        )

      subject
    end
  end

  describe "add_reliability" do
    subject do
      instance.add_reliability(
        person_id:,
        trace_id:,
        reliabilities:
      )
    end

    let(:reliabilities) { [Reliability::JOB, Reliability::EDUCATION] }

    it "emits an reliability added event" do
      expect(message_service)
        .to receive(:create!)
        .with(
          person_id:,
          trace_id:,
          schema: Events::ReliabilityAdded::V2,
          data: {
            reliabilities:
          }
        )

      subject
    end
  end

  describe "add_professional_interests" do
    subject do
      instance.add_professional_interests(
        person_id:,
        trace_id:,
        interests:
      )
    end

    let(:interests) { %w[Pokemon Cowboys] }

    it "emits an professional interest event" do
      expect(message_service)
        .to receive(:create!)
        .with(
          person_id:,
          trace_id:,
          schema: Events::ProfessionalInterestsAdded::V2,
          data: {
            interests:
          }
        )

      subject
    end
  end

  describe "complete_onboarding" do
    subject do
      instance.complete_onboarding(
        person_id:,
        trace_id:
      )
    end

    it "emits an basic info added event" do
      expect(message_service)
        .to receive(:create!)
        .with(
          person_id:,
          trace_id:,
          schema: Commands::CompleteOnboarding::V2,
          data: Core::Nothing
        )

      subject
    end
  end

  describe "remove_education_experience" do
    subject do
      instance.remove_education_experience(
        person_id:,
        education_experience_id:,
        trace_id:
      )
    end

    let(:education_experience_id) { SecureRandom.uuid }

    it "emits an experience added event" do
      expect(message_service)
        .to receive(:create!)
        .with(
          schema: Events::EducationExperienceDeleted::V2,
          trace_id:,
          person_id:,
          data: {
            id: education_experience_id
          }
        )

      subject
    end
  end

  describe "add_personal_experience" do
    subject do
      instance.add_personal_experience(
        person_id:,
        activity:,
        description:,
        start_date:,
        end_date:,
        trace_id:,
        id:
      )
    end

    let(:activity) { "Do stuff" }
    let(:description) { "Best stuff" }
    let(:start_date) { "bro" }
    let(:end_date) { "15" }
    let(:id) { SecureRandom.uuid }

    it "emits an experience added event" do
      expect(message_service)
        .to receive(:create!)
        .with(
          schema: Events::PersonalExperienceAdded::V2,
          trace_id:,
          person_id:,
          data: {
            id:,
            activity:,
            description:,
            start_date:,
            end_date:
          }
        )

      subject
    end
  end

  describe "remove_personal_experience" do
    subject do
      instance.remove_personal_experience(
        person_id:,
        personal_experience_id:,
        trace_id:
      )
    end

    let(:personal_experience_id) { SecureRandom.uuid }

    it "emits an experience added event" do
      expect(message_service)
        .to receive(:create!)
        .with(
          schema: Events::PersonalExperienceRemoved::V2,
          trace_id:,
          person_id:,
          data: {
            id: personal_experience_id
          }
        )

      subject
    end
  end

  describe "add_experience" do
    subject do
      instance.add_experience(
        person_id:,
        organization_name:,
        position:,
        start_date:,
        end_date:,
        is_current:,
        description:,
        trace_id:
      )
    end

    let(:organization_name) { "Some org" }
    let(:position) { "Best position" }
    let(:start_date) { "2000-10-25" }
    let(:end_date) { "2005-3-25" }
    let(:is_current) { true }
    let(:description) { "It was a great job" }

    it "emits an experience added event" do
      expect(message_service)
        .to receive(:create!)
        .with(
          schema: Events::ExperienceAdded::V2,
          trace_id:,
          person_id:,
          data: {
            id: be_a(String),
            organization_name:,
            position:,
            start_date:,
            end_date:,
            description:,
            is_current:
          }
        )

      subject
    end
  end

  describe "remove_experience" do
    subject do
      instance.remove_experience(
        person_id:,
        experience_id:,
        trace_id:
      )
    end

    let(:experience_id) { SecureRandom.uuid }

    it "emits an experience added event" do
      expect(message_service)
        .to receive(:create!)
        .with(
          schema: Events::ExperienceRemoved::V2,
          trace_id:,
          person_id:,
          data: {
            id: experience_id
          }
        )

      subject
    end
  end
end
