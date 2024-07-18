class AddEmployerInformationToCandidate < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      change_table :analytics_fact_candidates, bulk: true do |t|
        t.string :employer_name
        t.string :employment_title
        t.string :first_name
        t.string :last_name
        t.string :email
      end
    end
  end
end
