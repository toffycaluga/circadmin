class CircusUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_circus_user
  before_action :authorize_owner!

  # GET /circus_users/:id/edit
  def edit
  end

  # PATCH /circus_users/:id
  def update
    new_role = params[:circus_user][:role]

    if CircusUser::ROLES.include?(new_role)
      if @circus_user.update(role: new_role)
        redirect_to admin_circus_path(@circus_user.circus), notice: t("controllers.circus_users.update.success")
      else
        render :edit, status: :unprocessable_entity
      end
    else
      redirect_to edit_circus_user_path(@circus_user),
                  alert: t("controllers.circus_users.update.invalid_role")
    end
  end

  # DELETE /circus_users/:id
  def destroy
    @circus_user.update(active: false)
    redirect_to admin_circus_path(@circus_user.circus), notice: t("controllers.circus_users.destroy.success")
  end

  # PATCH /circus_users/:id/deactivate
  def deactivate
    @circus_user.update(active: false)
    redirect_to admin_circus_path(@circus_user.circus), notice: t("controllers.circus_users.deactivate.success")
  end

  private

  def set_circus_user
    @circus_user = CircusUser.find(params[:id])
  end

  def authorize_owner!
    unless current_user.owned_circuses.include?(@circus_user.circus)
      redirect_to root_path, alert: t("controllers.circus_users.unauthorized")
    end
  end
end
