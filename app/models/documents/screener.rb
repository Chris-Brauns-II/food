# == Schema Information
#
# Table name: documents_screeners
#
#  id                    :uuid             not null, primary key
#  document_generated_at :datetime
#  document_kind         :string           not null
#  requestor_type        :string           not null
#  status                :string           not null
#  storage_identifier    :string
#  storage_kind          :string
#  person_id             :uuid
#  requestor_id          :string           not null
#  screener_answers_id   :uuid             not null
#
# Indexes
#
#  index_documents_screeners_on_person_id            (person_id)
#  index_documents_screeners_on_requestor_id         (requestor_id)
#  index_documents_screeners_on_screener_answers_id  (screener_answers_id)
#
module Documents
  class Screener < ApplicationRecord
  end
end
