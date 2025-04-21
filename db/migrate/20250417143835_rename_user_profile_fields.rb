class RenameUserProfileFields < ActiveRecord::Migration[8.0]
  def change
    rename_column :user_profiles, :nombre_completo, :full_name
    rename_column :user_profiles, :direccion, :address
    rename_column :user_profiles, :pais, :country
  end
end
