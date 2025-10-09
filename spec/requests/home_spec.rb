# spec/requests/errors_spec.rb
require "rails_helper"

RSpec.describe "Errores", type: :request do
  it "GET /404 retorna 404" do
    get "/404"
    expect(response).to have_http_status(:not_found)
  end

  it "rutas desconocidas caen en not_found" do
    get "/ruta/que/no/existe"
    expect(response).to have_http_status(:not_found)
  end
end
