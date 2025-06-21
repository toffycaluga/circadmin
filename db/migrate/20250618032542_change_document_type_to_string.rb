class ChangeDocumentTypeToString < ActiveRecord::Migration[8.0]
  def change
    change_column :documents, :document_type, :string
  end
end
