class JobWithScreenListing < ApplicationRecord
  include Paginatable
  include Searchable

  scope :filter_by_location, ->(location_id, _order, _start, _limit, job_number, screen_id, description, wages_hr) {
    where_clauses = "WHERE TRUE "
    where_clauses = "#{where_clauses} AND job_number::text LIKE '#{job_number}%'" unless job_number.blank?
    where_clauses = "#{where_clauses} AND screen_id = #{screen_id}" unless screen_id.blank?
    where_clauses = "#{where_clauses} AND LOWER(description) LIKE LOWER('#{description}%')" unless description.blank?
    where_clauses = "#{where_clauses} AND wages_per_hour::text LIKE '#{wages_hr}%'" unless wages_hr.blank?

    find_by_sql("SELECT * FROM get_jobs(#{location_id}) #{where_clauses} ORDER BY #{_order} LIMIT #{_limit} OFFSET #{_start};")
  }

  scope :filter_jobs_id_by_location, ->(location_id) {
    find_by_sql("SELECT * FROM get_jobs(#{location_id}) ORDER BY id;")
  }
end
