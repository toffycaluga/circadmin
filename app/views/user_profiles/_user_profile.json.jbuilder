json.extract! user_profile, :id, :user_id, :nombre_completo, :direccion, :pais, :tipo_moneda, :created_at, :updated_at
json.url user_profile_url(user_profile, format: :json)
