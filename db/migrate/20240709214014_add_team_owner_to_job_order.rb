class AddTeamOwnerToJobOrder < ActiveRecord::Migration[7.1]
  def change
    add_column :job_orders_job_orders, :team_id, :uuid
  end
end
