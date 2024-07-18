require 'rails_helper'

RSpec.describe PeopleSearch::PeopleAggregator do
  describe "#handle_message" do
    subject { instance.handle_message(message) }

    let(:instance) { described_class.new }

    context "person added" do
      let(:message) do
        build(
          :message,
          schema: Events::PersonAdded::V1,
          data: {
            first_name: "John",
            last_name: "Doe",
            email: "john.doe@skillarc.com",
            phone_number: "555-555-5555",
            date_of_birth: "1990-01-01"
          }
        )
      end

      it "creates a new person record" do
        expect { subject }.to change(PeopleSearch::Person, :count).from(0).to(1)

        person = PeopleSearch::Person.last

        expect(person.first_name).to eq("John")
        expect(person.last_name).to eq("Doe")
        expect(person.email).to eq("john.doe@skillarc.com")
        expect(person.phone_number).to eq("555-555-5555")
        expect(person.date_of_birth).to eq(Date.new(1990, 1, 1))
        expect(person.search_vector).to eq("John Doe john.doe@skillarc.com 555-555-5555 1990-01-01")
        expect(person.last_active_at).to eq(message.occurred_at)
      end
    end

    context "basic info updated" do
      let(:person) { create(:people_search_person) }

      let(:message) do
        build(
          :message,
          schema: Events::BasicInfoAdded::V1,
          stream_id: person.id,
          data: {
            first_name: "Khushi",
            last_name: "Mo",
            phone_number: "999-999-9999",
            email: "khushi.mo@skillarc.com"
          }
        )
      end
      let(:person_id) { person.id }

      it "updates the person record" do
        subject

        person.reload

        expect(person.first_name).to eq("Khushi")
        expect(person.last_name).to eq("Mo")
        expect(person.phone_number).to eq("999-999-9999")
        expect(person.email).to eq("khushi.mo@skillarc.com")
        expect(person.search_vector).to eq("Khushi Mo khushi.mo@skillarc.com 999-999-9999 1990-01-01")
      end
    end

    context "coach added" do
      let(:message) do
        build(
          :message,
          schema: Events::CoachAdded::V1,
          data: {
            coach_id: SecureRandom.uuid,
            email: "coach@skillarc.com"
          }
        )
      end

      it "creates a new coach record" do
        expect { subject }.to change(PeopleSearch::Coach, :count).from(0).to(1)

        coach = PeopleSearch::Coach.last

        expect(coach.email).to eq("coach@skillarc.com")
      end
    end

    context "coach assigned" do
      let(:message) do
        build(
          :message,
          schema: Events::CoachAssigned::V3,
          stream_id: person.id,
          data: {
            coach_id: coach.id
          }
        )
      end

      let(:coach) { create(:people_search_coach) }
      let(:person) { create(:people_search_person) }

      it "updates the assigned_coach field" do
        subject

        person.reload

        expect(person.assigned_coach).to eq(coach.email)
      end
    end

    context "experience added" do
      let(:person) { create(:people_search_person) }

      let(:message) do
        build(
          :message,
          schema: Events::ExperienceAdded::V2,
          stream_id: person.id,
          data: {
            id:,
            organization_name: "Skillarc",
            position: "Software Engineer",
            start_date: "2019-01-01",
            end_date: "2021-01-01",
            description: "Worked on the backend team"
          }
        )
      end
      let(:id) { SecureRandom.uuid }

      it "creates adds a new experience record" do
        expect { subject }.to change(PeopleSearch::PersonExperience, :count).from(0).to(1)

        experience = PeopleSearch::PersonExperience.last

        expect(experience.organization_name).to eq("Skillarc")
        expect(experience.position).to eq("Software Engineer")
        expect(experience.description).to eq("Worked on the backend team")
      end

      it "updates the search vector" do
        subject

        person.reload

        expect(person.search_vector).to eq("John Doe john.doe@skillarc.com 555-555-5555 1990-01-01 Skillarc Software Engineer Worked on the backend team")
      end
    end

    context "experience removed" do
      let(:person) { create(:people_search_person) }
      let!(:experience) { create(:people_search_person_experience, person:) }
      let(:message) do
        build(
          :message,
          schema: Events::ExperienceRemoved::V2,
          stream_id: person.id,
          data: {
            id: experience.id
          }
        )
      end

      it "removes the experience record" do
        expect { subject }.to change(PeopleSearch::PersonExperience, :count).by(-1)
      end

      it "updates the search vector" do
        subject

        person.reload

        expect(person.search_vector).to eq("John Doe john.doe@skillarc.com 555-555-5555 1990-01-01")
      end
    end

    context "education experience added" do
      let(:person) { create(:people_search_person) }

      let(:message) do
        build(
          :message,
          schema: Events::EducationExperienceAdded::V2,
          stream_id: person.id,
          data: {
            id:,
            organization_name: "Skillarc University",
            title: "Bachelor of Science in Computer Science",
            activities: "Studied computer science",
            graduation_date: "2017-01-01"
          }
        )
      end
      let(:id) { SecureRandom.uuid }

      it "creates adds a new education experience record" do
        expect { subject }.to change(PeopleSearch::PersonEducationExperience, :count).by(1)
      end

      it "updates the search vector" do
        subject

        person.reload

        expected_vector =
          "John Doe john.doe@skillarc.com 555-555-5555 1990-01-01 Skillarc University Bachelor of Science in Computer Science Studied computer science"
        expect(person.search_vector).to eq(expected_vector)
      end
    end

    context "education experience removed" do
      let(:person) { create(:people_search_person) }
      let!(:education_experience) { create(:people_search_person_education_experience, person:) }

      let(:message) do
        build(
          :message,
          schema: Events::EducationExperienceDeleted::V2,
          stream_id: person.id,
          data: {
            id: education_experience.id
          }
        )
      end

      it "removes the education experience record" do
        expect { subject }.to change(PeopleSearch::PersonEducationExperience, :count).by(-1)
      end

      it "updates the search vector" do
        subject

        person.reload

        expect(person.search_vector).to eq("John Doe john.doe@skillarc.com 555-555-5555 1990-01-01")
      end
    end

    context "note added" do
      let(:person) { create(:people_search_person) }

      let(:message) do
        build(
          :message,
          schema: Events::NoteAdded::V4,
          stream_id: person.id,
          data: {
            originator: "foo",
            note: "This is a note",
            note_id: SecureRandom.uuid
          }
        )
      end
      let(:id) { SecureRandom.uuid }

      it "updates the person last_contactedat" do
        expect { subject }.to change { person.reload.last_contacted_at }.from(nil).to(message.occurred_at)
      end
    end

    context "person associated to user" do
      let(:message) do
        build(
          :message,
          schema: Events::PersonAssociatedToUser::V1,
          stream_id: person.id,
          data: {
            user_id:
          }
        )
      end
      let(:user_id) { SecureRandom.uuid }
      let(:person) { create(:people_search_person) }

      it "updates the person record" do
        subject

        expect(person.reload.user_id).to eq(user_id)
      end
    end

    context "person certified" do
      let(:message) do
        build(
          :message,
          schema: Events::PersonCertified::V1,
          stream_id: person.id,
          data: {
            coach_first_name: "Coach",
            coach_last_name: "Doe",
            coach_email: "coach_email",
            coach_id:
          }
        )
      end
      let(:coach) { create(:people_search_coach) }
      let(:coach_id) { coach.id }
      let(:person) { create(:people_search_person) }

      it "updates the person" do
        subject

        expect(person.reload.certified_by).to eq("coach_email")
      end
    end

    context "session started" do
      let(:message) do
        build(
          :message,
          schema: Events::SessionStarted::V1,
          stream_id: person.user_id
        )
      end
      let(:person) { create(:people_search_person) }

      it "updates the person" do
        subject

        expect(person.reload.last_active_at).to eq(message.occurred_at)
      end
    end
  end
end
