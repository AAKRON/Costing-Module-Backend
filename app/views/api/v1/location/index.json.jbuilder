# frozen_string_literal: true
json.array! @locations, partial: 'api/v1/location/show.json', as: :location
