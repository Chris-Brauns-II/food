FactoryBot.define do
  factory :user_role do
    user
    role { Role::Types::COACH }
  end
end
