class CreateBlankAverageCosts < ActiveRecord::Migration[5.0]
  def change
    create_view :blank_average_costs
  end
end
