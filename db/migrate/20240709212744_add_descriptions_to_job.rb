class AddDescriptionsToJob < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      change_table :job_orders_jobs do |t| # rubocop:disable Rails/BulkChangeTable
        t.text :benefits_description
        t.text :requirements_description
        t.text :responsibilities_description
      end
    end
  end
end
