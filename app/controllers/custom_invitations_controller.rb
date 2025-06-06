class CustomInvitationsController < ApplicationController
  def create
    email = params[:user][:email] # ❗ CORREGIDO: el email no viene dentro de :user
    role  = params[:user][:role]
    unless current_circus
      flash[:alert] = "No hay un circo activo en la sesión."
      redirect_to dashboard_index_path and return
    end
    if email.blank?
      flash[:alert] = "El correo no puede estar vacío."
      return redirect_back fallback_location: root_path
    end

    unless email.match?(/\A[^@\s]+@[^@\s]+\z/)
      flash[:alert] = "El correo no tiene un formato válido."
      return redirect_back fallback_location: root_path
    end

    existing_user = User.find_by(email: email)

    if existing_user
      handle_existing_user(existing_user, role)
    else
      invited_user = User.invite!(email: email) do |u|
        u.skip_invitation = false
      end

      if invited_user.errors.any?
        flash[:alert] = "Hubo un error al enviar la invitación: #{invited_user.errors.full_messages.to_sentence}"
      else
        handle_circus_user(invited_user, role)
        create_internal_invitation(invited_user, role)
        flash[:notice] = "Usuario invitado por email e invitación interna creada."
      end
    end

    redirect_back fallback_location: root_path
  end
  # app/controllers/custom_invitations_controller.rb
  def resend_email
    invitation = Invitation.find(params[:id])

    if invitation.user.present?
      InvitationMailer.notify(invitation).deliver_now
      flash[:notice] = "Correo de invitación reenviado correctamente."
    else
      flash[:alert] = "No se pudo reenviar la invitación."
    end

    redirect_back fallback_location: root_path
  end


  private

  def handle_existing_user(user, role)
    circus_user = CircusUser.find_or_initialize_by(user: user, circus: current_circus)

    if circus_user.persisted?
      if circus_user.active?
        flash[:alert] = "Este usuario ya está activo en este circo."
      else
        circus_user.update!(role: role, active: true)
        flash[:notice] = "El usuario fue reactivado con el nuevo rol."
      end
    else
      circus_user.assign_attributes(role: role, active: true)
      circus_user.save!
      flash[:notice] = "Usuario existente asociado al circo con rol #{role}."
    end

    create_internal_invitation(user, role)
  end

  def handle_circus_user(user, role)
    circus_user = CircusUser.find_or_initialize_by(user: user, circus: current_circus)
    circus_user.assign_attributes(role: role, active: true)
    circus_user.save!
  end

  def create_internal_invitation(user, role)
    Invitation.create!(
      user: user,
      circus: current_circus,
      sender: current_user,
      message: "Has sido invitado como #{role}.",
      status: Invitation::STATUSES["pending"]
    )
  end
end
