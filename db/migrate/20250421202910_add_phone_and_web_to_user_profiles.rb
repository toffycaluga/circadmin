class AddPhoneAndWebToUserProfiles < ActiveRecord::Migration[8.0]
  def change
    add_column :user_profiles, :phone, :string
    add_column :user_profiles, :web, :string
  end
end
