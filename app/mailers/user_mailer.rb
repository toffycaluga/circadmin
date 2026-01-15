# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
  default from: "no-reply@circadmin.com"

  def new_circus_invitation(user, circus)
    @user = user
    @circus = circus
    @accept_url = accept_invitation_circus_url(@circus)

    mail(
      to: @user.email,
      subject: I18n.t("mailers.user_mailer.new_circus_invitation.subject", circus_name: @circus.name)
    )
  end

  def notify(invitation)
    @invitation = invitation

    mail(
      to: @invitation.user.email,
      subject: I18n.t("mailers.user_mailer.notify.subject", circus_name: @invitation.circus.name)
    )
  end
end
