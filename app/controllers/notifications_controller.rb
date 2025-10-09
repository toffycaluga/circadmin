class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: [ :mark_as_read, :show ]
  layout "dashboard"

  # Muestra las notificaciones ordenadas
  def index
    @pagy, @notifications = pagy(current_user.notifications.order(created_at: :desc), items: 10)
  end

  # Marca una notificación como leída
  def mark_as_read
    if @notification.update(read: true)
      flash[:notice] = t("flash.notifications.mark_as_read.success")
    else
      flash[:alert]  = t("flash.notifications.mark_as_read.failure")
    end
    redirect_back fallback_location: notifications_path
  end

  # Marca todas las notificaciones como leídas
  def mark_all_as_read
    current_user.notifications.update_all(read: true)
    flash[:notice] = t("flash.notifications.all_marked_read.success")
    redirect_back fallback_location: notifications_path
  end

  # Muestra/abre una notificación y la marca como leída
  def show
    @notification.update(read: true) unless @notification.read?
    flash[:notice] = t("flash.notifications.show.opened")
    redirect_to notifications_path # o render :show si tienes vista
  end

  private

  def set_notification
    @notification = current_user.notifications.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = t("flash.notifications.not_found")
    redirect_back fallback_location: notifications_path
  end
end
