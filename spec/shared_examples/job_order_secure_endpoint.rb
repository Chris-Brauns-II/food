RSpec.shared_context "job order authenticated" do
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
      role: Role::Types::JOB_ORDER_ADMIN
    )

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

RSpec.shared_examples "an unauthenticated user" do
  let(:Authorization) { nil }

  response '401', 'unauthenticated' do
    run_test!
  end
end
