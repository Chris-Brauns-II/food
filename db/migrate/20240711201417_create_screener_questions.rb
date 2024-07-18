class CreateScreenerQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :screeners_questions, id: :uuid do |t|
      t.string :title, null: false
      t.jsonb :questions, null: false
      t.timestamps
    end
  end
end
