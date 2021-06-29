class DocumentType < ActiveRecord::Migration[5.0]
  def change
    add_column :documents, :document_type, :string
  end
end
