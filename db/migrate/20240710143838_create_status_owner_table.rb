class CreateStatusOwnerTable < ActiveRecord::Migration[7.1]
  def change
    create_table :job_orders_status_owners do |t|
      t.string :order_status, null: false, index: { unique: true }
      t.uuid :team_id, null: false
      t.timestamps
    end
  end
end
