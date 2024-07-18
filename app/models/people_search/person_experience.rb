# == Schema Information
#
# Table name: people_search_person_experiences
#
#  id                :uuid             not null, primary key
#  description       :text
#  organization_name :string
#  position          :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  person_id         :uuid             not null
#
# Indexes
#
#  index_people_search_person_experiences_on_person_id  (person_id)
#
# Foreign Keys
#
#  fk_rails_...  (person_id => people_search_people.id) ON DELETE => cascade
#
module PeopleSearch
  class PersonExperience < ApplicationRecord
    belongs_to :person, class_name: "PeopleSearch::Person"
  end
end
