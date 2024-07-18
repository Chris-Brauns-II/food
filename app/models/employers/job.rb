# == Schema Information
#
# Table name: employers_jobs
#
#  id                           :uuid             not null, primary key
#  benefits_description         :string           not null
#  category                     :string           default("marketplace"), not null
#  elevator_pitch               :text
#  employment_title             :string           not null
#  employment_type              :string           not null
#  hide_job                     :boolean          default(FALSE), not null
#  industry                     :string           default([]), is an Array
#  location                     :string           not null
#  requirements_description     :string
#  responsibilities_description :string
#  schedule                     :string
#  work_days                    :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  employers_employer_id        :uuid             not null
#  job_id                       :string           not null
#
# Indexes
#
#  index_employers_jobs_on_employers_employer_id  (employers_employer_id)
#
# Foreign Keys
#
#  fk_rails_...  (employers_employer_id => employers_employers.id)
#
module Employers
  class Job < ApplicationRecord
    belongs_to :employer, class_name: "Employers::Employer", foreign_key: "employers_employer_id", inverse_of: :jobs
    has_many :applicants, class_name: "Employers::Applicant", foreign_key: "employers_job_id", inverse_of: :job, dependent: :destroy
    has_many :job_owners, class_name: "Employers::JobOwner", foreign_key: "employers_job_id", inverse_of: :job, dependent: :destroy

    scope :active, -> { where(hide_job: false) }

    def owner_emails
      return job_owners.map(&:email) if job_owners.present?

      return employer.recruiters.map(&:email) if employer.recruiters.present?

      ["chris@skillarc.com"]
    end
  end
end
