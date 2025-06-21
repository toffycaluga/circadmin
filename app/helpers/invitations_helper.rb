# app/helpers/invitations_helper.rb
module InvitationsHelper
  def status_badge(invitation)
    status = invitation.status_name
    color = case status
    when "pending" then "warning"
    when "accepted" then "success"
    when "rejected" then "secondary"
    else "light"
    end

    content_tag :span, t("invitations.statuses.#{status}", default: status.capitalize),
                class: "badge badge-#{color}"
  end
end
