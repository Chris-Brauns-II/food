class AddDimJobFkOnEmployerValidate < ActiveRecord::Migration[7.1]
  def change
    validate_foreign_key :analytics_dim_jobs, :analytics_dim_employers
  end
end
