class UserProfilesController < ApplicationController
  layout "dashboard"
  before_action :authenticate_user!
  before_action :set_user_profile, only: [ :edit, :update, :update_profile_picture, :destroy ]

  # Vista personalizada del perfil actual (dashboard -> "Perfil")
  def profile
    @user_profile = current_user.user_profile
  end

  # Solo si se necesita listado administrativo de perfiles
  def index
    # ⚠️ Idealmente protegido por un rol admin
    @user_profiles = UserProfile.all
  end

  def new
    # Normalmente innecesario, ya que el perfil se crea con el user
    @user_profile = UserProfile.new
  end

  def edit
    # @user_profile ya está seteado
  end

  def create
    @user_profile = current_user.build_user_profile(user_profile_params)

    if @user_profile.save
      redirect_to profile_path, notice: t("user_profiles.notices.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user_profile.update(user_profile_params)
      redirect_to profile_path, notice: t("user_profiles.notices.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def update_profile_picture
    if @user_profile.update(profile_picture_params)
      flash[:notice] = t("user_profiles.notices.picture_updated")
    else
      flash[:alert] = t("user_profiles.alerts.picture_failed")
    end
    redirect_to profile_path # ❗ corrección: era profile_user_profiles_path (no existe)
  end

  def destroy
    @user_profile.destroy!
    redirect_to user_profiles_path, status: :see_other, notice: t("user_profiles.notices.destroyed")
  end

  private

  def set_user_profile
    # Si viene por URL (edit, update, etc.) verificamos que sea el del current_user
    @user_profile = UserProfile.find(params[:id])
    unless @user_profile.user_id == current_user.id
      redirect_to root_path, alert: t("user_profiles.alerts.unauthorized")
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: t("user_profiles.alerts.not_found")
  end

  def user_profile_params
    params.require(:user_profile).permit(:full_name, :address, :country, :phone, :web)
  end

  def profile_picture_params
    params.require(:user_profile).permit(:profile_picture)
  end
end
