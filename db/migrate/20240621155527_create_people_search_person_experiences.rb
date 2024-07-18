class CreatePeopleSearchPersonExperiences < ActiveRecord::Migration[7.1]
  def change
    create_table :people_search_person_experiences, id: :uuid do |t|
      t.references :person, null: false, foreign_key: { to_table: :people_search_people, on_delete: :cascade }, type: :uuid

      t.string :organization_name, null: false
      t.string :position, null: false
      t.text :description, null: false

      t.timestamps
    end
  end
end
