# frozen_string_literal: true
json.id item.id
json.item_number item.item_number
json.description item.description
json.type_description item.type_description
json.item_type_id item.item_type_id
json.number_of_pcs_per_box item.number_of_pcs_per_box
json.box_name item.box_name || 'none'
json.box_cost item.box_cost
json.secondary_box_cost secondary_box_id_exists ? item.secondary_box_cost : 0.00
json.total_price_cost item.total_price_cost ? item.total_price_cost.round(5) : 0.00
json.total_inventory_cost item.total_inventory_cost ? item.total_inventory_cost.round(5) : 0.00
json.ink_cost item.ink_cost ? item.ink_cost.round(5) : 0.00
item_jobs_count = ItemJob.where(item_id: item.id).count
blank_ids = BlanksListingByItem.where(item_number: item.item_number).pluck(:blank_number)
blank_jobs_count = BlankJob.where(blank_id: blank_ids).count
total_jobs_count = item_jobs_count+blank_jobs_count
json.item_jobs_count  item_jobs_count
json.blank_jobs_count  blank_jobs_count
json.total_jobs_count total_jobs_count

