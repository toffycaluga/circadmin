# app/controllers/users/invitations_controller.rb
class Users::InvitationsController < Devise::InvitationsController
  layout "dashboard"

  before_action :configure_permitted_parameters, only: [ :create, :update ]

  def after_invite_path_for(resource)
    current_circus ? admin_circus_path(current_circus) : dashboard_index_path
  end

  def create
    unless current_user.circus_users.exists?(circus_id: current_circus.id, role: "owner")
      flash[:alert] = t("users.invitations.permission_denied")
      redirect_to dashboard_index_path
      return
    end

    email = params[:user][:email]
    role  = params[:user][:role]
    user  = User.find_by(email: email)

    if user.present?
      Rails.logger.info "Usuario existente encontrado: #{email}. Intentando invitar al circo."
      invite_existing_user(user, role)
    else
      Rails.logger.info "Usuario no encontrado: #{email}. Invitando como nuevo usuario."
      invite_new_user(email, role)
    end

    redirect_to after_invite_path_for(user)
  end

  def update
    super do |user|
      user.create_user_profile! unless user.user_profile

      if user.errors.empty?
        pending_invitation = CircusUser.where(user: user, accepted_at: nil)
                                       .order(invitation_sent_at: :desc)
                                       .last
        if pending_invitation.present?
          pending_invitation.update!(accepted_at: Time.current)
          Rails.logger.info "Invitación aceptada por #{user.email} para el circo #{current_circus&.name}"
        else
          Rails.logger.warn "No se encontró invitación pendiente para #{user.email} en este circo al aceptar."
        end
      end
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:invite, keys: [ :role ])
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [ :nombre_completo ])
  end

  private

  def invite_existing_user(user, role)
    circus_user = CircusUser.find_by(user: user, circus: current_circus)

    if user.circuses.exists?(current_circus.id)
      flash[:alert] = t("users.invitations.already_member")
      Rails.logger.info "El usuario #{user.email} ya es miembro del circo #{current_circus&.name}."
    elsif circus_user.present?
      if circus_user.accepted_at.nil?
        if circus_user.invitation_sent_at.present? && circus_user.invitation_sent_at < 48.hours.ago
          Rails.logger.info "Reenviando invitación a #{user.email} para el circo #{current_circus&.name}."
          UserMailer.new_circus_invitation(user, current_circus).deliver_later
          circus_user.update!(invitation_sent_at: Time.current)
          flash[:notice] = t("users.invitations.invitation_resent", email: user.email)
        else
          flash[:alert] = t("users.invitations.recent_invitation")
          Rails.logger.info "Invitación reciente para #{user.email} al circo #{current_circus&.name}. No reenviando."
        end
      else
        flash[:alert] = t("users.invitations.already_accepted")
        Rails.logger.info "El usuario #{user.email} ya aceptó una invitación al circo #{current_circus&.name}."
      end
    else
      # Primera vez que se invita a este circo
      Rails.logger.info "Invitando por primera vez a #{user.email} al circo #{current_circus&.name}."
      CircusUser.create!(
        user: user,
        circus: current_circus,
        role: role,
        invitation_sent_at: Time.current
      )
      UserMailer.new_circus_invitation(user, current_circus).deliver_later
      flash[:notice] = t("users.invitations.invited_ok")
    end
  end

  def invite_new_user(email, role)
    Rails.logger.info "Invitando nuevo usuario con correo #{email} al circo #{current_circus&.name}."
    user = User.invite!(email: email)

    if user.persisted?
      CircusUser.create!(
        user: user,
        circus: current_circus,
        role: role,
        invitation_sent_at: Time.current
      )
      flash[:notice] = t("users.invitations.sent", email: email)
      Rails.logger.info "Invitación de Devise enviada a #{email} y asociado al circo."
    else
      flash[:alert] = t("users.invitations.error", error: user.errors.full_messages.to_sentence)
      Rails.logger.error "Error al invitar a #{email}: #{user.errors.full_messages.to_sentence}"
    end
  end
end
