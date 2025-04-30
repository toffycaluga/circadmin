class CircusUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_circus_user
  before_action :authorize_owner!

  def edit
  end

  def update
    if @circus_user.update(circus_user_params)
      redirect_to admin_circus_path(@circus_user.circus), notice: t("cu_notice.update")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # Cambiado por desactivación en lugar de eliminación real
    @circus_user.update(active: false)
    redirect_to admin_circus_path(@circus_user.circus), notice: t("cu_notice.destroy")
  end

  def deactivate
    @circus_user.update(active: false)
    redirect_to admin_circus_path(@circus_user.circus), notice: t("cu_notice.deactivate")
  end

  private

  def set_circus_user
    @circus_user = CircusUser.find(params[:id])
  end

  def authorize_owner!
    unless current_user.owned_circuses.include?(@circus_user.circus)
      redirect_to root_path, alert: "No tienes permiso para realizar esta acción."
    end
  end

  def circus_user_params
    params.require(:circus_user).permit(:role)
  end
end
