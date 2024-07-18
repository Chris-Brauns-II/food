class CreateScreeners < ActiveRecord::Migration[7.1]
  def change
    create_table :documents_screeners, id: :uuid do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.datetime :document_generated_at
      t.string :document_kind, null: false
      t.string :requestor_type, null: false
      t.string :status, null: false
      t.string :storage_identifier
      t.string :storage_kind
      t.string :requestor_id, null: false, index: true
      t.uuid :screener_answers_id, null: false, index: true
    end
  end
end
