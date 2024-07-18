class AddRecommendedAtToCandidate < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      change_table :job_orders_candidates, bulk: true do |t|
        t.datetime :recommended_at
        t.datetime :status_updated_at
      end
    end
  end
end
