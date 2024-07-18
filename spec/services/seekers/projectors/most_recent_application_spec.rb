require 'rails_helper'

RSpec.describe Seekers::Projectors::MostRecentApplication do
  describe ".project" do
    subject { described_class.new.project(messages) }

    let(:stream) { Streams::Person.new(person_id:) }
    let(:person_id) { SecureRandom.uuid }
    let(:job1_id) { SecureRandom.uuid }
    let(:job2_id) { SecureRandom.uuid }

    let(:seeker_applied_job11) do
      build(
        :message,
        stream:,
        schema: Events::PersonApplied::V1,
        data: {
          application_id: SecureRandom.uuid,
          seeker_first_name: "John",
          seeker_last_name: "Chabot",
          seeker_email: "john@skillarc.com",
          seeker_phone_number: "333-333-3333",
          user_id: SecureRandom.uuid,
          job_id: job1_id,
          employer_name: "Stuff",
          employment_title: "Place"
        },
        occurred_at: Time.zone.local(2010, 1, 1)
      )
    end
    let(:seeker_applied_job12) do
      build(
        :message,
        stream:,
        schema: Events::PersonApplied::V1,
        data: {
          application_id: SecureRandom.uuid,
          seeker_first_name: "John",
          seeker_last_name: "Chabot",
          seeker_email: "john@skillarc.com",
          seeker_phone_number: "333-333-3333",
          user_id: SecureRandom.uuid,
          job_id: job1_id,
          employer_name: "Stuff",
          employment_title: "Place"
        },
        occurred_at: Time.zone.local(2020, 1, 1)
      )
    end
    let(:seeker_applied_job22) do
      build(
        :message,
        stream:,
        schema: Events::PersonApplied::V1,
        data: {
          application_id: SecureRandom.uuid,
          seeker_first_name: "John",
          seeker_last_name: "Chabot",
          seeker_email: "john@skillarc.com",
          seeker_phone_number: "333-333-3333",
          user_id: SecureRandom.uuid,
          job_id: job2_id,
          employer_name: "Stuff",
          employment_title: "Place"
        },
        occurred_at: Time.zone.local(2018, 1, 1)
      )
    end

    context "when there are no applications" do
      let(:messages) { [] }

      it "returns the applied_at as nil" do
        expect(subject.applied_at(job1_id)).to eq(nil)
      end
    end

    context "when there are several applications" do
      let(:messages) { [seeker_applied_job11, seeker_applied_job12, seeker_applied_job22] }

      it "returns the applied_at as the most recent timestamp" do
        expect(subject.applied_at(job1_id)).to eq(Time.zone.local(2020, 1, 1))
        expect(subject.applied_at(job2_id)).to eq(Time.zone.local(2018, 1, 1))
      end
    end
  end
end
