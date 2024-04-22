# frozen_string_literal: true
job_price_cost = 0.0
job_inventory_cost = 0.0

blank_price_cost = 0.0
blank_inventory_cost = 0.0
job_screen_cost = 0.0
ink_cost = ink_column_exists ? InksLocationPrice.get_ink_cost_by_location(item.location_id, item.ink_id) : item.ink_cost.round(5)
ink_id = ink_column_exists ? item.ink_id : nil

default_blank_cost_modifier_multi = 1
default_blank_cost_modifier_div = 1

json.id item.id
json.item_number item.item_number
json.description item.description
json.number_of_pcs_per_box item.number_of_pcs_per_box
json.ink_cost ink_cost
json.ink_id ink_id
json.box_id item.box_id
json.secondary_box_id (secondary_box_id_exists ? item.secondary_box_id : nil)
json.number_of_pcs_per_secondary_box (secondary_box_id_exists ? item.number_of_pcs_per_secondary_box : nil)
json.item_type_id item.item_type_id
json.type_number item.item_type.type_number
json.box_cost item.box_cost

unless item.box.nil?
  json.box_cost item.box.cost_per_box.to_f.round(5)
  json.box_name item.box.name
end

json.jobs do
  json.array! item.item_jobs do |job|
    job = ItemJobDecorator.new(job)
    json.job_number job.job_number
    json.description job.description
    json.wages_per_hour job.wages_per_hour
    json.hour_per_piece job.hour_per_piece.round(5)
    json.direct_labor_cost job.direct_labor_cost
    json.overhead_inventory_cost job.overhead_inventory_cost
    json.overhead_pricing_cost job.overhead_pricing_cost
    json.total_inventory_cost job.total_inventory_cost.round(5)
    json.total_pricing_cost job.total_pricing_cost.round(5)
    json.job_listing_id job.job_listing_id
    job_price_cost = job_price_cost + job.total_pricing_cost.to_f
    job_inventory_cost = job_inventory_cost + job.total_inventory_cost.to_f
  end
end
json.blanks do
  json.array! item.blanks_listing_by_item do |blank|
    blank = item.location_id != 0 ? BlankCostView.get_blank_by_location(item.location_id, blank.blank_number) : BlankCostView.find_by_blank_number(blank.blank_number)
    blank_cost_modifier = BlanksListingByItem.find_by_item_number_and_blank_number(item.item_number, blank.blank_number)
    unless blank.nil?
      total_blank_cost_for_price = blank.total_blank_cost_for_price + blank.cost
      total_blank_cost_for_inventory = blank.total_blank_cost_for_inventory + blank.cost

      json.blank_number blank.blank_number
      json.description blank.description
      json.blank_type blank.blank_type
      json.type_number blank.type_number
      json.cost blank.cost
      json.total_blank_cost_for_price total_blank_cost_for_price
      json.total_blank_cost_for_inventory total_blank_cost_for_inventory
      unless blank_cost_modifier.nil?
        default_blank_cost_modifier_multi = blank_cost_modifier.mult
        default_blank_cost_modifier_div = blank_cost_modifier.div
        json.multiplication default_blank_cost_modifier_multi
        json.division default_blank_cost_modifier_div
      end
      total_blank_cost_for_price_modify = (total_blank_cost_for_price * default_blank_cost_modifier_multi) / default_blank_cost_modifier_div
      total_blank_cost_for_inventory_modify = (total_blank_cost_for_inventory * default_blank_cost_modifier_multi) / default_blank_cost_modifier_div

      json.total_blank_cost_for_price_modify total_blank_cost_for_price_modify
      json.total_blank_cost_for_inventory_modify total_blank_cost_for_inventory_modify

      blank_price_cost = blank_price_cost + total_blank_cost_for_price_modify
      blank_inventory_cost = blank_inventory_cost + total_blank_cost_for_inventory_modify
    end
  end
end
json.screen do
  json.array! item.item_jobs do |job|
    job = ItemJobDecorator.new(job)
    job_listings = JobListing.find_by_id(job.job_listing_id)
    unless job_listings.screen.nil?
      json.job_listing_id job.job_listing_id
      json.job_number job.job_number
      json.description job.description
      json.screen_name job_listings.screen.screen_size
      json.screen_cost job.screen_location_cost.round(5)
      job_screen_cost = job_screen_cost + job.screen_location_cost.to_f
    end
  end
end

secondary_box_cost = 0
if secondary_box_id_exists
  secondary_box_cost = item.location_id != 0 ? BoxesLocationPrice.get_box_cost(item.location_id, item.secondary_box.id, item.number_of_pcs_per_secondary_box) : item.secondary_box.cost_per_box.to_f.round(5)
  json.secondary_box_cost secondary_box_cost
  json.secondary_box_name item.secondary_box.name
end

item_box_cost = item.location_id != 0 ? BoxesLocationPrice.get_box_cost(item.location_id, item.box.id, item.number_of_pcs_per_box) : item.box_cost.round(5)
json.item_box_cost item_box_cost
json.job_price_cost job_price_cost.round(5)
json.job_inventory_cost job_inventory_cost.round(5)
json.job_screen_cost job_screen_cost.round(5)
json.blank_price_cost blank_price_cost.round(5)
json.blank_inventory_cost blank_inventory_cost.round(5)

total_price_cost = blank_price_cost.round(5) + job_price_cost.round(5) + job_screen_cost.round(5) + item_box_cost + secondary_box_cost + ink_cost
json.total_price_cost total_price_cost.round(5)

total_inventory_cost = blank_inventory_cost.round(5) + job_inventory_cost.round(5) + job_screen_cost.round(5) + item_box_cost + secondary_box_cost + ink_cost
json.total_inventory_cost total_inventory_cost.round(5)
