class AddPersonIdToScreenerAnswers < ActiveRecord::Migration[7.1]
  def change
    add_column :screeners_answers, :person_id, :uuid
  end
end
