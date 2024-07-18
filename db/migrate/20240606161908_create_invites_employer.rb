class CreateInvitesEmployer < ActiveRecord::Migration[7.1]
  def change
    create_table :invites_employer_invites, id: :uuid do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.string :email, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.datetime :used_at
      t.uuid :employer_id, null: false
      t.string :employer_name, null: false
    end
  end
end
