# == Schema Information
#
# Table name: employers_applicants
#
#  id                    :uuid             not null, primary key
#  application_submit_at :datetime
#  certified_by          :string
#  email                 :string           not null
#  first_name            :string           not null
#  last_name             :string           not null
#  phone_number          :string
#  status                :string           not null
#  status_as_of          :datetime
#  status_reason         :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  applicant_id          :string           not null
#  employers_job_id      :uuid             not null
#  seeker_id             :uuid             not null
#
# Indexes
#
#  index_employers_applicants_on_applicant_id      (applicant_id) UNIQUE
#  index_employers_applicants_on_employers_job_id  (employers_job_id)
#  index_employers_applicants_on_seeker_id         (seeker_id)
#
# Foreign Keys
#
#  fk_rails_...  (employers_job_id => employers_jobs.id)
#
module Employers
  class Applicant < ApplicationRecord
    belongs_to :job, class_name: "Employers::Job", foreign_key: "employers_job_id", inverse_of: :applicants

    module StatusTypes
      ALL = [
        NEW = "new".freeze,
        PENDING_INTRO = "pending intro".freeze,
        INTRO_MADE = "intro made".freeze,
        INTERVIEWING = "interviewing".freeze,
        HIRE = "hire".freeze,
        PASS = "pass".freeze
      ].freeze

      TERMINAL = [HIRE, PASS].freeze
    end

    validates :status, inclusion: { in: StatusTypes::ALL }

    scope :active, -> { where.not(status: StatusTypes::TERMINAL) }
  end
end
