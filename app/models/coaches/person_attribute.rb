# == Schema Information
#
# Table name: coaches_person_attributes
#
#  id                        :uuid             not null, primary key
#  name                      :string           not null
#  values                    :string           default([]), is an Array
#  attribute_id              :uuid             not null
#  coaches_person_context_id :uuid             not null
#
# Indexes
#
#  index_coaches_person_attributes_on_coaches_person_context_id  (coaches_person_context_id)
#
module Coaches
  class PersonAttribute < ApplicationRecord
    belongs_to :person_context, class_name: "Coaches::PersonContext", foreign_key: "coaches_person_context_id", inverse_of: :person_attributes
  end
end
