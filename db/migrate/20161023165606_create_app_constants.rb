class CreateAppConstants < ActiveRecord::Migration[5.0]
  def change
    create_table :app_constants do |t|
      t.string :code
      t.string :value

      t.timestamps
    end
  end
end
