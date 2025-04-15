class CreateUserProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :user_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :nombre_completo
      t.string :direccion
      t.string :pais
      t.string :tipo_moneda

      t.timestamps
    end
  end
end
