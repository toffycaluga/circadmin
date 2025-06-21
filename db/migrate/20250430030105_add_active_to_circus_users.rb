class AddActiveToCircusUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :circus_users, :active, :boolean
  end
end
