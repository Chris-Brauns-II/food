class DimJobAddUniqueJobIdIndex < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :analytics_dim_jobs, :job_id, unique: true, algorithm: :concurrently
  end
end
