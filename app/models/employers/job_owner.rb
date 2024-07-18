# == Schema Information
#
# Table name: employers_job_owners
#
#  id                     :uuid             not null, primary key
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  employers_job_id       :uuid             not null
#  employers_recruiter_id :uuid             not null
#
# Indexes
#
#  index_employers_job_owners_on_employers_job_id        (employers_job_id)
#  index_employers_job_owners_on_employers_recruiter_id  (employers_recruiter_id)
#
# Foreign Keys
#
#  fk_rails_...  (employers_job_id => employers_jobs.id)
#  fk_rails_...  (employers_recruiter_id => employers_recruiters.id)
#
module Employers
  class JobOwner < ApplicationRecord
    belongs_to :job, class_name: "Employers::Job", foreign_key: "employers_job_id", inverse_of: :job_owners
    belongs_to :recruiter, class_name: "Employers::Recruiter", foreign_key: "employers_recruiter_id", inverse_of: :job_owners

    delegate :email, to: :recruiter
  end
end
