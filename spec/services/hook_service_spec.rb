require 'rails_helper'

RSpec.describe HookService do
  describe "#create_notification" do
    subject do
      described_class.new.create_notification(
        email:,
        title:,
        body:,
        url:
      )
    end

    include_context "event emitter"

    let(:email) { user.email }
    let(:title) { Faker::Lorem.sentence }
    let(:body) { Faker::Lorem.paragraph }
    let(:url) { Faker::Internet.url }

    let(:user) { create(:user) }

    it "enqueues a notification created event job" do
      expect_any_instance_of(MessageService).to receive(:create!).with(
        schema: Events::NotificationCreated::V3,
        message_id: be_a(String),
        data: {
          user_id: user.id,
          notification_id: be_a(String),
          title:,
          body:,
          url:
        }
      ).and_call_original

      subject
    end
  end
end
