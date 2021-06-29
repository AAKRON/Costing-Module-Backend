# frozen_string_literal: true
json.array! @job_listings, partial: 'api/v1/job_listings/show.json', as: :job_listing

