FactoryBot.define do
  factory :invites__employer_invite, class: "Invites::EmployerInvite" do
    id { SecureRandom.uuid }
    email { "fake@email.com" }
    first_name { "Recruitor" }
    last_name { "Person" }
    employer_id { SecureRandom.uuid }
    employer_name { "SkillArc" }
    used_at { nil }
  end
end
