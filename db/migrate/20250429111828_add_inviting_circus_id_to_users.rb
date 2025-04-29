class AddInvitingCircusIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :inviting_circus_id, :integer
  end
end
