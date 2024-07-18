class DimPeopleDropLeadIdColumn < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :analytics_dim_people, :lead_id, :uuid }
  end
end
