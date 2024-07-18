# == Schema Information
#
# Table name: education_experiences
#
#  id                :text             not null, primary key
#  activities        :text
#  gpa               :text
#  graduation_date   :text
#  organization_name :text
#  title             :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  organization_id   :text
#  seeker_id         :uuid             not null
#
# Indexes
#
#  index_education_experiences_on_seeker_id  (seeker_id)
#
# Foreign Keys
#
#  EducationExperience_organization_id_fkey  (organization_id => organizations.id) ON DELETE => nullify ON UPDATE => cascade
#  fk_rails_...                              (seeker_id => seekers.id)
#
class EducationExperience < ApplicationRecord
  belongs_to :seeker
end
