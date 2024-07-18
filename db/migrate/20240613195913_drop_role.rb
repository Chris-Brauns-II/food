class DropRole < ActiveRecord::Migration[7.1]
  def change
    drop_table :roles # rubocop:disable Rails/ReversibleMigration
  end
end
