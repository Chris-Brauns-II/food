RSpec.shared_context "employer authenticated" do
  let!(:recruiter) { create(:recruiter, user:, employer_id: employer.id) }
  let!(:employer) { create(:employer) }
  let!(:employers_employer) { create(:employers_employer, employer_id: employer.id, name: employer.name) }
  let!(:employers_recruiter) { create(:employers_recruiter, employer: employers_employer, email: recruiter.user.email) }
  let!(:user) do
    User.create!(
      id: '1a7d78bd-ae41-4d09-95d5-0b417efbcb7f',
      first_name: 'Jake',
      last_name: 'Not-Onboard',
      email: 'jake@statefarm.com',
      sub: 'jakesub'
    )
  end
  let(:headers) { { "Authorization" => "Bearer #{user.sub}" } }

  around do |example|
    original = ENV.fetch("MOCK_AUTH", nil)
    ENV["MOCK_AUTH"] = "true"

    example.run

    ENV["MOCK_AUTH"] = original
  end
end

RSpec.shared_examples "employer spec unauthenticated" do
  it "returns 401" do
    subject

    expect(response).to have_http_status(:unauthorized)
  end
end

RSpec.shared_examples "employer secured endpoint" do
  context "unauthenticated" do
    it "returns 401" do
      subject

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "authenticated" do
    include_context "employer authenticated"

    it "returns 2XX" do
      subject

      expect(response.status).to be_between(200, 299).inclusive
    end
  end
end

RSpec.shared_context "employer authenticated openapi" do
  let!(:recruiter) { create(:recruiter, user:, employer_id: employer.id) }
  let!(:employer) { create(:employer) }
  let!(:employers_employer) { create(:employers_employer, employer_id: employer.id, name: employer.name) }
  let!(:employers_recruiter) { create(:employers_recruiter, employer: employers_employer, email: recruiter.user.email) }
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

RSpec.shared_examples "employer spec unauthenticated openapi" do
  let(:Authorization) { nil }

  response '401', 'unauthenticated' do
    run_test!
  end
end
