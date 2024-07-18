# == Schema Information
#
# Table name: seekers
#
#  id           :uuid             not null, primary key
#  about        :text
#  bio          :string
#  email        :string
#  first_name   :string
#  image        :string
#  last_name    :string
#  phone_number :string
#  zip_code     :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :text
#
# Indexes
#
#  index_seekers_on_user_id  (user_id)
#
class Seeker < ApplicationRecord
  has_many :applicants, dependent: :destroy
  has_many :education_experiences, dependent: :destroy
  has_many :other_experiences, dependent: :destroy
  has_many :personal_experiences, dependent: :destroy
  has_many :profile_skills, dependent: :destroy
  has_many :references, class_name: "Reference", dependent: :destroy
  has_many :stories, dependent: :destroy
  has_many :seeker_training_providers, dependent: :destroy
  has_one :onboarding_session, dependent: :destroy
end
