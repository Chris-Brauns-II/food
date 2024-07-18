class AddPersonIdToNonNullValidateToScreenerAnswers < ActiveRecord::Migration[7.1]
  def change
    validate_check_constraint :screeners_answers, name: "screeners_answers_person_id_null"
    change_column_null :screeners_answers, :person_id, false
    remove_check_constraint :screeners_answers, name: "screeners_answers_person_id_null"
  end
end
