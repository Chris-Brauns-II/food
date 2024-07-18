FactoryBot.define do
  factory :employers_seeker, class: 'Employers::Seeker' do
    seeker_id { SecureRandom.uuid }
    certified_by { "john@skillarc.com" }
  end
end
