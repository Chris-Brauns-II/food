require 'rails_helper'

RSpec.describe "Employers::Chats", type: :request do
  describe "GET /index" do
    subject { get chats_path, headers: }

    it_behaves_like "employer spec unauthenticated"

    context "when the employer has a recruiter" do
      include_context "employer authenticated"

      it "calls the EmployerChats service" do
        expect(EmployerChats)
          .to receive(:new)
          .with(
            recruiter: EmployerChats::Recruiter.new(
              user:,
              employer_id: employer.id
            ),
            message_service: be_a(MessageService)
          ).and_call_original

        expect_any_instance_of(EmployerChats).to receive(:get)

        subject
      end
    end

    context "when the user is an employer admin" do
      include_context "employer authenticated"

      let(:recruiter) { nil }
      let(:employers_recruiter) { nil }

      before do
        create(:user_role, user:, role: Role::Types::EMPLOYER_ADMIN)
      end

      it "calls the EmployerChats service" do
        expect(EmployerChats)
          .to receive(:new)
          .with(
            recruiter: EmployerChats::Recruiter.new(
              user:,
              employer_id: [employer.id]
            ),
            message_service: be_a(MessageService)
          ).and_call_original

        expect_any_instance_of(EmployerChats).to receive(:get)

        subject
      end
    end
  end

  describe "POST /mark_read" do
    subject { post mark_read_chats_path, params:, headers: }

    let(:params) do
      {
        applicant_id: applicant.id
      }
    end
    let(:applicant) { create(:employers_applicant) }

    it_behaves_like "employer spec unauthenticated"

    context "when the employer has a recruiter" do
      include_context "employer authenticated"

      it "calls the EmployerChats service" do
        expect(EmployerChats)
          .to receive(:new)
          .with(
            recruiter: EmployerChats::Recruiter.new(
              user:,
              employer_id: employer.id
            ),
            message_service: be_a(MessageService)
          ).and_call_original

        expect_any_instance_of(EmployerChats).to receive(:mark_read).with(
          application_id: applicant.id
        ).and_call_original

        subject
      end
    end
  end

  describe "POST /send_message" do
    subject { post send_message_chats_path, params:, headers: }

    let(:params) do
      {
        applicant_id: applicant.id,
        message: "We are interested in your application"
      }
    end
    let(:applicant) { create(:employers_applicant) }

    it_behaves_like "employer spec unauthenticated"

    context "when the employer has a recruiter" do
      include_context "employer authenticated"

      it "calls the EmployerChats service" do
        expect(EmployerChats)
          .to receive(:new)
          .with(
            recruiter: EmployerChats::Recruiter.new(
              user:,
              employer_id: employer.id
            ),
            message_service: be_a(MessageService)
          ).and_call_original

        expect_any_instance_of(EmployerChats)
          .to receive(:send_message)
          .with(
            application_id: applicant.id,
            message: "We are interested in your application"
          )

        subject
      end
    end
  end

  describe "POST /create" do
    subject { post chats_path, params:, headers: }

    let(:params) do
      {
        applicant_id: applicant.applicant_id
      }
    end
    let(:applicant) { create(:employers_applicant) }

    it_behaves_like "employer spec unauthenticated"

    context "when the employer has a recruiter" do
      include_context "employer authenticated"

      it "calls the EmployerChats service" do
        expect(EmployerChats)
          .to receive(:new)
          .with(
            recruiter: EmployerChats::Recruiter.new(
              user:,
              employer_id: employer.id
            ),
            message_service: be_a(MessageService)
          ).and_call_original

        expect_any_instance_of(EmployerChats)
          .to receive(:create)
          .with(
            application_id: applicant.applicant_id,
            job_id: applicant.job.job_id,
            seeker_id: applicant.seeker_id,
            title: "#{applicant.first_name} #{applicant.last_name} - #{applicant.job.employment_title}"
          ).and_call_original

        subject
      end
    end
  end
end
