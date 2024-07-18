# == Schema Information
#
# Table name: onboarding_sessions
#
#  id           :text             not null, primary key
#  completed_at :datetime
#  responses    :jsonb            not null
#  started_at   :datetime         not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  seeker_id    :uuid             not null
#
# Indexes
#
#  index_onboarding_sessions_on_seeker_id  (seeker_id) UNIQUE
#
class OnboardingSession < ApplicationRecord
  belongs_to :seeker

  def industry_interests
    # begin
    #   responses["opportunityInterests"]["response"].map(&:downcase)
    # rescue
    %w[construction manufacturing healthcare]
    # end
  end
end
