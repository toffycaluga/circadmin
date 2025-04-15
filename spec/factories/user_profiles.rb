FactoryBot.define do
  factory :user_profile do
    user { nil }
    nombre_completo { "MyString" }
    direccion { "MyString" }
    pais { "MyString" }
    tipo_moneda { "MyString" }
  end
end
