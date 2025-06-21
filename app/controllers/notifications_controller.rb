class NotificationsController < ApplicationController
  before_action :authenticate_user!
  layout "dashboard"

  # Muestra las notificaciones ordenadas
  def index
    @pagy, @notifications = pagy(current_user.notifications.order(created_at: :desc), items: 10)
  end


  # Marca una notificación como leída
  def mark_as_read
    notification = current_user.notifications.find_by(id: params[:id])

    if notification
      notification.update(read: true)
      flash[:notice] = t("notifications.marked_read", default: "Notificación marcada como leída.")
    else
      flash[:alert] = t("notifications.not_found", default: "Notificación no encontrada.")
    end

    redirect_back fallback_location: notifications_path
  end

  # Marca todas las notificaciones como leídas
  def mark_all_as_read
    current_user.notifications.update_all(read: true)
    flash[:notice] = t("notifications.all_marked_read", default: "Todas las notificaciones fueron marcadas como leídas.")
    redirect_back fallback_location: notifications_path
  end
  # app/controllers/notifications_controller.rb
  def show
    @notification = current_user.notifications.find(params[:id])

    unless @notification.read?
      @notification.update(read: true)
    end

    # Redirige al recurso relacionado si lo hay, o muestra el detalle
    # Ejemplo simple:
    flash[:notice] = t("notifications.opened", default: "Has abierto una notificación.")
    redirect_to notifications_path # o muestra una vista detallada si tienes
  end
end
