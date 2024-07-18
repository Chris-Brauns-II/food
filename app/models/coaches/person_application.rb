# == Schema Information
#
# Table name: coaches_person_applications
#
#  id                        :uuid             not null, primary key
#  employer_name             :string           not null
#  employment_title          :string           not null
#  status                    :string           not null
#  coaches_person_context_id :uuid             not null
#  job_id                    :uuid             not null
#
# Indexes
#
#  index_coaches_person_applications_on_coaches_person_context_id  (coaches_person_context_id)
#
module Coaches
  class PersonApplication < ApplicationRecord
    belongs_to :person_context, class_name: "Coaches::PersonContext", foreign_key: "coaches_person_context_id", inverse_of: :applications
  end
end
