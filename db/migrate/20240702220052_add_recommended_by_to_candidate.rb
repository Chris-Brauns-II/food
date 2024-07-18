class AddRecommendedByToCandidate < ActiveRecord::Migration[7.1]
  def change
    add_column :job_orders_candidates, :recommended_by, :string
  end
end
