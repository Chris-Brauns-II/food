class AddPersonIdToNonNullConstraintToScreenerAnswers < ActiveRecord::Migration[7.1]
  def change
    add_check_constraint :screeners_answers, "person_id IS NOT NULL", name: "screeners_answers_person_id_null", validate: false
  end
end
