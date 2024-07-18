class MakeListenerBookmarkEventIdNullValidate < ActiveRecord::Migration[7.1]
  def change
    validate_check_constraint :listener_bookmarks, name: "listener_bookmark_event_id_null"
    change_column_null :listener_bookmarks, :event_id, false
    remove_check_constraint :listener_bookmarks, name: "listener_bookmark_event_id_null"
  end
end
