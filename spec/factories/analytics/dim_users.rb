FactoryBot.define do
  factory :analytics__dim_user, class: "Analytics::DimUser" do
    kind { Analytics::DimUser::Kind::USER }
    email { "an@email.com" }
    first_name { "Khushi" }
    last_name { "Mohapatra" }
    user_created_at { Faker::Time.backward(days: 14) }
    user_id { SecureRandom.uuid }
  end
end
