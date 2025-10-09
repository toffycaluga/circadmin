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
    @user_profile = UserProfile.new
  end

  def edit; end

  def create
    @user_profile = current_user.build_user_profile(user_profile_params)

    if @user_profile.save
      redirect_to profile_path, notice: t("flash.user_profiles.create.success")
    else
      flash.now[:alert] = t("flash.user_profiles.create.failure")
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user_profile.update(user_profile_params)
      redirect_to profile_path, notice: t("flash.user_profiles.update.success")
    else
      flash.now[:alert] = t("flash.user_profiles.update.failure")
      render :edit, status: :unprocessable_entity
    end
  end

  def update_profile_picture
    if @user_profile.update(profile_picture_params)
      flash[:notice] = t("flash.user_profiles.picture.update.success")
    else
      flash[:alert]  = t("flash.user_profiles.picture.update.failure")
    end
    redirect_to profile_path
  end

  def destroy
    @user_profile.destroy!
    redirect_to user_profiles_path, status: :see_other,
                notice: t("flash.user_profiles.destroy.success")
  end

  private

  def set_user_profile
    @user_profile = UserProfile.find(params[:id])
    unless @user_profile.user_id == current_user.id
      redirect_to root_path, alert: t("flash.user_profiles.unauthorized")
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: t("flash.user_profiles.not_found")
  end

  def user_profile_params
    params.require(:user_profile).permit(:full_name, :address, :country, :phone, :web)
  end

  def profile_picture_params
    params.require(:user_profile).permit(:profile_picture)
  end
end
