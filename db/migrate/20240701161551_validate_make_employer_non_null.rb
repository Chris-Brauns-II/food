class ValidateMakeEmployerNonNull < ActiveRecord::Migration[7.1]
  def change
    validate_check_constraint :analytics_dim_jobs, name: "analytics_dim_employer_id_column_null"
    change_column_null :analytics_dim_jobs, :analytics_dim_employer_id, false
    remove_check_constraint :analytics_dim_jobs, name: "analytics_dim_employer_id_column_null"
  end
end
