require 'rails_helper'

RSpec.describe Employers::ApplicationService do
  describe "#update_status" do
    subject { described_class.update_status(application_id:, status:, message_service:, user_id:, reasons:) }

    before do
      message_service.save!(applicant_status_updated)
    end

    let(:applicant_status_updated) do
      build(
        :message,
        schema: Events::ApplicantStatusUpdated::V6,
        stream_id: application_id,
        data: {
          applicant_first_name: "first_name",
          applicant_last_name: "last_name",
          applicant_email: "email",
          applicant_phone_number: "phone_number",
          seeker_id: SecureRandom.uuid,
          user_id: SecureRandom.uuid,
          job_id: SecureRandom.uuid,
          employer_name: "employer_name",
          employment_title: "employment_title",
          status: ApplicantStatus::StatusTypes::NEW,
          reasons: []
        },
        metadata: {
          user_id:
        }
      )
    end

    let(:application_id) { SecureRandom.uuid }
    let(:message_service) { MessageService.new }
    let(:status) { ApplicantStatus::StatusTypes::PENDING_INTRO }
    let(:reasons) { [{ id: reason.id, response: "Bad canidate" }] }
    let(:reason) { create(:employers__pass_reason) }
    let(:user_id) { SecureRandom.uuid }

    it "creates an event" do
      expect(message_service).to receive(:create!).with(
        schema: Events::ApplicantStatusUpdated::V6,
        application_id:,
        data: {
          applicant_first_name: applicant_status_updated.data.applicant_first_name,
          applicant_last_name: applicant_status_updated.data.applicant_last_name,
          applicant_email: applicant_status_updated.data.applicant_email,
          applicant_phone_number: applicant_status_updated.data.applicant_phone_number,
          seeker_id: applicant_status_updated.data.seeker_id,
          job_id: applicant_status_updated.data.job_id,
          employer_name: applicant_status_updated.data.employer_name,
          user_id: applicant_status_updated.data.user_id,
          employment_title: applicant_status_updated.data.employment_title,
          status: ApplicantStatus::StatusTypes::PENDING_INTRO,
          reasons: [
            Events::ApplicantStatusUpdated::Reason::V2.new(
              id: reason.id,
              response: "Bad canidate",
              reason_description: "This is a description"
            )
          ]
        },
        metadata: {
          user_id:
        }
      ).and_call_original

      subject
    end
  end
end
