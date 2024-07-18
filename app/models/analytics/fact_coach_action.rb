# == Schema Information
#
# Table name: analytics_fact_coach_actions
#
#  id                             :bigint           not null, primary key
#  action                         :string           not null
#  action_taken_at                :datetime         not null
#  analytics_dim_person_target_id :bigint
#  analytics_dim_users_id         :bigint           not null
#
# Indexes
#
#  idx_on_analytics_dim_person_target_id_a665f20399              (analytics_dim_person_target_id)
#  index_analytics_fact_coach_actions_on_action                  (action)
#  index_analytics_fact_coach_actions_on_analytics_dim_users_id  (analytics_dim_users_id)
#
# Foreign Keys
#
#  fk_rails_...  (analytics_dim_person_target_id => analytics_dim_people.id)
#
module Analytics
  class FactCoachAction < ApplicationRecord
    module Actions
      ALL = [
        JOB_RECOMMENDED = "job_recommended".freeze,
        SEEKER_CERTIFIED = "seeker_certified".freeze,
        NOTE_ADDED = "note_added".freeze,
        NOTE_MODIFIED = "note_modified".freeze,
        NOTE_DELETED = "note_deleted".freeze,
        LEAD_ADDED = "lead_added".freeze
      ].freeze
    end

    validates :action, inclusion: { in: Actions::ALL }
    belongs_to :dim_user_executor, class_name: "Analytics::DimUser", foreign_key: "analytics_dim_users_id" # rubocop:disable Rails/InverseOf
    belongs_to :dim_person_target, optional: true, class_name: "Analytics::DimPerson", foreign_key: "analytics_dim_person_target_id", inverse_of: :fact_applications
  end
end
