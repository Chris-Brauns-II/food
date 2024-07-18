class AddEmployerReferencetoJob < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_reference :analytics_dim_jobs, :analytics_dim_employer, index: { algorithm: :concurrently }
  end
end
