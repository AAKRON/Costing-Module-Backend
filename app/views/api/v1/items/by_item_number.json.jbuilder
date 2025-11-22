item = @item

# Count item jobs
item_jobs_count = ItemJob.where(item_id: item.id).count

# Get all blank IDs linked by item_number
blank_ids = BlanksListingByItem.where(item_number: item.item_number)
                               .pluck(:blank_number)

# Count blank jobs
blank_jobs_count = BlankJob.where(blank_id: blank_ids).count

# Total jobs
total_jobs_count = item_jobs_count + blank_jobs_count

# Render JSON
json.status "success"
json.message "Total jobs fetched successfully"
json.id item.id
json.item_number item.item_number
json.item_jobs_count  item_jobs_count
json.blank_jobs_count blank_jobs_count
json.total_jobs_count total_jobs_count
