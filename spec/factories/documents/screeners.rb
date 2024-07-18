FactoryBot.define do
  factory :documents__screener, class: "Documents::Screener" do
    id { SecureRandom.uuid }
    document_kind { Documents::DocumentKind::PDF }
    requestor_type { Requestor::Kinds::USER }
    requestor_id { SecureRandom.uuid }

    screener_answers_id { SecureRandom.uuid }
    status { Documents::DocumentStatus::PROCESSING }

    person_id { nil }
    storage_kind { nil }
    storage_identifier { nil }
    document_generated_at { nil }
  end
end
