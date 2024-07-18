FactoryBot.define do
  factory :people_search_person, class: 'PeopleSearch::Person' do
    first_name { "John" }
    last_name { "Doe" }
    email { "john.doe@skillarc.com" }
    phone_number { "555-555-5555" }
    search_vector { "John Doe 555-555-5555 john.doe@skillarc.com 1990-01-01" }
    date_of_birth { "1990-01-01" }
    user_id { SecureRandom.uuid }
  end
end
