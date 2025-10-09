# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'devise'
require 'rspec/rails'
require 'capybara/rails'

# Si usas Shoulda Matchers (opcional, pero útil para modelos/validations):
begin
  require 'shoulda/matchers'
  Shoulda::Matchers.configure do |config|
    config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end
rescue LoadError
  # ignora si no lo tienes en el Gemfile
end

# Mantener esquema al día
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # === NUEVO: calidad de vida ===
  config.example_status_persistence_file_path = "spec/examples.txt"  # rspec --only-failures
  config.filter_run_when_matching :focus

  # Para que RSpec marque automáticamente un spec como :request, :system, etc. según la carpeta
  config.infer_spec_type_from_file_location!

  # Devise helpers para request specs (sign_in / sign_out)
  config.include Devise::Test::IntegrationHelpers, type: :request

  # (Opcional pero útil) Warden helpers si los necesitas
  config.include Warden::Test::Helpers
  config.before(:suite) { Warden.test_mode! }
  config.after(:each)   { Warden.test_reset! }

  # Calidad de vida (solo si aún no lo tenías)
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.filter_run_when_matching :focus

  # Fixtures
  config.fixture_paths = [ Rails.root.join('spec/fixtures') ]

  # DB en transacción (está bien para la mayoría de casos con rack_test)
  config.use_transactional_fixtures = true

  # === Autenticación Devise en request specs (YA LO TENÍAS) ===
  config.include Devise::Test::IntegrationHelpers, type: :request

  # === NUEVO: Autenticación en system specs (Capybara) ===
  # Para system/feature specs usar Warden helpers: login_as(user, scope: :user)
  config.include Warden::Test::Helpers, type: :system
  config.after(type: :system) { Warden.test_reset! }

  # === NUEVO: Driver por defecto para system specs ===
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  # Filtrar backtraces de Rails/gems
  config.filter_rails_from_backtrace!

  config.include Warden::Test::Helpers, type: :request
  config.after(type: :request) { Warden.test_reset! }
end

# Auto-require support/ (si lo usas)
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
