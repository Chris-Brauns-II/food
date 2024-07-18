class DropProfileCertifications < ActiveRecord::Migration[7.1]
  def change
    drop_table :profile_certifications # rubocop:disable Rails/ReversibleMigration
  end
end
