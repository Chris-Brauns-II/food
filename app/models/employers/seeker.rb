# == Schema Information
#
# Table name: employers_seekers
#
#  id           :uuid             not null, primary key
#  certified_by :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  seeker_id    :uuid             not null
#
# Indexes
#
#  index_employers_seekers_on_seeker_id  (seeker_id)
#
module Employers
  class Seeker < ApplicationRecord
  end
end
