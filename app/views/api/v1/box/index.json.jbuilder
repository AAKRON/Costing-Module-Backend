# frozen_string_literal: true
json.array! @boxes, partial: 'api/v1/box/show.json', as: :box
