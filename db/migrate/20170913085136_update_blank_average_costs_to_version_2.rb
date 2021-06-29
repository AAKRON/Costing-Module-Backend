class UpdateBlankAverageCostsToVersion2 < ActiveRecord::Migration[5.0]
  def change
    replace_view :blank_average_costs, version: 2, revert_to_version: 1
  end
end
