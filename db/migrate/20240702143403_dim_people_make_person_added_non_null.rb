class DimPeopleMakePersonAddedNonNull < ActiveRecord::Migration[7.1]
  def change
    add_check_constraint :analytics_dim_people, "person_added_at IS NOT NULL", name: "person_added_at_column_null", validate: false
  end
end
