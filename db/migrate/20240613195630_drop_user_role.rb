class DropUserRole < ActiveRecord::Migration[7.1]
  def change
    drop_table :user_roles # rubocop:disable Rails/ReversibleMigration
  end
end
