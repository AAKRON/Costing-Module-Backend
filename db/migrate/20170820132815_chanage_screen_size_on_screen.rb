class ChanageScreenSizeOnScreen < ActiveRecord::Migration[5.0]
  def change
    change_column :screens, :screen_size, :string
  end
end
