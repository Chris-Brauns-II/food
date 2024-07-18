class DropDimJobJobIdIndex < ActiveRecord::Migration[7.1]
  def change
    remove_index :analytics_dim_jobs, :job_id
  end
end
