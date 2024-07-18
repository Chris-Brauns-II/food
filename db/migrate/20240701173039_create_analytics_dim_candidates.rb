class CreateAnalyticsDimCandidates < ActiveRecord::Migration[7.1]
  def change
    create_table :analytics_fact_candidates do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.references :analytics_dim_people, foreign_key: true, null: false
      t.references :analytics_dim_job_orders, foreign_key: true, null: false
      t.integer :order_candidate_number, null: false
      t.datetime :added_at, null: false
      t.datetime :terminal_status_at
      t.string :status, null: false
    end
  end
end
