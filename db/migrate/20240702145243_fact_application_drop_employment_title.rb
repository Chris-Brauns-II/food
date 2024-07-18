class FactApplicationDropEmploymentTitle < ActiveRecord::Migration[7.1]
  def change
    safety_assured { remove_column :analytics_fact_applications, :employment_title, :string }
  end
end
