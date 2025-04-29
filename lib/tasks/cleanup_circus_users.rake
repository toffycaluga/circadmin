namespace :circus_users do
    desc "Eliminar solo CircusUser de invitaciones no aceptadas (48h vencidas)"
    task cleanup_expired_invitations: :environment do
      expired_invitations = CircusUser.where.not(invitation_sent_at: nil)
                                       .where(accepted_at: nil)
                                       .where.not(role: "dueño")
                                       .where("invitation_sent_at < ?", 48.hours.ago)

      count = expired_invitations.count
      expired_invitations.destroy_all

      puts "Eliminadas #{count} invitaciones expiradas de CircusUser."
    end
  end
