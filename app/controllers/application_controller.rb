class ApplicationController < ActionController::Base
  # allow_browser versions: :modern, if: -> { Rails.env.production? }

  before_action :set_locale
  before_action :redirect_if_profile_incomplete, unless: :active_storage_request?
  before_action :ensure_circus_context!

  helper_method :current_circus

  def set_locale
    I18n.locale = session[:locale] ||
      extract_locale_from_accept_language_header ||
      I18n.default_locale
  end

  def current_circus
    @current_circus ||= begin
      circus = Circus.find_by(id: session[:circus_id])
      Rails.logger.info "🐞 current_circus desde sesión: #{session[:circus_id]} -> #{circus&.name}"
      circus
    end
  end

  def extract_locale_from_accept_language_header
    locale if %w[es en].include?(locale.to_s)
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

  def after_sign_up_path_for(resource)
    dashboard_index_path
  end

  def after_resetting_password_path_for(resource)
    dashboard_index_path
  end

  def render_not_found
    redirect_to "/404"
  end

  def accept_invitation
    @circus = Circus.find(params[:id])
    circus_user = CircusUser.find_by(user: current_user, circus: @circus)

    if circus_user.present? && circus_user.accepted_at.nil?
      circus_user.update!(accepted_at: Time.current)
      flash[:notice] = "¡Has aceptado ser parte de #{@circus.name}!"
    else
      flash[:alert] = "No tienes invitaciones pendientes para este circo."
    end

    redirect_to dashboard_index_path
  end

  private

  def ensure_circus_context!
    if controller_name == "custom_invitations" && session[:circus_id].blank?
      redirect_to dashboard_index_path, alert: "Debes seleccionar un circo antes de invitar."
    end
  end

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

  def active_storage_request?
    request.path.starts_with?("/rails/active_storage")
  end
end
