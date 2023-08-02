# frozen_string_literal: true
json.id blanks_listing_item_with_cost.id
json.item_id item.id
json.item_number item.item_number
json.blanks_listing_by_item do
  json.array! item.blanks_listing_item_with_cost do |item_blanks|
    json.blanks_listing_item_with_cost_id item_blanks.id
    json.blank_id item_blanks.blank.id
    json.blank_number item_blanks.blank_number
		json.blank_description item_blanks.blank.description
  end
end
