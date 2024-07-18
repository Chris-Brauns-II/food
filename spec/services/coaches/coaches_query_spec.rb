require 'rails_helper'

RSpec.describe Coaches::CoachesQuery do
  describe ".all_seekers" do
    subject { described_class.all_seekers }

    before do
      barrier = create(:barrier, id: "81f43abc-67b6-4531-af45-293d3fc053e5", name: "barrier2")

      person_context1 = create(
        :coaches__person_context,
        id: "ab36d8fe-5bf0-47c3-9c79-fc461799287e",
        phone_number: "1234567890",
        first_name: "Hannah",
        last_name: "Block",
        assigned_coach: "coach@blocktrainapp.com",
        person_captured_at: Time.zone.local(2000, 1, 1),
        email: "hannah@blocktrainapp.com",
        captured_by: "someone@skillarc.com",
        last_active_on: Time.zone.local(2005, 1, 1),
        last_contacted_at: Time.zone.local(2010, 1, 1),
        kind: Coaches::PersonContext::Kind::SEEKER,
        barriers: [barrier.id],
        certified_by: "person@skillarc.com"
      )

      person_context2 = create(
        :coaches__person_context,
        id: "3e7cccaa-ec0e-4c59-a7ad-2b187b3acc4c",
        phone_number: nil,
        first_name: "Katina",
        last_name: "Hall",
        assigned_coach: nil,
        person_captured_at: Time.zone.local(2001, 1, 1),
        email: "katina@gmail.com",
        captured_by: "someone@skillarc.com",
        last_active_on: Time.zone.local(2008, 1, 1),
        last_contacted_at: nil,
        kind: Coaches::PersonContext::Kind::SEEKER,
        certified_by: nil
      )

      create(
        :coaches__person_context,
        id: "ec9ea4ff-7655-435b-a6dc-0de8427d6cb6",
        phone_number: "1234567890",
        first_name: "Jim",
        last_name: "Jimson",
        assigned_coach: nil,
        person_captured_at: Time.zone.local(2000, 1, 1),
        email: "hannah@blocktrainapp.com",
        captured_by: "someone@skillarc.com",
        last_active_on: Time.zone.local(2005, 1, 1),
        last_contacted_at: Time.zone.local(2010, 1, 1),
        kind: Coaches::PersonContext::Kind::LEAD,
        certified_by: "person@skillarc.com"
      )

      create(
        :coaches__person_note,
        person_context: person_context1,
        note: "This note was updated",
        id: "a2dd7180-6c3d-46ad-9bd7-413314b7a849",
        note_taken_at: Time.zone.local(2020, 1, 1),
        note_taken_by: "coach@blocktrainapp.com"
      )

      create(
        :coaches__person_application,
        person_context: person_context1,
        job_id: "2e6a7696-08e6-4e95-aa95-166fc2b43dcf",
        status: "Actively failing an interview",
        employer_name: "Cool",
        employment_title: "A title"
      )

      create(
        :coaches__person_application,
        person_context: person_context2,
        job_id: "23642aea-8f58-4a0c-8799-5d80591b84ad",
        status: "Actively failing an interview",
        employer_name: "Not Cool",
        employment_title: "A title"
      )

      create(
        :coaches__person_application,
        person_context: person_context2,
        job_id: "6f6dc17a-1f3b-44b6-aa5f-25da193943c5",
        status: "Actively chillin at an interview",
        employer_name: "Cool",
        employment_title: "A bad title"
      )

      create(
        :coaches__person_job_recommendation,
        person_context: person_context1,
        job: create(:coaches__job, id: "d4cd7594-bc68-44cd-b22c-246979a9ea0f")
      )
    end

    it "returns an empty array" do
      expected_profile = {
        id: "ab36d8fe-5bf0-47c3-9c79-fc461799287e",
        seeker_id: "ab36d8fe-5bf0-47c3-9c79-fc461799287e",
        first_name: "Hannah",
        last_name: "Block",
        email: "hannah@blocktrainapp.com",
        phone_number: "1234567890",
        last_active_on: Time.zone.local(2005, 1, 1),
        last_contacted: Time.zone.local(2010, 1, 1),
        assigned_coach: "coach@blocktrainapp.com",
        certified_by: "person@skillarc.com",
        barriers: [{
          id: "81f43abc-67b6-4531-af45-293d3fc053e5",
          name: "barrier2"
        }]
      }
      expected_other_profile = {
        id: "3e7cccaa-ec0e-4c59-a7ad-2b187b3acc4c",
        seeker_id: "3e7cccaa-ec0e-4c59-a7ad-2b187b3acc4c",
        first_name: "Katina",
        last_name: "Hall",
        email: "katina@gmail.com",
        phone_number: nil,
        last_active_on: Time.zone.local(2008, 1, 1),
        last_contacted: "Never",
        assigned_coach: 'none',
        certified_by: nil,
        barriers: []
      }

      expect(subject.length).to eq(2)
      expect(subject).to include(expected_profile)
      expect(subject).to include(expected_other_profile)
    end
  end

  describe ".all_leads" do
    subject { described_class.all_leads }

    before do
      create(
        :coaches__person_context,
        id: "2df13b05-fff6-43be-b4fd-2c688ca4ee38",
        phone_number: "0987654321",
        first_name: "Not",
        last_name: "Converted",
        assigned_coach: nil,
        person_captured_at: Time.zone.local(2000, 1, 1),
        email: nil,
        captured_by: "someone@skillarc.com",
        kind: Coaches::PersonContext::Kind::LEAD
      )
    end

    it "returns all leads" do
      expected_lead = {
        id: "2df13b05-fff6-43be-b4fd-2c688ca4ee38",
        phone_number: "0987654321",
        assigned_coach: 'none',
        first_name: "Not",
        last_name: "Converted",
        email: nil,
        lead_captured_at: Time.zone.local(2000, 1, 1),
        lead_captured_by: "someone@skillarc.com",
        kind: Coaches::PersonContext::Kind::LEAD,
        status: "new"
      }

      expect(subject).to eq([expected_lead])
    end
  end

  describe ".find_person" do
    subject { described_class.find_person(id) }

    let(:id) { SecureRandom.uuid }

    before do
      barrier = create(:barrier, id: "81f43abc-67b6-4531-af45-293d3fc053e5", name: "barrier2")

      person_context1 = create(
        :coaches__person_context,
        id:,
        phone_number: "1234567890",
        first_name: "Hannah",
        last_name: "Block",
        assigned_coach: "coach@blocktrainapp.com",
        person_captured_at: Time.zone.local(2000, 1, 1),
        email: "hannah@blocktrainapp.com",
        captured_by: "someone@skillarc.com",
        last_active_on: Time.zone.local(2005, 1, 1),
        last_contacted_at: Time.zone.local(2010, 1, 1),
        kind: Coaches::PersonContext::Kind::SEEKER,
        barriers: [barrier.id],
        certified_by: "person@skillarc.com"
      )

      create(
        :coaches__person_note,
        person_context: person_context1,
        note: "This note was updated",
        id: "a2dd7180-6c3d-46ad-9bd7-413314b7a849",
        note_taken_at: Time.zone.local(2020, 1, 1),
        note_taken_by: "coach@blocktrainapp.com"
      )

      create(
        :coaches__person_application,
        person_context: person_context1,
        job_id: "2e6a7696-08e6-4e95-aa95-166fc2b43dcf",
        status: "Actively failing an interview",
        employer_name: "Cool",
        employment_title: "A title"
      )

      create(
        :coaches__person_job_recommendation,
        person_context: person_context1,
        job: create(:coaches__job, job_id: "d4cd7594-bc68-44cd-b22c-246979a9ea0f")
      )

      create(
        :coaches__person_attribute,
        id: '2527d624-d0c4-48d4-856b-369ff767f29d',
        person_context: person_context1,
        name: "Education Level",
        values: ["High School"],
        attribute_id: "3f48a475-b711-4265-9cc5-02fcfc0c40d1"
      )
    end

    it "returns the context" do
      expected_profile = {
        id:,
        seeker_id: id,
        first_name: "Hannah",
        last_name: "Block",
        kind: 'seeker',
        email: "hannah@blocktrainapp.com",
        phone_number: "1234567890",
        last_active_on: Time.zone.local(2005, 1, 1),
        last_contacted: Time.zone.local(2010, 1, 1),
        assigned_coach: "coach@blocktrainapp.com",
        certified_by: "person@skillarc.com",
        attributes: [{
          name: "Education Level",
          id: '2527d624-d0c4-48d4-856b-369ff767f29d',
          attribute_id: "3f48a475-b711-4265-9cc5-02fcfc0c40d1",
          value: ["High School"]
        }],
        barriers: [{
          id: "81f43abc-67b6-4531-af45-293d3fc053e5",
          name: "barrier2"
        }],
        notes: [
          {
            note: "This note was updated",
            note_id: "a2dd7180-6c3d-46ad-9bd7-413314b7a849",
            note_taken_by: "coach@blocktrainapp.com",
            date: Time.utc(2020, 1, 1)
          }
        ],
        applications: [
          {
            job_id: "2e6a7696-08e6-4e95-aa95-166fc2b43dcf",
            employer_name: "Cool",
            status: "Actively failing an interview",
            employment_title: "A title"
          }
        ],
        job_recommendations: ["d4cd7594-bc68-44cd-b22c-246979a9ea0f"]
      }

      expect(subject).to eq(expected_profile)
    end
  end

  describe ".tasks" do
    subject { described_class.tasks(coach:, person_id:) }

    let(:coach) { create(:coaches__coach) }

    let!(:reminder1) do
      create(
        :coaches__reminder,
        note: "Do the thing",
        state: Coaches::ReminderState::SET,
        reminder_at: Time.zone.local(2024, 1, 1),
        person_id: SecureRandom.uuid,
        coach:
      )
    end
    let!(:reminder2) do
      create(
        :coaches__reminder,
        note: "Call X",
        state: Coaches::ReminderState::COMPLETE,
        reminder_at: Time.zone.local(2022, 1, 1),
        person_id: nil,
        coach:
      )
    end

    context "when a person_id is not provided" do
      let(:person_id) { nil }

      it "returns tasks for the coach" do
        expected_tasks = [
          {
            id: reminder1.id,
            note: "Do the thing",
            state: Coaches::ReminderState::SET,
            reminder_at: Time.zone.local(2024, 1, 1),
            context_id: reminder1.person_id
          },
          {
            id: reminder2.id,
            note: "Call X",
            state: Coaches::ReminderState::COMPLETE,
            reminder_at: Time.zone.local(2022, 1, 1),
            context_id: nil
          }
        ]

        expect(subject).to eq(expected_tasks)
      end
    end

    context "when a person_id is provided" do
      let(:person_id) { reminder1.person_id }

      it "returns tasks for the coach" do
        expected_tasks = [
          {
            id: reminder1.id,
            note: "Do the thing",
            state: Coaches::ReminderState::SET,
            reminder_at: Time.zone.local(2024, 1, 1),
            context_id: reminder1.person_id
          }
        ]

        expect(subject).to eq(expected_tasks)
      end
    end
  end

  describe ".all_coaches" do
    subject { described_class.all_coaches }

    before do
      create(
        :coaches__coach,
        id: "6f6dc17a-1f3b-44b6-aa5f-25da193943c5",
        email: "an@email.com"
      )
    end

    it "returns all coaches" do
      expected_coaches = [
        {
          id: "6f6dc17a-1f3b-44b6-aa5f-25da193943c5",
          email: "an@email.com"
        }
      ]

      expect(subject).to eq(expected_coaches)
    end
  end

  describe ".all_jobs" do
    subject { described_class.all_jobs }

    before do
      create(
        :coaches__job,
        job_id: "6f6dc17a-1f3b-44b6-aa5f-25da193943c5",
        employer_name: "SkillArc",
        employment_title: "First Engineer"
      )

      create(
        :coaches__job,
        hide_job: true
      )
    end

    it "returns all visible jobs" do
      expected_jobs = [
        {
          id: "6f6dc17a-1f3b-44b6-aa5f-25da193943c5",
          employer_name: "SkillArc",
          employment_title: "First Engineer"
        }
      ]

      expect(subject).to eq(expected_jobs)
    end
  end
end
