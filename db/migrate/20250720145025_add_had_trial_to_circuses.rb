class AddHadTrialToCircuses < ActiveRecord::Migration[8.0]
  def change
    add_column :circuses, :had_trial, :boolean, default: false, null: false
  end
end
