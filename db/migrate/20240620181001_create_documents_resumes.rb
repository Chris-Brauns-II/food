class CreateDocumentsResumes < ActiveRecord::Migration[7.1]
  def change
    create_table :documents_resumes, id: :uuid do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.string :document_kind, null: false

      t.string :requestor_type, null: false
      t.string :requestor_id, null: false, index: true

      t.uuid :person_id, null: false, index: true
      t.boolean :anonymized, null: false # rubocop:disable Rails/ThreeStateBooleanColumn
      t.string :status, null: false
      t.string :storage_kind
      t.string :storage_identifier
      t.datetime :document_generated_at
    end
  end
end
