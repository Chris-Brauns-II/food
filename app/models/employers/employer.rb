# == Schema Information
#
# Table name: employers_employers
#
#  id          :uuid             not null, primary key
#  bio         :string           not null
#  location    :string
#  logo_url    :string
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  employer_id :string           not null
#
module Employers
  class Employer < ApplicationRecord
    has_many :jobs, class_name: "Employers::Job", dependent: :destroy, inverse_of: :employer, foreign_key: "employers_employer_id"
    has_many :recruiters, class_name: "Employers::Recruiter", dependent: :destroy, inverse_of: :employer, foreign_key: "employers_employer_id"

    has_many :applicants, through: :jobs

    def active?
      jobs.active.present?
    end
  end
end
