class DropNullConstraints < ActiveRecord::Migration[7.1]
  def change
    change_column_null :people_search_person_education_experiences, :organization_name, true
    change_column_null :people_search_person_education_experiences, :title, true
    change_column_null :people_search_person_education_experiences, :activities, true

    change_column_null :people_search_person_experiences, :description, true
    change_column_null :people_search_person_experiences, :organization_name, true
    change_column_null :people_search_person_experiences, :position, true
  end
end
