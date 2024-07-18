RSpec.shared_context "admin authenticated" do
  let(:headers) { { "Authorization" => "Bearer #{user.sub}" } }
  let!(:user) do
    u = User.find_or_create_by!(
      id: '1a7d78bd-ae41-4d09-95d5-0b417efbcb7f',
      first_name: 'Jake',
      last_name: 'Not-Onboard',
      email: 'jake@statefarm.com',
      sub: 'jakesub'
    )
    UserRole.create!(id: SecureRandom.uuid, user: u, role: Role::Types::ADMIN)
    u
  end

  around do |example|
    original = ENV.fetch("MOCK_AUTH", nil)
    ENV["MOCK_AUTH"] = "true"

    example.run

    ENV["MOCK_AUTH"] = original
  end
end

RSpec.shared_examples "admin secured endpoint" do
  context "unauthenticated" do
    it "returns 401" do
      subject

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "authenticated" do
    include_context "admin authenticated"

    it "returns 200" do
      subject

      expect(response).to have_http_status(:ok)
    end
  end
end

RSpec.shared_context "admin authenticated openapi" do
  let!(:user) do
    u = User.find_or_create_by!(
      id: '1a7d78bd-ae41-4d09-95d5-0b417efbcb7f',
      first_name: 'Jake',
      last_name: 'Not-Onboard',
      email: 'jake@statefarm.com',
      sub: 'jakesub'
    )
    UserRole.create!(id: SecureRandom.uuid, user: u, role: Role::Types::ADMIN)
    u
  end
  let(:Authorization) { "Bearer #{user.sub}" }

  around do |example|
    original = ENV.fetch("MOCK_AUTH", nil)
    ENV["MOCK_AUTH"] = "true"

    example.run

    ENV["MOCK_AUTH"] = original
  end
end

RSpec.shared_examples "admin spec unauthenticated openapi" do
  let(:Authorization) { nil }

  response '401', 'unauthenticated' do
    run_test!
  end
end
