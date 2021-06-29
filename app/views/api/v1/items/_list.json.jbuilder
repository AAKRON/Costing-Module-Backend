# frozen_string_literal: true
json.id item.id
json.item_number item.item_number
json.description item.description
json.type_description item.type_description
json.item_type_id item.item_type_id
json.number_of_pcs_per_box item.number_of_pcs_per_box
json.box_name item.box_name || 'none'
json.ink_cost item.ink_cost
json.box_cost item.box_cost
json.total_price_cost item.total_price_cost.round(5)
json.total_inventory_cost item.total_inventory_cost.round(5)
