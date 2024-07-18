class RemoveNullEmailConstraintOnPerson < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      change_column_null :people_search_people, :email, true
    end
  end
end
