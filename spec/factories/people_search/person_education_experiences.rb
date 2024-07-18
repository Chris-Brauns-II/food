FactoryBot.define do
  factory :people_search_person_education_experience, class: 'PeopleSearch::PersonEducationExperience' do
    title { "Bachelor of Science in Computer Science" }
    activities { "Studied computer science" }
    organization_name { "Organization, Inc" }
  end
end
