# == Schema Information
#
# Table name: employers_recruiters
#
#  id                    :uuid             not null, primary key
#  email                 :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  employers_employer_id :uuid             not null
#
# Indexes
#
#  index_employers_recruiters_on_email                  (email) UNIQUE
#  index_employers_recruiters_on_employers_employer_id  (employers_employer_id)
#
# Foreign Keys
#
#  fk_rails_...  (employers_employer_id => employers_employers.id)
#
module Employers
  class Recruiter < ApplicationRecord
    belongs_to :employer, class_name: "Employers::Employer", foreign_key: "employers_employer_id", inverse_of: :recruiters

    has_many :job_owners, class_name: "Employers::JobOwner", foreign_key: "employers_recruiter_id", inverse_of: :recruiter, dependent: :destroy
  end
end
