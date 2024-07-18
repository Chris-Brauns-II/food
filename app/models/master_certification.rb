# == Schema Information
#
# Table name: master_certifications
#
#  id            :text             not null, primary key
#  certification :text             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class MasterCertification < ApplicationRecord
end
