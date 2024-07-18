require 'rails_helper'

RSpec.describe People::BasicInfoService do
  describe ".update" do
    subject { described_class.new(user_id, message_service).update(about:, first_name:, last_name:, phone_number:, zip_code:, email:) }

    let(:message_service) { MessageService.new }
    let(:user_id) { user.id }
    let(:user) { create(:user) }
    let!(:seeker) { create(:seeker, user_id: user.id) }
    let(:about) { "New About" }
    let(:first_name) { "New First Name" }
    let(:last_name) { "New Last Name" }
    let(:phone_number) { "1234567890" }
    let(:email) { "A@B.C" }
    let(:zip_code) { "12345" }
    let(:stream) { Streams::Person.new(person_id: seeker.id) }

    it "publishes a basic info added event" do
      allow(message_service).to receive(:create!)
      expect(message_service).to receive(:create!).with(
        schema: Events::BasicInfoAdded::V1,
        stream:,
        data: {
          first_name:,
          last_name:,
          phone_number:,
          email:
        }
      ).and_call_original

      expect(message_service).to receive(:create!).with(
        schema: Events::ZipAdded::V2,
        stream:,
        data: {
          zip_code:
        }
      ).and_call_original

      expect(message_service).to receive(:create!).with(
        schema: Events::PersonAboutAdded::V1,
        stream:,
        data: {
          about:
        }
      ).and_call_original

      subject
    end
  end
end
