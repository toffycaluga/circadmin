class InvitationsController < ApplicationController
  before_action :set_invitation, only: %i[ show edit update destroy accept reject ]

  layout "dashboard"
  # GET /invitations or /invitations.json
  def index
    @invitations = current_user.invitations.order(created_at: :desc)
  end

  # GET /invitations/1 or /invitations/1.json
  def show
  end

  # GET /invitations/new
  def new
    @invitation = Invitation.new
  end
  # app/controllers/invitations_controller.rb
  def accept
    @invitation.update!(status: Invitation::STATUSES["accepted"])

    Notification.create!(
      user: @invitation.sender,
      title: "Invitación aceptada",
      body: "#{current_user.email} ha aceptado tu invitación al circo #{@invitation.circus.name}."
    )

    circus_user = CircusUser.find_by(user: @invitation.user, circus: @invitation.circus)
    circus_user.update!(active: true, accepted_at: Time.current) if circus_user

    redirect_to invitations_path, notice: "Invitación aceptada."
  end

  def reject
    @invitation.update!(status: Invitation::STATUSES["rejected"])

    Notification.create!(
      user: @invitation.sender,
      title: "Invitación rechazada",
      body: "#{current_user.email} ha rechazado tu invitación al circo #{@invitation.circus.name}."
    )

    redirect_to invitations_path, alert: "Invitación rechazada."
  end



  # GET /invitations/1/edit
  def edit
  end

  # POST /invitations or /invitations.json
  def create
    @invitation = Invitation.new(invitation_params)

    respond_to do |format|
      if @invitation.save
        format.html { redirect_to @invitation, notice: "Invitation was successfully created." }
        format.json { render :show, status: :created, location: @invitation }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /invitations/1 or /invitations/1.json
  def update
    respond_to do |format|
      if @invitation.update(invitation_params)
        format.html { redirect_to @invitation, notice: "Invitation was successfully updated." }
        format.json { render :show, status: :ok, location: @invitation }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @invitation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invitations/1 or /invitations/1.json
  def destroy
    @invitation.destroy!

    respond_to do |format|
      format.html { redirect_to invitations_path, status: :see_other, notice: "Invitation was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invitation
      @invitation = Invitation.find(params[:id])
    end

    def invitation_params
      params.require(:invitation).permit(:user_id, :circus_id, :sender_id, :message, :status)
    end
end
