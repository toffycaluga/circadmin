# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

# Rails.application.configure do
#   config.content_security_policy do |policy|
#     policy.default_src :self, :https
#     policy.font_src    :self, :https, :data
#     policy.img_src     :self, :https, :data
#     policy.object_src  :none
#     policy.script_src  :self, :https
#     policy.style_src   :self, :https
#     # Specify URI for violation reports
#     # policy.report_uri "/csp-violation-report-endpoint"
#   end
#
#   # Generate session nonces for permitted importmap, inline scripts, and inline styles.
#   config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
#   config.content_security_policy_nonce_directives = %w(script-src style-src)
#
#   # Report violations without enforcing the policy.
#   # config.content_security_policy_report_only = true
# end

# Be sure to restart your server when you modify this file.

# frozen_string_literal: true

# config/initializers/content_security_policy.rb
# config/initializers/content_security_policy.rb
# config/initializers/content_security_policy.rb

Rails.application.config.content_security_policy do |policy|
  # Por defecto sólo nosotros
  policy.default_src :self

  # Scripts: inline (importmap/Stimulus), eval (módulos ESM que usan eval internamente),
  # Stripe, jsDelivr, Bootstrap CDN y cualquier otro CDN que uses.
  policy.script_src  :self,
                     :unsafe_inline,
                     :unsafe_eval,
                     "https://js.stripe.com",
                     "https://m.stripe.network",
                     "https://*.stripe.com",
                     "https://cdn.jsdelivr.net"

  # Fetch/XHR
  policy.connect_src :self,
                     "https://api.stripe.com",
                     "https://js.stripe.com",
                     "https://m.stripe.network"

  # Styles: inline (Bootstrap incluye algunas reglas inline), tu dominio y CDN de CSS
  policy.style_src   :self,
                     :unsafe_inline,
                     "https://cdn.jsdelivr.net"

  # Imágenes: tu bucket S3, data URIs
  policy.img_src     :self,
                     "data:",
                     "https://circadmin-assets-2025.s3.us-east-2.amazonaws.com"

  # Iframes (Stripe Elements, hCaptcha, etc.)
  policy.frame_src   :self,
                     "https://js.stripe.com",
                     "https://hooks.stripe.com",
                     "https://hcaptcha.com",
                     "https://*.hcaptcha.com"

  # Fuentes web (Google Fonts, jsDelivr)
  policy.font_src    :self,
                     "https://cdn.jsdelivr.net",
                     "https://fonts.gstatic.com"
end

# Que bloquee en lugar de solo reportar
Rails.application.config.content_security_policy_report_only = false
