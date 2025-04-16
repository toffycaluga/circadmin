class CustomDeviseMailer < Devise::Mailer
  helper :application # acceso a helpers como `url_helpers`
  include Devise::Controllers::UrlHelpers
  include Devise::Mailers::Helpers
  default template_path: "devise/mailer" # usa las vistas por defecto de Devise
  layout "mailer" # tu layout personalizado
end
