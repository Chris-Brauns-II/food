require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe "#authorize" do
    controller do
      include Secured

      before_action :authorize

      def example
        render json: @current_user
      end
    end

    let(:auth_client) do
      AuthClient::Fake.new(
        email:,
        sub: 'some_sub'
      )
    end
    let(:user_finder) do
      UserFinder.new
    end
    let(:token) { '123' }
    let(:email) { 'some@email.com' }

    it "doesn't explode" do
      request.headers['Authorization'] = "Bearer #{token}"

      expect(AuthClient::Factory)
        .to receive(:build)
        .and_return(auth_client)

      expect_any_instance_of(MessageService)
        .to receive(:create!)
        .with(
          user_id: be_a(String),
          schema: Events::UserCreated::V1,
          data: {
            email:,
            first_name: nil,
            last_name: nil,
            sub: token
          },
          occurred_at: anything
        ).and_call_original

      routes.draw { get 'example' => 'anonymous#example' }
      get :example

      expect(response).to be_successful

      body = response.parsed_body
      expect(body['email']).to eq(email)
      expect(body['sub']).to eq(token)
    end
  end
end
