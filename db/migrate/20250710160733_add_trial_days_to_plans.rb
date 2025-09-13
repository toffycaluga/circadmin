class AddTrialDaysToPlans < ActiveRecord::Migration[8.0]
  def change
    add_column :plans, :trial_days, :integer, null: false, default: 0
  end
end
