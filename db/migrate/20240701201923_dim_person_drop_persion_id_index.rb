class DimPersonDropPersionIdIndex < ActiveRecord::Migration[7.1]
  def change
    remove_index :analytics_dim_people, :person_id
  end
end
