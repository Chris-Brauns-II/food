class AddDimJobFkOnEmployerConstraint < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :analytics_dim_jobs, :analytics_dim_employers, validate: false
  end
end
