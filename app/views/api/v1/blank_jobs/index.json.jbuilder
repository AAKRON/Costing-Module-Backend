# frozen_string_literal: true
json.array! @blank_jobs, partial: 'api/v1/blank_jobs/show.json', as: :blank_job
