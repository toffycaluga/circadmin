# frozen_string_literal: true

# config/initializers/content_security_policy.rb
#
# IMPORTANTE:
# - Reinicia el servidor después de modificar este archivo.
# - Ajusta/borra dominios que no uses (hCaptcha, Google Fonts, etc.).
# - Mantén *.stripe.com porque Stripe usa subdominios/iframes internos.

Rails.application.config.content_security_policy do |policy|
  # Bloquea todo por defecto al mismo origen
  policy.default_src :self

  # Scripts: importmap/Stimulus (inline), ESM que usan eval internamente, Stripe, CDN(s)
  policy.script_src :self,
                    :unsafe_inline,
                    :unsafe_eval,
                    "https://js.stripe.com",
                    "https://m.stripe.network",
                    "https://*.stripe.com",
                    "https://cdn.jsdelivr.net",
                    "https://esm.sh"

  # Conexiones XHR/fetch/EventSource/WebSocket que pueden usar librerías/iframes
  policy.connect_src :self,
                     "https://api.stripe.com",
                     "https://js.stripe.com",
                     "https://m.stripe.network",
                     "https://*.stripe.com",
                     "https://cdn.jsdelivr.net",
                     "https://esm.sh"

  # Estilos: permite inline (Bootstrap, estilos embebidos) y tu(s) CDN(s)
  policy.style_src :self,
                   :unsafe_inline,
                   "https://cdn.jsdelivr.net",
                   # Quita si no usas Google Fonts (mantén si los cargas en tu CSS)
                   "https://fonts.googleapis.com"

  # Imágenes: data URIs, tu bucket S3 y assets que puedan provenir de iframes (Stripe)
  policy.img_src :self,
                 "data:",
                 "https://circadmin-assets-2025.s3.us-east-2.amazonaws.com",
                 "https://*.stripe.com"

  # Iframes embebidos (Stripe Elements/Checkout, hooks de Stripe, hCaptcha opcional)
  policy.frame_src :self,
                   "https://js.stripe.com",
                   "https://*.stripe.com",
                   "https://hooks.stripe.com",
                   "https://hcaptcha.com",
                   "https://*.hcaptcha.com"

  # Fuentes web (CDN, Google Fonts). Borra las que no uses.
  policy.font_src :self,
                  "https://cdn.jsdelivr.net",
                  "https://fonts.gstatic.com",
                  "data:"

  # Workers/Blobs (útil para ciertas librerías/Source Maps). Déjalo si no te molesta.
  policy.worker_src :self, "blob:"

  # Endurecimiento adicional recomendado
  policy.object_src :none
  policy.base_uri   :self
  policy.form_action :self
  # Si tu app se muestra embebida en otros sitios, ajusta esto. Por defecto solo tú.
  policy.frame_ancestors :self

  # Si usas manifest.json desde tu dominio:
  policy.manifest_src :self
end

# Si quieres nonces automáticos para inline <script> y <style> (útil con importmap):
# Nota: Solo habilítalo si ya agregas nonces en tus tags, o mantén :unsafe_inline arriba.
# Rails.application.config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
# Rails.application.config.content_security_policy_nonce_directives = %w(script-src style-src)

# Enforce (no solo reportar)
Rails.application.config.content_security_policy_report_only = false
