class InvitationsController < ApplicationController
  before_action :set_invitation, only: %i[show edit update destroy accept reject]
  layout "dashboard"

  # GET /invitations
  def index
    @invitations = current_user.invitations.order(created_at: :desc)
  end

  # GET /invitations/1
  def show; end

  # GET /invitations/new
  def new
    @invitation = Invitation.new
  end

  # PATCH /invitations/:id/accept
  def accept
    @invitation.update!(status: Invitation::STATUSES["accepted"])

    Notification.create!(
      user: @invitation.sender,
      title: t("controllers.invitations.accept.title"),
      body:  t("controllers.invitations.accept.body",
               user_email: current_user.email,
               circus_name: @invitation.circus.name)
    )

    circus_user = CircusUser.find_by(user: @invitation.user, circus: @invitation.circus)
    circus_user.update!(active: true, accepted_at: Time.current) if circus_user

    redirect_to invitations_path, notice: t("controllers.invitations.accept.success")
  end

  # PATCH /invitations/:id/reject
  def reject
    @invitation.update!(status: Invitation::STATUSES["rejected"])

    Notification.create!(
      user: @invitation.sender,
      title: t("controllers.invitations.reject.title"),
      body:  t("controllers.invitations.reject.body",
               user_email: current_user.email,
               circus_name: @invitation.circus.name)
    )

    redirect_to invitations_path, alert: t("controllers.invitations.reject.success")
  end

  # GET /invitations/:id/edit
  def edit; end

  # POST /invitations
  def create
    @invitation = Invitation.new(invitation_params)

    respond_to do |format|
      if @invitation.save
        format.html { redirect_to @invitation, notice: t("controllers.invitations.create.success") }
        format.json { render :show, status: :created, location: @invitation }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /invitations/:id
  def update
    respond_to do |format|
      if @invitation.update(invitation_params)
        format.html { redirect_to @invitation, notice: t("controllers.invitations.update.success") }
        format.json { render :show, status: :ok, location: @invitation }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invitations/:id
  def destroy
    @invitation.destroy!

    respond_to do |format|
      format.html { redirect_to invitations_path, status: :see_other, notice: t("controllers.invitations.destroy.success") }
      format.json { head :no_content }
    end
  end

  private

  def set_invitation
    @invitation = Invitation.find(params[:id])
  end

  def invitation_params
    params.require(:invitation).permit(:user_id, :circus_id, :sender_id, :message, :status)
  end
end
