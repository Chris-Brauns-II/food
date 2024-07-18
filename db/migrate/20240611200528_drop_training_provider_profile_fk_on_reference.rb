class DropTrainingProviderProfileFkOnReference < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :seeker_references, :training_provider_profiles
  end
end
