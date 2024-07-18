class DropTrainingProviderInvite < ActiveRecord::Migration[7.1]
  def change
    drop_table :training_provider_invites # rubocop:disable Rails/ReversibleMigration
  end
end
