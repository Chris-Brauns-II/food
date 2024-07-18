class JobOrdersAddScreenedCount < ActiveRecord::Migration[7.1]
  def change
    add_column :job_orders_job_orders, :screened_count, :integer
  end
end
