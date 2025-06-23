require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Los ajustes especificados aquí tendrán prioridad sobre los de config/application.rb.

  # El código no se recarga entre peticiones.
  config.enable_reloading = false

  # Carga el código en arranque para mejorar rendimiento y ahorro de memoria (ignorado por tareas Rake).
  config.eager_load = true

  # Los informes de errores detallados están desactivados.
  config.consider_all_requests_local = false

  # Activa el almacenamiento en caché de fragmentos en las vistas.
  config.action_controller.perform_caching = true

  # Caché para assets con expiración a largo plazo, ya que usan digest.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Determina tu dominio (usado en URLs de controllers y mailers).
  host = ENV.fetch("APP_HOST", "circadmin.cirxoft.com")
  config.action_controller.default_url_options = { host: host, protocol: "https" }
  config.action_mailer   .default_url_options = { host: host, protocol: "https" }

  # Habilita servir imágenes, estilos y JavaScripts desde un servidor de assets.
  # config.asset_host = "http://assets.example.com"

  # Almacena archivos subidos en el sistema de archivos local (ver config/storage.yml).
  config.active_storage.service = :amazon

  # Asume que todo el acceso a la app llega a través de un proxy inverso que termina SSL.
  config.assume_ssl = true

  # Fuerza todo el tráfico sobre SSL, establece Strict-Transport-Security y cookies seguras.
  config.force_ssl = true

  # Excluir la redirección http→https para el endpoint de verificación de salud.
  # config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Registrar en STDOUT con el ID de la petición como etiqueta.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Cambia a "debug" para registrar todo (¡incluyendo datos sensibles!).
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Evitar que las comprobaciones de salud saturen los logs.
  config.silence_healthcheck_path = "/up"

  # No registrar deprecaciones.
  config.active_support.report_deprecations = false

  # Reemplaza el cache en memoria por una alternativa duradera.
  config.cache_store = :solid_cache_store

  # Reemplaza el backend de colas de Active Job por uno duradero.
  config.active_job.queue_adapter = :inline
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Ignorar direcciones de correo inválidas y no generar errores de entrega.
  config.action_mailer.perform_deliveries    = true
  config.action_mailer.raise_delivery_errors = true

  # Método de envío SMTP
  config.action_mailer.delivery_method = :smtp

  # Configuración SMTP / Mailgun
  config.action_mailer.smtp_settings = {
    address:              ENV["MAILGUN_SMTP_SERVER"],
    port:                 ENV["MAILGUN_SMTP_PORT"],
    domain:               ENV["MAILGUN_DOMAIN"],
    user_name:            ENV["MAILGUN_SMTP_LOGIN"],
    password:             ENV["MAILGUN_SMTP_PASSWORD"],
    authentication:       :plain,
    enable_starttls_auto: true
  }

  # Habilitar fallback de locale en I18n.
  config.i18n.fallbacks = true

  # No volcar el esquema tras migraciones.
  config.active_record.dump_schema_after_migration = false

  # Usar solo :id en inspecciones en producción.
  config.active_record.attributes_for_inspect = [ :id ]

  # Habilitar protección contra DNS rebinding y otros ataques de header Host.
  config.hosts = [ host ]
  # Excluir protección de DNS rebinding para el endpoint de salud por defecto.
  # config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end
