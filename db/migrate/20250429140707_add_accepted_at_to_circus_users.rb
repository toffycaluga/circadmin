class AddAcceptedAtToCircusUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :circus_users, :accepted_at, :datetime
  end
end
