FactoryBot.define do
  factory :analytics__dim_employer, class: "Analytics::DimEmployer" do
    name { "SkillArc" }
    employer_id { SecureRandom.uuid }
  end
end
