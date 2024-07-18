class FactApplicationDropEmployerName < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :analytics_fact_applications, :employer_name, :string }
  end
end
