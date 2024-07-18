FactoryBot.define do
  factory :people_search_person_experience, class: 'PeopleSearch::PersonExperience' do
    position { "Welder" }
    organization_name { "Welding Inc." }
    description { "Welded things" }
  end
end
