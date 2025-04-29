# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
    default from: "no-reply@circadmin.com"

    def new_circus_invitation(user, circus)
      @user = user
      @circus = circus
      @accept_url = accept_invitation_circus_url(@circus)

      mail(
        to: @user.email,
        subject: "¡Has sido invitado a unirte a #{@circus.name} en CircAdmin!"
      )
    end
end
