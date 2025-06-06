# app/controllers/notifications_controller.rb
class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.order(created_at: :desc)
  end

  def mark_as_read
    notification = current_user.notifications.find(params[:id])
    notification.update(read: true)
    redirect_back fallback_location: notifications_path
  end

  def mark_all_as_read
    current_user.notifications.update_all(read: true)
    redirect_back fallback_location: notifications_path
  end
end
