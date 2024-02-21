class ItemBlankDecorator < SimpleDelegator
  def initialize(item_blank)
    @item_blank = item_blank
  end

  def blank_number
    item_blank.blank_number
  end

  def description
    item_blank.description
  end

  def blank_type
    item_blank.blank_type
  end

  def type_number
    item_blank.type_number
  end

  def cost
    item_blank.cost
  end

  def total_blank_cost_for_price
    item_blank.total_blank_cost_for_price
  end

  def total_blank_cost_for_inventory
    item_blank.total_blank_cost_for_inventory
  end

end
