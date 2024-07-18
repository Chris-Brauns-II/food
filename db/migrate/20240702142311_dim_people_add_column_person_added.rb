class DimPeopleAddColumnPersonAdded < ActiveRecord::Migration[7.1]
  def change
    add_column :analytics_dim_people, :person_added_at, :datetime
  end
end
