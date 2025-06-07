class RemoveNotesFromLocalities < ActiveRecord::Migration[8.0]
  def change
    remove_column :localities, :notes, :text
  end
end
