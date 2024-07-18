FactoryBot.define do
  factory :people_search_coach, class: 'PeopleSearch::Coach' do
    email { Faker::Internet.email }
  end
end
