# frozen_string_literal: true

# == Schema Information
#
# Table name: user_roles
#
#  id      :bigint           not null, primary key
#  role    :string           not null
#  user_id :text             not null
#
# Indexes
#
#  index_user_roles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class UserRole < ApplicationRecord
  belongs_to :user
end
