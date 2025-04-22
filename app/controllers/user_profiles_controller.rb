class UserProfilesController < ApplicationController
  layout "dashboard"
  before_action :set_user_profile, only: %i[show edit update destroy update_picture]

  # GET /user_profiles
  def index
    @user_profiles = UserProfile.all
  end

  # GET /user_profiles/1
  def show
  end

  # GET /user_profiles/new
  def new
    @user_profile = UserProfile.new
  end

  # GET /user_profiles/1/edit
  def edit
  end
  def profile
    @user_profile = current_user.user_profile
  end

  # POST /user_profiles
  def create
    @user_profile = current_user.build_user_profile(user_profile_params)

    if @user_profile.save
      redirect_to dashboard_index_path, notice: t("user_profiles.notices.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /user_profiles/1
  def update
    if @user_profile.update(user_profile_params)
      redirect_to dashboard_index_path, notice: t("user_profiles.notices.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # PATCH /user_profiles/1/profile_picture
  def update_picture
    if @user_profile.update(profile_picture_params)
      redirect_to edit_user_profile_path(@user_profile), notice: t("user_profiles.edit.picture_updated")
    else
      redirect_to edit_user_profile_path(@user_profile), alert: t("user_profiles.edit.picture_failed")
    end
  end

  # DELETE /user_profiles/1
  def destroy
    @user_profile.destroy!
    redirect_to user_profiles_path, status: :see_other, notice: t("user_profiles.notices.destroyed")
  end

  private

  def set_user_profile
    @user_profile = UserProfile.find(params.require(:id))
  end

  def user_profile_params
    params.require(:user_profile).permit(:full_name, :address, :country)
  end

  def profile_picture_params
    params.require(:user_profile).permit(:profile_picture)
  end
end
