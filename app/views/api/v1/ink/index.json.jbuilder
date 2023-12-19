# frozen_string_literal: true
json.array! @inks, partial: 'api/v1/ink/show.json', as: :ink
