# == Schema Information
#
# Table name: applicant_statuses
#
#  id           :text             not null, primary key
#  status       :text             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  applicant_id :text             not null
#
# Foreign Keys
#
#  ApplicantStatus_applicant_id_fkey  (applicant_id => applicants.id) ON DELETE => restrict ON UPDATE => cascade
#
class ApplicantStatus < ApplicationRecord
  belongs_to :applicant
  has_many :applicant_status_reasons, dependent: :destroy

  module StatusTypes
    ALL = [
      NEW = "new".freeze,
      PENDING_INTRO = "pending intro".freeze,
      INTRO_MADE = "intro made".freeze,
      INTERVIEWING = "interviewing".freeze,
      HIRE = "hire".freeze,
      PASS = "pass".freeze
    ].freeze
  end

  validates :status, inclusion: { in: StatusTypes::ALL }
end
