class UpdateBlankAverageCostsToVersion4 < ActiveRecord::Migration[5.0]
  def change
    replace_view :blank_average_costs, version: 4, revert_to_version: 3
  end
end
