require 'rails_helper'

RSpec.describe Chats::ChatsAggregator do
  it_behaves_like "a replayable message consumer"

  describe "#handle_message" do
    subject { instance.handle_message(message) }

    let(:instance) { described_class.new }

    context "when the message is chat created" do
      let(:message) do
        build(
          :message,
          schema: Events::ChatCreated::V2,
          data: {
            employer_id: SecureRandom.uuid,
            job_id: SecureRandom.uuid,
            seeker_id: SecureRandom.uuid,
            title: "A title"
          }
        )
      end

      it "creates a applicant chat record" do
        expect { subject }.to change(Chats::ApplicantChat, :count).from(0).to(1)

        applicant_chat = Chats::ApplicantChat.take(1).first
        expect(applicant_chat.application_id).to eq(message.stream.id)
        expect(applicant_chat.chat_created_at).to eq(message.occurred_at)
        expect(applicant_chat.title).to eq("A title")
        expect(applicant_chat.employer_id).to eq(message.data.employer_id)
        expect(applicant_chat.seeker_id).to eq(message.data.seeker_id)
      end
    end

    context "when the message is job updated" do
      let(:message) do
        build(
          :message,
          stream_id: applicant_chat.application_id,
          schema: Events::ChatMessageSent::V2,
          data: {
            from_name: "Uncle Bob",
            from_user_id: SecureRandom.uuid,
            message: "Hey my top dawg"
          }
        )
      end

      let!(:applicant_chat) { create(:chats__applicant_chat) }

      it "creates a chat message" do
        expect { subject }.to change(Chats::Message, :count).from(0).to(1)

        chat_message = Chats::Message.take(1).first
        expect(chat_message.applicant_chat).to eq(applicant_chat)
        expect(chat_message.message).to eq("Hey my top dawg")
        expect(chat_message.from).to eq("Uncle Bob")
        expect(chat_message.message_sent_at).to eq(message.occurred_at)

        applicant_chat.reload
        expect(applicant_chat.chat_updated_at).to eq(message.occurred_at)
      end
    end

    context "when the message is chat read" do
      let(:message) do
        build(
          :message,
          stream_id: applicant_chat.application_id,
          schema: Events::ChatRead::V1,
          data: {
            read_by_user_id: user_id
          }
        )
      end

      let!(:applicant_chat) { create(:chats__applicant_chat) }
      let(:user_id) { SecureRandom.uuid }

      context "when a read reciept exists for the user" do
        let!(:read_receipt) { create(:chats__read_receipt, applicant_chat:) }
        let(:user_id) { read_receipt.user_id }

        it "update a read reciept read until" do
          expect { subject }.not_to change(Chats::ReadReceipt, :count)

          read_receipt.reload
          expect(read_receipt.read_until).to eq(message.occurred_at)
        end
      end

      context "when a read reciept does not exists for the user" do
        it "creates a read reciept record" do
          expect { subject }.to change(Chats::ReadReceipt, :count).from(0).to(1)

          read_receipt = Chats::ReadReceipt.take(1).first
          expect(read_receipt.applicant_chat).to eq(applicant_chat)
          expect(read_receipt.user_id).to eq(message.data.read_by_user_id)
          expect(read_receipt.read_until).to eq(message.occurred_at)
        end
      end
    end
  end
end
