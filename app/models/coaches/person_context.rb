# == Schema Information
#
# Table name: coaches_person_contexts
#
#  id                 :uuid             not null, primary key
#  assigned_coach     :string
#  barriers           :uuid             default([]), is an Array
#  captured_by        :string
#  certified_by       :string
#  email              :string
#  first_name         :string
#  kind               :string           not null
#  last_active_on     :datetime
#  last_contacted_at  :datetime
#  last_name          :string
#  person_captured_at :datetime         not null
#  phone_number       :string
#  user_id            :string
#
# Indexes
#
#  index_coaches_person_contexts_on_kind     (kind)
#  index_coaches_person_contexts_on_user_id  (user_id)
#
module Coaches
  class PersonContext < ApplicationRecord
    module Kind
      ALL = [
        SEEKER = "seeker".freeze,
        LEAD = "lead".freeze
      ].freeze
    end

    has_many :notes, dependent: :destroy, class_name: "Coaches::PersonNote", inverse_of: :person_context
    has_many :applications, dependent: :destroy, class_name: "Coaches::PersonApplication", inverse_of: :person_context
    has_many :job_recommendations, dependent: :destroy, class_name: "Coaches::PersonJobRecommendation", inverse_of: :person_context
    has_many :person_attributes, dependent: :destroy, class_name: "Coaches::PersonAttribute", inverse_of: :person_context

    validates :kind, allow_nil: true, inclusion: { in: Kind::ALL }

    scope :leads, -> { where(kind: Kind::LEAD) }
    scope :seekers, -> { where(kind: Kind::SEEKER) }
  end
end
