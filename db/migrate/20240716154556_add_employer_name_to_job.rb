class AddEmployerNameToJob < ActiveRecord::Migration[7.1]
  def change
    add_column :analytics_dim_jobs, :employer_name, :string
  end
end
