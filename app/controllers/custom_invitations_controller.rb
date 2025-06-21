class CustomInvitationsController < ApplicationController
  def create
    email = params[:user][:email]
    role  = params[:user][:role]

    unless current_circus
      flash[:alert] = t("notifications.flash.invitation.no_active_circus")
      return redirect_to dashboard_index_path
    end

    if email.blank?
      flash[:alert] = t("notifications.flash.invitation.email_blank")
      return redirect_back fallback_location: root_path
    end

    unless email.match?(/\A[^@\s]+@[^@\s]+\z/)
      flash[:alert] = t("notifications.flash.invitation.email_invalid")
      return redirect_back fallback_location: root_path
    end

    existing_user = User.find_by(email: email)

    if existing_user
      handle_existing_user(existing_user, role)
    else
      invited_user = User.invite!(email: email) { |u| u.skip_invitation = false }

      if invited_user.errors.any?
        flash[:alert] = t("notifications.flash.invitation.invite_error", errors: invited_user.errors.full_messages.to_sentence)
      else
        handle_circus_user(invited_user, role)
        create_internal_invitation(invited_user, role)
        flash[:notice] = t("notifications.flash.invitation.invite_success", email: invited_user.email)
      end
    end

    redirect_back fallback_location: root_path
  end

  def resend_email
    invitation = Invitation.find(params[:id])

    if invitation.user.present?
      InvitationMailer.notify(invitation).deliver_now

      Notification.create!(
        user: invitation.user,
        title: t("notifications.invitation.resent.title"),
        body: t("notifications.invitation.resent.body", sender_email: current_user.email, circus: invitation.circus.name)

      )

      flash[:notice] = t("notifications.flash.invitation.resent_success")
    else
      flash[:alert] = t("notifications.flash.invitation.resent_error")
    end

    redirect_back fallback_location: root_path
  end

  private

  def handle_existing_user(user, role)
    cu = CircusUser.find_or_initialize_by(user: user, circus: current_circus)

    if cu.persisted? && cu.active?
      flash[:alert] = t("notifications.flash.invitation.already_active")
      return
    end

    cu.assign_attributes(role: role, active: false, accepted_at: nil)
    cu.save!

    create_internal_invitation(user, role)
  end

  def handle_circus_user(user, role)
    cu = CircusUser.find_or_initialize_by(user: user, circus: current_circus)
    cu.assign_attributes(role: role, active: true)
    cu.save!
  end

  def create_internal_invitation(user, role)
    Invitation.where(user: user, circus: current_circus, status: Invitation::STATUSES["pending"])
              .update_all(status: Invitation::STATUSES["rejected"])

    message = t("notifications.invitation.new.body", circus: current_circus.name, role: role)

    invitation = Invitation.new(
      user: user,
      circus: current_circus,
      sender: current_user,
      message: message,
      status: Invitation::STATUSES["pending"]
    )

    if invitation.save
      Notification.create!(
        user: user,
        title: t("notifications.invitation.new.title"),
        body: message
      )
      InvitationMailer.notify(invitation).deliver_now
      flash[:notice] = t("notifications.flash.invitation.invite_success", email: user.email)
    else
      flash[:alert] = t("notifications.flash.invitation.invite_error", errors: invitation.errors.full_messages.to_sentence)
    end
  end
end
