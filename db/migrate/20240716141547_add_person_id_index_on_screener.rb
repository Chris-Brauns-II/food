class AddPersonIdIndexOnScreener < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :documents_screeners, :person_id, algorithm: :concurrently
  end
end
