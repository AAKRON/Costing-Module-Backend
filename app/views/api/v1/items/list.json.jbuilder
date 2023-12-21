# frozen_string_literal: true
json.array! @items, partial: 'api/v1/items/list.json', as: :item, secondary_box_id_exists: @secondary_box_id_exists