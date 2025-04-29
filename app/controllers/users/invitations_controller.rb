# app/controllers/users/invitations_controller.rb
class Users::InvitationsController < Devise::InvitationsController
  layout "dashboard"

  before_action :configure_permitted_parameters, only: [ :create, :update ]

  def after_invite_path_for(resource)
    current_circus ? admin_circus_path(current_circus) : dashboard_index_path
  end

  def create
    email = params[:user][:email]
    role  = params[:user][:role]
    user  = User.find_by(email: email)

    if user.present?
      if user.invitation_accepted_at.nil?
        # Usuario ya existe pero no aceptó → Reenviar invitación
        user.invite!
        flash[:notice] = "Invitation resent to #{email}."
      else
        # Usuario ya aceptó la invitación → solo asociarlo al circo
        unless user.circuses.exists?(current_circus.id)
          CircusUser.create!(user: user, circus: current_circus, role: role)

          # Enviar correo especial de invitación a nuevo circo
          UserMailer.new_circus_invitation(user, current_circus).deliver_later

          flash[:notice] = "User was already registered and has been invited to this circus."
        else
          flash[:alert] = "User is already part of this circus."
        end

      end
    else
      # Usuario nuevo → enviar invitación
      user = User.invite!(email: email) do |u|
        u.inviting_circus_id = current_circus.id
      end


      if user.persisted?
        # Guardamos en sesión la intención de asociarlo cuando acepte
        session["inviting_circus_id_#{user.id}"] = { circus_id: current_circus.id, role: role }
        flash[:notice] = "Invitation sent to #{email}."
      else
        flash[:alert] = user.errors.full_messages.to_sentence
      end
    end

    redirect_to after_invite_path_for(user)
  end

  def update
    super do |user|
      user.create_user_profile! unless user.user_profile

      if user.errors.empty?
        if user.inviting_circus_id.present?
          unless user.circuses.exists?(user.inviting_circus_id)
            CircusUser.create!(
              user: user,
              circus_id: user.inviting_circus_id,
              role: "representante" # o el rol que prefieras
            )
          end
          user.update(inviting_circus_id: nil) # Limpiar el campo después de asociarlo
        end
      end
    end
  end


  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:invite, keys: [ :role ])
    devise_parameter_sanitizer.permit(:accept_invitation, keys: [ :nombre_completo ])
  end
end
