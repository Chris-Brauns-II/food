# == Schema Information
#
# Table name: barriers
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  barrier_id :uuid             not null
#
# Indexes
#
#  index_barriers_on_barrier_id  (barrier_id) UNIQUE
#
class Barrier < ApplicationRecord
  validates :name, presence: true
  validates :barrier_id, presence: true, uniqueness: true
end
