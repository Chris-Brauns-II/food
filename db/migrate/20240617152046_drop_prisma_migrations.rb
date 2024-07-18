class DropPrismaMigrations < ActiveRecord::Migration[7.1]
  def change
    drop_table :_prisma_migrations # rubocop:disable Rails/ReversibleMigration
  end
end
