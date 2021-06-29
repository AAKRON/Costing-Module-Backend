# frozen_string_literal: true
json.array! @items, partial: 'api/v1/item_jobs/list.json', as: :item
