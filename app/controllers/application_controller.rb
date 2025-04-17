class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_locale
  before_action :redirect_if_profile_incomplete

  def set_locale
    I18n.locale = session[:locale]||
    extract_locale_from_accept_language_header ||
    I18n.default_locale
  end
  

  
  def extract_locale_from_accept_language_header
    # request.env["HTTP_ACCEPT_LANGUAGE"].scan(/^[a-z]{2}/).first
    locale if [ "es", "en" ].include? locale.to_s
  end
  def set_language
    session[:locale] = params[:locale]
    redirect_back(fallback_location: root_path)
  end
  def after_sign_in_path_for(resource)
    dashboard_index_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
  def render_not_found
    redirect_to "/404"
  end
  
  private
  # middleware para asegurar que completen todos los datos 
  def redirect_if_profile_incomplete
    return unless user_signed_in?
  
    allowed_paths = [
      "/user_profiles",
      "/users/sign_out",
      "/users/password",
      "/set_language"
    ]
  
    return if allowed_paths.any? { |path| request.path.starts_with?(path) }
    return if request.xhr?
  
    if current_user.user_profile.nil?
      redirect_to new_user_profile_path, alert: t("alerts.complete_profile")
    end
  end
  
end
