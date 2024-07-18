class MakeEmployerNonNull < ActiveRecord::Migration[7.1]
  def change
    add_check_constraint :analytics_dim_jobs, "analytics_dim_employer_id IS NOT NULL", name: "analytics_dim_employer_id_column_null", validate: false
  end
end
