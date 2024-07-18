class DropMasterCertificationFkOnDesiredCertifications < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :desired_certifications, :master_certifications
  end
end
