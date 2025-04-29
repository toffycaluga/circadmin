class UserMailer < ApplicationMailer
    default from: "no-reply@circadmin.com"

    def new_circus_invitation(user, circus)
      @user = user
      @circus = circus
      mail(
        to: @user.email,
        subject: "¡Has sido invitado a unirte a #{@circus.name} en CircAdmin!"
      )
    end
end
