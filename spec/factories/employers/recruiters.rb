FactoryBot.define do
  factory :employers_recruiter, class: 'Employers::Recruiter' do
    employer factory: %i[employers_employer]

    email { Faker::Internet.email }
  end
end
