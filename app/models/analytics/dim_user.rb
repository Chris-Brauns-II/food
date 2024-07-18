# == Schema Information
#
# Table name: analytics_dim_users
#
#  id              :bigint           not null, primary key
#  email           :string
#  first_name      :string
#  kind            :string
#  last_active_at  :datetime
#  last_name       :string
#  user_created_at :datetime         not null
#  coach_id        :uuid
#  user_id         :string           not null
#
# Indexes
#
#  index_analytics_dim_users_on_coach_id  (coach_id) UNIQUE
#  index_analytics_dim_users_on_user_id   (user_id) UNIQUE
#
module Analytics
  class DimUser < ApplicationRecord
    module Kind
      ALL = [
        USER = 'user'.freeze,
        COACH = 'coach'.freeze,
        RECRUITER = 'recruiter'.freeze,
        TRAINING_PROVIDER = 'training_provider'.freeze
      ].freeze
    end

    validates :kind, presence: true, inclusion: { in: Kind::ALL }
  end
end
