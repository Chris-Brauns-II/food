class DimPeopleValidateMakePersonAddedNonNull < ActiveRecord::Migration[7.1]
  def change
    validate_check_constraint :analytics_dim_people, name: "person_added_at_column_null"
    change_column_null :analytics_dim_people, :person_added_at, false
    remove_check_constraint :analytics_dim_people, name: "person_added_at_column_null"
  end
end
