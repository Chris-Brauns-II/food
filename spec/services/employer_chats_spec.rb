require 'rails_helper'

RSpec.describe EmployerChats do
  let!(:recruiter) { create(:recruiter, employer_id: employer.id, user: recruiter_user) }
  let(:employer) { create(:employer) }

  let(:recruiter_user) { create(:user, first_name: "Recruiter", last_name: "User") }
  let(:instance) { described_class.new(recruiter:, message_service:) }
  let(:message_service) { MessageService.new }

  describe "#get" do
    subject { instance.get }

    let!(:applicant_chat) do
      create(
        :chats__applicant_chat,
        application_id:,
        employer_id: employer.id,
        title: "Hannah Block - Welder",
        chat_updated_at: Time.zone.local(2000, 1, 1)
      )
    end
    let!(:message1) do
      create(
        :chats__message,
        applicant_chat:,
        message: "This is a message from the applicant",
        from: "Hannah Block",
        user_id: SecureRandom.uuid,
        message_sent_at: Time.zone.local(2000, 1, 1)
      )
    end
    let!(:message2) do
      create(
        :chats__message,
        applicant_chat:,
        message: "This is a message from the recruiter",
        from: "Recruiter User",
        user_id: recruiter_user.id,
        message_sent_at: Time.zone.local(2010, 1, 1)
      )
    end
    let!(:read_receipt) do
      create(
        :chats__read_receipt,
        applicant_chat:,
        user_id: recruiter_user.id,
        read_until: Time.zone.local(2005, 1, 1)
      )
    end

    let(:application_id) { SecureRandom.uuid }

    it "returns the applicant chat" do
      expect(subject.first).to eq(
        {
          id: application_id,
          name: "Hannah Block - Welder",
          updatedAt: Time.zone.local(2000, 1, 1),
          messages: [
            {
              id: message1.id,
              text: "This is a message from the applicant",
              isUser: false,
              isRead: true,
              sender: "Hannah Block"
            },
            {
              id: message2.id,
              text: "This is a message from the recruiter",
              isUser: true,
              isRead: false,
              sender: "Recruiter User"
            }
          ]
        }
      )
    end
  end

  describe "#mark_read" do
    subject { instance.mark_read(application_id:) }

    let(:application_id) { SecureRandom.uuid }

    it "emits a chat read event" do
      expect(message_service)
        .to receive(:create!)
        .with(
          schema: Events::ChatRead::V1,
          application_id:,
          data: {
            read_by_user_id: recruiter.user.id
          }
        )

      subject
    end
  end

  describe "#send_message" do
    subject { instance.send_message(application_id:, message:) }

    let(:application_id) { SecureRandom.uuid }
    let(:message) { "Some message" }

    it "emits a chat message sent event" do
      expect(message_service).to receive(:create!).with(
        schema: Events::ChatMessageSent::V2,
        application_id:,
        data: {
          from_name: "Recruiter User",
          from_user_id: recruiter.user.id,
          message:
        }
      ).and_call_original

      subject
    end
  end

  describe "#create" do
    subject { instance.create(application_id:, job_id:, seeker_id:, title:) }

    let(:application_id) { SecureRandom.uuid }
    let(:job_id) { SecureRandom.uuid }
    let(:seeker_id) { SecureRandom.uuid }
    let(:title) { "Some title" }

    it "emits a chat created event" do
      expect(message_service).to receive(:create_once_for_stream!).with(
        schema: Events::ChatCreated::V2,
        application_id:,
        data: {
          employer_id: recruiter.employer_id,
          job_id:,
          seeker_id:,
          title:
        }
      ).and_call_original

      subject
    end
  end
end
