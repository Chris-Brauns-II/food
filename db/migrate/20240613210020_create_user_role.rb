class CreateUserRole < ActiveRecord::Migration[7.1]
  def change
    create_table :user_roles do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.references :user, foreign_key: true, type: :text, null: false
      t.string :role, null: false
    end
  end
end
