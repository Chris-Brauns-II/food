# == Schema Information
#
# Table name: people_search_person_education_experiences
#
#  id                :uuid             not null, primary key
#  activities        :text
#  organization_name :string
#  title             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  person_id         :uuid             not null
#
# Indexes
#
#  index_people_search_person_education_experiences_on_person_id  (person_id)
#
# Foreign Keys
#
#  fk_rails_...  (person_id => people_search_people.id) ON DELETE => cascade
#
module PeopleSearch
  class PersonEducationExperience < ApplicationRecord
    belongs_to :person, class_name: "PeopleSearch::Person"
  end
end
