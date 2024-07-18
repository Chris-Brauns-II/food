FactoryBot.define do
  factory :seeker do
    user_id { SecureRandom.uuid }

    first_name { "Chris" }
    last_name { "Skill" }
    email { "cool@person.com" }
    phone_number { "+13333333333" }
    zip_code { "45662" }

    id { SecureRandom.uuid }
    about { "I'm a good worker" }
    bio { "I'm Mary and I'm a good worker" }
    image { "www.images.com/my_image/123" }
  end
end
