class CreateScreenerAnswers < ActiveRecord::Migration[7.1]
  def change
    create_table :screeners_answers, id: :uuid do |t|
      t.string :title, null: false
      t.jsonb :question_responses, null: false
      t.references :screeners_questions, foreign_key: true, type: :uuid, null: false
      t.timestamps
    end
  end
end
