class RemoveTipoMonedaFromUserProfiles < ActiveRecord::Migration[8.0]
  def change
    remove_column :user_profiles, :tipo_moneda, :string
  end
end
