# == Schema Information
#
# Table name: coaches_person_job_recommendations
#
#  id                         :bigint           not null, primary key
#  coaches_coaches_id         :uuid             not null
#  coaches_jobs_id            :uuid             not null
#  coaches_person_contexts_id :uuid             not null
#
# Indexes
#
#  idx_on_coaches_person_contexts_id_5ae9369261                    (coaches_person_contexts_id)
#  index_coaches_person_job_recommendations_on_coaches_coaches_id  (coaches_coaches_id)
#  index_coaches_person_job_recommendations_on_coaches_jobs_id     (coaches_jobs_id)
#
module Coaches
  class PersonJobRecommendation < ApplicationRecord
    belongs_to :person_context, class_name: "Coaches::PersonContext", foreign_key: "coaches_person_contexts_id", inverse_of: :job_recommendations
    belongs_to :job, class_name: "Coaches::Job", foreign_key: "coaches_jobs_id", inverse_of: :job_recommendations

    belongs_to :coach, class_name: "Coaches::Coach", foreign_key: "coaches_coaches_id", inverse_of: :job_recommendations
  end
end
