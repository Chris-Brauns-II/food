FactoryBot.define do
  factory :coaches__person_job_recommendation, class: "Coaches::PersonJobRecommendation" do
    person_context factory: %i[coaches__person_context]
    job factory: %i[coaches__job]
    coach factory: %i[coaches__coach]
  end
end
