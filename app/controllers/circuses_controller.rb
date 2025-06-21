class CircusesController < ApplicationController
  layout "dashboard"
  before_action :authenticate_user!
  before_action :set_circus, only: %i[ show edit update destroy admin ]
  before_action :check_user_is_active_in_circus, only: [ :show, :admin ]

  def check_user_is_active_in_circus
    unless current_user.circus_users.find_by(circus_id: params[:id])&.active?
      redirect_to root_path, alert: "Debes aceptar la invitación antes de acceder al circo."
    end
  end

  # app/controllers/circuses_controller.rb
  def toggle_status
    @circus = Circus.find(params[:id])
    authorize! :update, @circus  # si usas Cancancan

    @circus.update(active: !@circus.active)

    flash[:notice] = t("circus.status.changed", default: "Estado del circo actualizado.")
    redirect_to admin_circus_path(@circus)
  end

  def index
    @owned_circuses = current_user.owned_circuses

    @associated_circuses = current_user
      .associated_circuses
      .joins(:circus_users)
      .where(circus_users: { user_id: current_user.id, active: true })
      .where.not(circus_users: { accepted_at: nil })
      .where.not(id: @owned_circuses.map(&:id))
      .distinct

    @circuses = @owned_circuses + @associated_circuses
  end

  def show
  end

  def accept_invitation
    @circus = Circus.find(params[:id])
    circus_user = CircusUser.find_by(user: current_user, circus: @circus)

    if circus_user.present? && circus_user.accepted_at.nil?
      circus_user.update!(accepted_at: Time.current)
      flash[:notice] = "Has aceptado la invitación al circo #{@circus.name}."
    else
      flash[:alert] = "No tienes una invitación pendiente para este circo."
    end

    redirect_to dashboard_index_path
  end

  def new
    @circus = current_user.circuses.build
  end

  def edit
  end

  def admin
    @circus = Circus.find(params[:id])
    session[:circus_id] = @circus.id
    authorize! :admin, @circus

    current_cu = current_user.circus_users.find_by(circus: @circus)

    filtered_users = if current_cu&.role == "owner"
      @circus.circus_users.includes(user: [ :user_profile, :invitations ])
    else
      @circus.circus_users.includes(user: [ :user_profile, :invitations ])
              .where(active: true)
              .where.not(accepted_at: nil)
    end

    owner = @circus.circus_users.find_by(role: "owner")
    @circus_users = [ owner ] + filtered_users.reject { |cu| cu.id == owner&.id }
  end

  def create
    @circus = Circus.new(circus_params)
    @circus.user = current_user
    respond_to do |format|
      if @circus.save
        CircusUser.create!(user: current_user, circus: @circus, role: "owner")

        format.html { redirect_to root_path, notice: "Circo creado con éxito." }
        format.json { render :show, status: :created, location: @circus }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @circus.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @circus.update(circus_params)
        format.html { redirect_to @circus, notice: "Circo actualizado con éxito." }
        format.json { render :show, status: :ok, location: @circus }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @circus.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @circus.destroy
    respond_to do |format|
      format.html { redirect_to circuses_path, notice: "Circo eliminado correctamente." }
      format.json { head :no_content }
    end
  end

  private

  def set_circus
    @circus = current_user.circuses.find(params[:id])
  end

  def circus_params
    params.require(:circus).permit(:name, :description, :country, :currency, :active, :logo)
  end
end
