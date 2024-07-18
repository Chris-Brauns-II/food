require 'rails_helper'

RSpec.describe Contact::ContactAggregator do
  it_behaves_like "a replayable message consumer"

  describe "#handle_message" do
    subject { described_class.new.handle_message(message) }

    context "when the message is notification created" do
      let(:message) do
        build(
          :message,
          schema: Events::NotificationCreated::V3,
          data: {
            user_id: SecureRandom.uuid,
            title: "A title",
            body: "A body",
            url: "A url",
            notification_id: SecureRandom.uuid
          }
        )
      end

      it "persists a notification record" do
        subject

        notification = Contact::Notification.last_created
        expect(notification.id).to eq(message.data.notification_id)
        expect(notification.user_id).to eq(message.data.user_id)
        expect(notification.title).to eq(message.data.title)
        expect(notification.body).to eq(message.data.body)
        expect(notification.url).to eq(message.data.url)
      end
    end

    context "when the message is notification marked read" do
      let(:message) do
        build(
          :message,
          schema: Events::NotificationMarkedRead::V2,
          data: {
            notification_ids: [notification1.id, notification2.id]
          }
        )
      end

      let(:notification1) { create(:contact__notification) }
      let(:notification2) { create(:contact__notification) }

      it "persists a notification record" do
        subject

        notification1.reload
        notification2.reload

        expect(notification1.read_at).to eq(message.occurred_at)
        expect(notification2.read_at).to eq(message.occurred_at)
      end
    end
  end
end
