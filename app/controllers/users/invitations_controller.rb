# app/controllers/users/invitations_controller.rb
class Users::InvitationsController < Devise::InvitationsController
    layout "dashboard"

    before_action :configure_permitted_parameters, only: [ :create, :update ]

    def after_invite_path_for(resource)
      admin_dashboard_path
    end

    protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:invite, keys: [ :role ])
      devise_parameter_sanitizer.permit(:accept_invitation, keys: [ :nombre_completo ])
    end
end
