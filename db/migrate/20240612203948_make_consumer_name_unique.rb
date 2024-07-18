class MakeConsumerNameUnique < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :listener_bookmarks, :consumer_name, unique: true, algorithm: :concurrently
  end
end
