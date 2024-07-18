class CreateAnalyticsDimEmployer < ActiveRecord::Migration[7.1]
  def change
    create_table :analytics_dim_employers do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.string :name, null: false
      t.uuid :employer_id, null: false, index: { unique: true }
    end
  end
end
