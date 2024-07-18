RSpec.shared_context "coach authenticated" do
  let!(:user) do
    u = User.create!(
      id: '1a7d78bd-ae41-4d09-95d5-0b417efbcb7f',
      first_name: 'Jake',
      last_name: 'Not-Onboard',
      email: 'jake@statefarm.com',
      sub: 'jakesub'
    )

    UserRole.create!(
      id: SecureRandom.uuid,
      user_id: u.id,
      role: Role::Types::COACH
    )

    u
  end
  let!(:coach) { create(:coaches__coach, user_id: user.id) }

  let(:headers) { { "Authorization" => "Bearer #{user.sub}" } }

  around do |example|
    original = ENV.fetch("MOCK_AUTH", nil)
    ENV["MOCK_AUTH"] = "true"

    example.run

    ENV["MOCK_AUTH"] = original
  end
end

RSpec.shared_examples "coach secured endpoint" do
  context "unauthenticated" do
    it "returns 401" do
      subject

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "authenticated" do
    include_context "coach authenticated"

    it "returns 2XX" do
      subject

      expect(response.status).to be_between(200, 299).inclusive
    end
  end
end

RSpec.shared_context "coach authenticated openapi" do
  let!(:user) do
    u = User.create!(
      id: '1a7d78bd-ae41-4d09-95d5-0b417efbcb7f',
      first_name: 'Jake',
      last_name: 'Not-Onboard',
      email: 'jake@statefarm.com',
      sub: 'jakesub',
      person_id: SecureRandom.uuid
    )

    UserRole.create!(
      id: SecureRandom.uuid,
      user_id: u.id,
      role: Role::Types::COACH
    )

    u
  end
  let!(:coach) { create(:coaches__coach, user_id: user.id) }

  let(:Authorization) { "Bearer #{user.sub}" }

  around do |example|
    original = ENV.fetch("MOCK_AUTH", nil)
    ENV["MOCK_AUTH"] = "true"

    example.run

    ENV["MOCK_AUTH"] = original
  end
end

RSpec.shared_examples "coach spec unauthenticated openapi" do
  let(:Authorization) { nil }

  response '401', 'unauthenticated' do
    run_test!
  end
end
