# app/mailers/invitation_mailer.rb
class InvitationMailer < ApplicationMailer
  def notify(invitation)
    @invitation = invitation
    @circus_user = CircusUser.find_by(user: invitation.user, circus: invitation.circus)

    mail(
      to: invitation.user.email,
      subject: I18n.t("mailers.invitation_mailer.subject", circus_name: invitation.circus.name)
    )
  end
end
