class AddLastActiveToPeopleSearch < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      change_table :people_search_people do |t| # rubocop:disable Rails/BulkChangeTable
        t.datetime :last_active_at
        t.datetime :last_contacted_at
        t.string :user_id
      end
    end
  end
end
