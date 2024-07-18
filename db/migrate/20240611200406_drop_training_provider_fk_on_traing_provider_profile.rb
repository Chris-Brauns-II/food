class DropTrainingProviderFkOnTraingProviderProfile < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :training_provider_profiles, :training_providers
  end
end
