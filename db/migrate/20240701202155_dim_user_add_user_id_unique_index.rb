class DimUserAddUserIdUniqueIndex < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :analytics_dim_users, :user_id, unique: true, algorithm: :concurrently
  end
end
