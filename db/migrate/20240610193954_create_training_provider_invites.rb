class CreateTrainingProviderInvites < ActiveRecord::Migration[7.1]
  def change
    create_table :invites_training_provider_invites, id: :uuid do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.string :email, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.datetime :used_at
      t.uuid :training_provider_id, null: false
      t.string :training_provider_name, null: false
      t.string :role_description, null: false
    end
  end
end
