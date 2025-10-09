# app/controllers/circuses_controller.rb
class CircusesController < ApplicationController
  layout "dashboard"
  before_action :authenticate_user!

  include SubscriptionCheckable

  before_action :set_circus, only: %i[show edit update destroy admin toggle_status accept_invitation]
  before_action :check_user_is_active_in_circus, only: %i[show admin]
  # before_action :check_subscription, only: %i[admin]

  # GET /circuses
  def index
    @owned_circuses = current_user.owned_circuses
    @associated_circuses = current_user.associated_circuses
      .joins(:circus_users)
      .where(circus_users: { user_id: current_user.id, active: true })
      .where.not(circus_users: { accepted_at: nil })
      .where.not(id: @owned_circuses.map(&:id))
      .distinct

    @circuses = @owned_circuses + @associated_circuses
  end

  # GET /circuses/:id
  def show
  end

  # GET /circuses/new
  def new
    @circus = Circus.new(user: current_user)
  end

  # POST /circuses
  def create
    @circus = Circus.new(circus_params)
    @circus.user = current_user

    respond_to do |format|
      if @circus.save
        CircusUser.create!(user: current_user, circus: @circus, role: "owner")
        format.html { redirect_to root_path, notice: t("controllers.circuses.create.success") }
        format.json { render :show, status: :created, location: @circus }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @circus.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /circuses/:id/edit
  def edit
  end

  # PATCH/PUT /circuses/:id
  def update
    respond_to do |format|
      if @circus.update(circus_params)
        format.html { redirect_to @circus, notice: t("controllers.circuses.update.success") }
        format.json { render :show, status: :ok, location: @circus }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @circus.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /circuses/:id
  def destroy
    @circus.destroy
    respond_to do |format|
      format.html { redirect_to circuses_path, notice: t("controllers.circuses.destroy.success") }
      format.json { head :no_content }
    end
  end

  # GET /circuses/:id/admin
  def admin
    authorize! :admin, @circus
    session[:circus_id] = @circus.id

    @payrolls = @circus.payrolls
                       .includes(:payroll_transaction)
                       .order(date: :desc)

    current_cu = current_user.circus_users.find_by(circus: @circus)
    users_scope = @circus.circus_users.includes(user: %i[user_profile invitations])

    @circus_users = if current_cu&.role == "owner"
      users_scope
    else
      users_scope.where(active: true).where.not(accepted_at: nil)
    end

    owner = @circus.circus_users.find_by(role: "owner")
    @circus_users = [ owner ] + @circus_users.reject { |cu| cu.id == owner&.id }
  end

  # PUT /circuses/:id/accept_invitation
  def accept_invitation
    circus_user = CircusUser.find_by(user: current_user, circus: @circus)

    if circus_user && circus_user.accepted_at.nil?
      circus_user.update!(accepted_at: Time.current)
      flash[:notice] = t("controllers.circuses.accept_invitation.success", circus_name: @circus.name)
    else
      flash[:alert]  = t("controllers.circuses.accept_invitation.none_pending")
    end

    redirect_to dashboard_index_path
  end

  # PUT /circuses/:id/toggle_status
  def toggle_status
    authorize! :update, @circus
    @circus.update!(active: !@circus.active)
    flash[:notice] = t("circus.status.changed", default: "Estado del circo actualizado.")
    redirect_to admin_circus_path(@circus)
  end

  private

  # carga @circus desde los circos que le pertenecen o donde está invitado
  def set_circus
    @circus = current_user.circuses.find(params[:id])
  end

  # sólo propietarios o invitados activos pueden ver /admin
  def check_user_is_active_in_circus
    cu = current_user.circus_users.find_by(circus: @circus)
    unless cu&.active?
      redirect_to root_path, alert: t("controllers.circuses.access.must_accept")
    end
  end

  # parámetros permitidos para create/update
  def circus_params
    params.require(:circus)
          .permit(:name, :description, :country, :currency, :active, :logo)
  end
end
