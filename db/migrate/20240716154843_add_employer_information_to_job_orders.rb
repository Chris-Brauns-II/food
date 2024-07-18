class AddEmployerInformationToJobOrders < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      change_table :analytics_dim_job_orders, bulk: true do |t|
        t.string :employer_name
        t.string :employment_title
      end
    end
  end
end
