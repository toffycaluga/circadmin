class AddInvitationSentAtToCircusUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :circus_users, :invitation_sent_at, :datetime
  end
end
