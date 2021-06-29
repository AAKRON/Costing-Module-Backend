class ChangeCodeToNameOnAppConstant < ActiveRecord::Migration[5.0]
  def change
    rename_column :app_constants, :code, :name
  end
end
