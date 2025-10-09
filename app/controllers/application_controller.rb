# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Pagy::Backend

  # allow_browser versions: :modern, if: -> { Rails.env.production? }

  before_action :set_locale
  before_action :redirect_if_profile_incomplete, unless: :active_storage_request?
  before_action :ensure_circus_context!
  before_action :track_history

  helper_method :current_circus

  # === Rescates de errores de autorización / carga ===
  rescue_from CanCan::AccessDenied do |_e|
    respond_to do |format|
      format.html do
        redirect_to main_app.root_path,
                    alert: t("errors.unauthorized", default: "No estás autorizado para realizar esta acción.")
      end
      format.json do
        render json: { error: t("errors.unauthorized_short", default: "No estás autorizado.") }, status: :forbidden
      end
    end
  end

  # Evita 404 en flujos de invitado sin relación: redirige igual que AccessDenied (→ 302)
  rescue_from ActiveRecord::RecordNotFound do
    redirect_to main_app.root_path,
                alert: t("errors.unauthorized", default: "No estás autorizado para realizar esta acción.")
  end

  # === Navegación / tracking sencillo de historial ===
  def track_history
    return unless request.get? && !request.xhr?

    session[:history] ||= []
    session[:history].unshift(request.fullpath)
    session[:history] = session[:history].uniq.take(10)
  end

  # === Localización ===
  def set_locale
    I18n.locale = session[:locale] ||
                  extract_locale_from_accept_language_header ||
                  I18n.default_locale
  end

  def extract_locale_from_accept_language_header
    header = request.env["HTTP_ACCEPT_LANGUAGE"]
    return nil unless header

    # Toma el primer código de 2 letras válido (ej. "es", "en")
    preferred = header.scan(/[a-z]{2}/).first
    %w[es en].include?(preferred) ? preferred : nil
  end

  def set_language
    session[:locale] = params[:locale]
    redirect_back(fallback_location: root_path)
  end

  # === Sesión / contexto de circo ===
  def current_circus
    @current_circus ||= begin
      circus = Circus.find_by(id: session[:circus_id])
      Rails.logger.info "🐞 current_circus desde sesión: #{session[:circus_id]} -> #{circus&.name}"
      circus
    end
  end

  # Exige un circo seleccionado para rutas de admin y para invitations personalizadas
  def ensure_circus_context!
    # Para controladores bajo Admin::..., controller_path es "admin/xxx"
    if controller_path.start_with?("admin/") && session[:circus_id].blank?
      redirect_to dashboard_index_path, alert: t("controllers.application.ensure_circus_context.select_before_continue") and return
    end

    if controller_name == "custom_invitations" && session[:circus_id].blank?
      redirect_to dashboard_index_path, alert: t("controllers.application.ensure_circus_context.select_before_invite") and return
    end
  end

  # === Devise redirecciones ===
  def after_sign_in_path_for(_resource)
    dashboard_index_path
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  def after_sign_up_path_for(_resource)
    dashboard_index_path
  end

  def after_resetting_password_path_for(_resource)
    dashboard_index_path
  end

  # === Utilidades varias ===
  def render_not_found
    redirect_to "/404"
  end

  def accept_invitation
    @circus = Circus.find(params[:id])
    circus_user = CircusUser.find_by(user: current_user, circus: @circus)

    if circus_user.present? && circus_user.accepted_at.nil?
      circus_user.update!(accepted_at: Time.current)
      flash[:notice] = t("controllers.application.accept_invitation.success", circus_name: @circus.name)
    else
      flash[:alert] = t("controllers.application.accept_invitation.none_pending")
    end

    redirect_to dashboard_index_path
  end

  private

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
