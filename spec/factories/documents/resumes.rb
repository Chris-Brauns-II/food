FactoryBot.define do
  factory :documents__resume, class: "Documents::Resume" do
    id { SecureRandom.uuid }
    document_kind { Documents::DocumentKind::PDF }
    requestor_type { Requestor::Kinds::USER }
    requestor_id { SecureRandom.uuid }

    person_id { SecureRandom.uuid }
    status { Documents::DocumentStatus::PROCESSING }
    anonymized { false }

    storage_kind { nil }
    storage_identifier { nil }
    document_generated_at { nil }
  end
end
