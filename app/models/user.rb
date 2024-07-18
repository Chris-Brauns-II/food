# == Schema Information
#
# Table name: users
#
#  id             :text             not null, primary key
#  email          :text
#  email_verified :datetime
#  first_name     :text
#  image          :text
#  last_name      :text
#  phone_number   :text
#  sub            :string           not null
#  zip_code       :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  person_id      :uuid
#
# Indexes
#
#  User_email_key      (email) UNIQUE
#  index_users_on_sub  (sub) UNIQUE
#
class User < ApplicationRecord
  has_one :recruiter, dependent: :destroy
  has_one :seeker, dependent: :destroy
  has_many :user_roles, dependent: :destroy
  has_many :training_provider_profiles, dependent: :destroy

  def employer_admin_role?
    role?(Role::Types::EMPLOYER_ADMIN)
  end

  def job_order_admin_role?
    role?(Role::Types::JOB_ORDER_ADMIN)
  end

  def coach_role?
    role?(Role::Types::COACH)
  end

  def admin_role?
    role?(Role::Types::ADMIN)
  end

  def role?(role)
    roles.any? { |r| r == role }
  end

  def roles
    user_roles.pluck(:role)
  end

  def training_provider_profile
    training_provider_profiles.order(created_at: :desc).first
  end
end
