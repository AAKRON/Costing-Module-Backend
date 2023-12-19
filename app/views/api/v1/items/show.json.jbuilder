# frozen_string_literal: true

json.partial! 'api/v1/items/show.json', item: @item, ink_column_exists: @ink_column_exists, secondary_box_id_exists: @secondary_box_id_exists
