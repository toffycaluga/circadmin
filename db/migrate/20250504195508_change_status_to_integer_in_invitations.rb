class ChangeStatusToIntegerInInvitations < ActiveRecord::Migration[8.0]
  def change
    change_column :invitations, :status, :integer, using: 'status::integer', default: 0, null: false
  end
end
