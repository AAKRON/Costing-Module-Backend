# frozen_string_literal: true
json.array! @blank_jobs, partial: 'api/v1/blank_jobs/list.json', as: :blank_job
