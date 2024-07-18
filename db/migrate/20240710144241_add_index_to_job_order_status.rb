class AddIndexToJobOrderStatus < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :job_orders_job_orders, :status, algorithm: :concurrently
  end
end
