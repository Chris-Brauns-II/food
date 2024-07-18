require 'rails_helper'

RSpec.describe SeekerChats do
  let(:user) { create(:user) }
  let(:seeker) { create(:seeker, first_name: "Jake", last_name: "Not-Onboard", user_id: user.id) }
  let(:instance) { described_class.new(seeker:, message_service:) }
  let(:message_service) { MessageService.new }

  describe "#send_message" do
    subject { instance.send_message(application_id:, message:) }

    let(:application_id) { SecureRandom.uuid }
    let(:message) { "Some message" }

    it "emits a chat message sent event" do
      expect(message_service).to receive(:create!).with(
        schema: Events::ChatMessageSent::V2,
        application_id:,
        data: {
          from_name: "Jake Not-Onboard",
          from_user_id: user.id,
          message:
        }
      ).and_call_original

      subject
    end
  end

  describe "#get" do
    subject { instance.get }

    let!(:applicant_chat) do
      create(
        :chats__applicant_chat,
        application_id:,
        seeker_id: seeker.id,
        title: "Acme, Inc - Welder",
        chat_updated_at: Time.zone.local(2000, 1, 1)
      )
    end
    let!(:message1) do
      create(
        :chats__message,
        applicant_chat:,
        message: "This is a message from the applicant",
        from: "Jake Not-Onboard",
        user_id: user.id,
        message_sent_at: Time.zone.local(2000, 1, 1)
      )
    end
    let!(:message2) do
      create(
        :chats__message,
        applicant_chat:,
        message: "This is a message from the employer",
        from: "John Doe",
        user_id: SecureRandom.uuid,
        message_sent_at: Time.zone.local(2010, 1, 1)
      )
    end
    let!(:read_receipt) do
      create(
        :chats__read_receipt,
        applicant_chat:,
        user_id: user.id,
        read_until: Time.zone.local(2005, 1, 1)
      )
    end

    let(:application_id) { SecureRandom.uuid }

    it "returns the applicant chat" do
      expect(subject.first).to match(
        {
          id: application_id,
          name: "Acme, Inc - Welder",
          updatedAt: Time.zone.local(2000, 1, 1),
          messages: [
            {
              id: message1.id,
              text: "This is a message from the applicant",
              isUser: true,
              isRead: true,
              sender: "Jake Not-Onboard"
            },
            {
              id: message2.id,
              text: "This is a message from the employer",
              isUser: false,
              isRead: false,
              sender: "John Doe"
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
            read_by_user_id: user.id
          }
        )

      subject
    end
  end
end
