class MakeListenerBookmarkCurrentTimestampNullValidate < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      validate_check_constraint :listener_bookmarks, name: "listener_bookmark_event_id_null"
      change_column_null :listener_bookmarks, :current_timestamp, false
      remove_check_constraint :listener_bookmarks, name: "listener_bookmark_event_id_null"
    end
  end
end
