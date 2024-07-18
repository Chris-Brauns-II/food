class DropSeekerInvite < ActiveRecord::Migration[7.1]
  def change
    drop_table :seeker_invites # rubocop:disable Rails/ReversibleMigration
  end
end
