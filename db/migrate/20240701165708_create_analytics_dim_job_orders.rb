class CreateAnalyticsDimJobOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :analytics_dim_job_orders do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.references :analytics_dim_jobs, foreign_key: true, null: false
      t.uuid :job_order_id, null: false, index: { unique: true }
      t.integer :order_count
      t.datetime :order_opened_at, null: false
      t.datetime :closed_at
      t.string :closed_status
    end
  end
end
