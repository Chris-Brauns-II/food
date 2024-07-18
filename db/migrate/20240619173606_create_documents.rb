class CreateDocuments < ActiveRecord::Migration[7.1]
  def change
    create_table :documents, id: :text do |t|
      t.string :file_name, null: false
      t.binary :file_data, null: false

      t.timestamps
    end
  end
end
