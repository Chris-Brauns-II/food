# == Schema Information
#
# Table name: coaches_person_notes
#
#  id                        :uuid             not null, primary key
#  note                      :text             not null
#  note_taken_at             :datetime         not null
#  note_taken_by             :string           not null
#  coaches_person_context_id :uuid             not null
#
# Indexes
#
#  index_coaches_person_notes_on_coaches_person_context_id  (coaches_person_context_id)
#
module Coaches
  class PersonNote < ApplicationRecord
    belongs_to :person_context, class_name: "Coaches::PersonContext", foreign_key: "coaches_person_context_id", inverse_of: :notes
  end
end
