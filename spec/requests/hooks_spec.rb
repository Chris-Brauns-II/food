require 'rails_helper'

RSpec.describe "Hooks", type: :request do
  describe "POST /event" do
    subject { post hooks_event_path(hook), params:, headers: }

    let(:hook) { create(:webhook) }

    let(:params) do
      {
        email: user.email,
        title:,
        body:,
        url:
      }
    end
    let(:user) { create(:user) }
    let(:title) { Faker::Lorem.sentence }
    let(:body) { Faker::Lorem.paragraph }
    let(:url) { Faker::Internet.url }

    it "returns a 200" do
      subject

      expect(response).to have_http_status(:ok)
    end

    it "calls the hook service" do
      expect_any_instance_of(HookService).to receive(:create_notification).with(
        email: user.email,
        title:,
        body:,
        url:
      )

      subject
    end
  end
end
