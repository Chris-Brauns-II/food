require 'rails_helper'

RSpec.describe Seekers::ApplicationService do
  describe ".apply" do
    subject { described_class.apply(job:, seeker:, message_service:) }

    let(:message_service) { MessageService.new }
    let(:seeker) do
      create(
        :seeker,
        first_name: "Katina",
        last_name: "Hall",
        email: "katina.hall@skillarc.com",
        phone_number: "123-456-7890"
      )
    end
    let(:job) { create(:job, employer:, employment_title: "Welder") }
    let(:employer) do
      create(
        :employer,
        name: "Skillarc"
      )
    end

    context "when the seeker has not applied for this job before" do
      it "publishes an event" do
        expect(message_service)
          .to receive(:create!)
          .with(
            stream: Streams::Person.new(person_id: seeker.id),
            schema: Events::PersonApplied::V1,
            data: {
              application_id: be_a(String),
              seeker_first_name: "Katina",
              seeker_last_name: "Hall",
              seeker_email: "katina.hall@skillarc.com",
              seeker_phone_number: "123-456-7890",
              user_id: seeker.user_id,
              job_id: job.id,
              employer_name: "Skillarc",
              employment_title: "Welder"
            }
          ).and_call_original

        subject
      end
    end

    context "when the seeker has applied for this job before" do
      before do
        Event.from_message!(
          build(
            :message,
            schema: Events::PersonApplied::V1,
            stream_id: seeker.id,
            data: {
              application_id: SecureRandom.uuid,
              seeker_first_name: "Katina",
              seeker_last_name: "Hall",
              seeker_email: "katina.hall@skillarc.com",
              seeker_phone_number: "123-456-7890",
              user_id: seeker.user_id,
              job_id: job.id,
              employer_name: "Skillarc",
              employment_title: "Welder"
            }
          )
        )
      end

      let(:now) { Time.zone.local(2020, 1, 1) }
      let(:waiting_period) { 10.days }

      it "does not emit an event" do
        expect(message_service)
          .not_to receive(:create!)

        subject
      end
    end
  end
end
