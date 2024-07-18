RSpec.shared_context "authenticated" do
  around do |example|
    original = ENV.fetch("MOCK_AUTH", nil)
    ENV["MOCK_AUTH"] = "true"

    example.run

    ENV["MOCK_AUTH"] = original
  end

  let(:headers) { { "Authorization" => "Bearer #{user.sub}" } }

  let!(:user) do
    User.create!(
      id: '1a7d78bd-ae41-4d09-95d5-0b417efbcb7f',
      first_name: 'Jake',
      last_name: 'Not-Onboard',
      email: 'jake@statefarm.com',
      sub: 'jakesub'
    )
  end
end

RSpec.shared_examples "a secured endpoint" do
  context "unauthenticated" do
    it "returns 401" do
      subject

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "authenticated" do
    include_context "authenticated"

    it "returns 200" do
      subject

      expect(response).to have_http_status(:ok).or have_http_status(:accepted)
    end
  end
end

RSpec.shared_context "unauthenticated" do
  context "unauthenticated" do
    it "returns 401" do
      subject

      expect(response).to have_http_status(:unauthorized)
    end
  end
end

RSpec.shared_context "authenticated openapi" do
  let!(:user) do
    User.create!(
      id: '1a7d78bd-ae41-4d09-95d5-0b417efbcb7f',
      first_name: 'Jake',
      last_name: 'Not-Onboard',
      email: 'jake@statefarm.com',
      sub: 'jakesub'
    )
  end
  let(:Authorization) { "Bearer #{user.sub}" }

  around do |example|
    original = ENV.fetch("MOCK_AUTH", nil)
    ENV["MOCK_AUTH"] = "true"

    example.run

    ENV["MOCK_AUTH"] = original
  end
end

RSpec.shared_context "unauthenticated openapi" do
  let(:Authorization) { nil }
end

RSpec.shared_examples "spec unauthenticated openapi" do
  let(:Authorization) { nil }

  response '401', 'unauthenticated' do
    run_test!
  end
end
