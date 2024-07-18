class DimPeopleDropLeadCreatedAt < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :analytics_dim_people, :lead_created_at, :datetime }
  end
end
