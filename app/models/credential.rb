# == Schema Information
#
# Table name: credentials
#
#  id              :text             not null, primary key
#  description     :text
#  issued_date     :text
#  name            :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :text
#  seeker_id       :uuid             not null
#
# Foreign Keys
#
#  Credential_organization_id_fkey  (organization_id => organizations.id) ON DELETE => nullify ON UPDATE => cascade
#
class Credential < ApplicationRecord
end
