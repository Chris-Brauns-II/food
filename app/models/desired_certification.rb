# == Schema Information
#
# Table name: desired_certifications
#
#  id                      :text             not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  job_id                  :text             not null
#  master_certification_id :text             not null
#
# Foreign Keys
#
#  DesiredCertification_job_id_fkey  (job_id => jobs.id) ON DELETE => restrict ON UPDATE => cascade
#
class DesiredCertification < ApplicationRecord
  belongs_to :job

  def master_certification
    MasterCertification.find_by(id: master_certification_id)
  end
end
