class MakeListenerBookmarkCurrentTimestampNullConstraint < ActiveRecord::Migration[7.1]
  def change
    add_check_constraint :listener_bookmarks, "current_timestamp IS NOT NULL", name: "listener_bookmark_event_id_null", validate: false
  end
end
