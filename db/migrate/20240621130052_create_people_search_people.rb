class CreatePeopleSearchPeople < ActiveRecord::Migration[7.1]
  def change
    create_table :people_search_people, id: :uuid do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.string :email, null: false
      t.string :assigned_coach
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.date :date_of_birth

      t.text :search_vector, null: false
    end
  end
end
