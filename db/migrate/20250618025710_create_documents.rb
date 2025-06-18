class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.string :title
      t.text :description
      t.integer :document_type
      t.references :user, null: false, foreign_key: true
      t.references :circus, null: false, foreign_key: true

      t.timestamps
    end
  end
end
