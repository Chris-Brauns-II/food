class DropEmployerInviteFk < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :employer_invites, :employers
  end
end
