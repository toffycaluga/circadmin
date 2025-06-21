# app/mailers/invitation_mailer.rb
class InvitationMailer < ApplicationMailer
  def notify(invitation)
    @invitation = invitation
    @circus_user = CircusUser.find_by(user: invitation.user, circus: invitation.circus)

    mail(
      to: invitation.user.email,
      subject: "Invitación al circo #{invitation.circus.name}"
    )
  end
end
