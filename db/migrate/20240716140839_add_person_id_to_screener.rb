class AddPersonIdToScreener < ActiveRecord::Migration[7.1]
  def change
    add_column :documents_screeners, :person_id, :uuid
  end
end
