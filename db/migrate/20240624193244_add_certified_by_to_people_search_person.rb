class AddCertifiedByToPeopleSearchPerson < ActiveRecord::Migration[7.1]
  def change
    add_column :people_search_people, :certified_by, :string
  end
end
