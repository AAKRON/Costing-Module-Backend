# frozen_string_literal: true
json.array! @items, partial: 'api/v1/items/show.json', as: :item


