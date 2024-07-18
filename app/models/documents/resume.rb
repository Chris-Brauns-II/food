# == Schema Information
#
# Table name: documents_resumes
#
#  id                    :uuid             not null, primary key
#  anonymized            :boolean          not null
#  document_generated_at :datetime
#  document_kind         :string           not null
#  requestor_type        :string           not null
#  status                :string           not null
#  storage_identifier    :string
#  storage_kind          :string
#  person_id             :uuid             not null
#  requestor_id          :string           not null
#
# Indexes
#
#  index_documents_resumes_on_person_id     (person_id)
#  index_documents_resumes_on_requestor_id  (requestor_id)
#
module Documents
  class Resume < ApplicationRecord
  end
end
