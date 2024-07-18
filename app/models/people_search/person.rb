# == Schema Information
#
# Table name: people_search_people
#
#  id                :uuid             not null, primary key
#  assigned_coach    :string
#  certified_by      :string
#  date_of_birth     :date
#  email             :string
#  first_name        :string
#  last_active_at    :datetime
#  last_contacted_at :datetime
#  last_name         :string
#  phone_number      :string
#  search_vector     :text             not null
#  user_id           :string
#
module PeopleSearch
  class Person < ApplicationRecord
    has_many :experiences, class_name: "PeopleSearch::PersonExperience", dependent: :destroy
    has_many :education_experiences, class_name: "PeopleSearch::PersonEducationExperience", dependent: :destroy
  end
end
