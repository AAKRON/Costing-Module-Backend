# frozen_string_literal: true
# app_constants = [{ id: 1,
#                    name: 'inventory_overhead_percentage',
#                    value: '0.9569',
#                    created_at: '2017-02-16T15:51:57.544Z',
#                    updated_at: '2017-02-16T15:51:57.544Z' },
#                  { id: 2,
#                    name: 'price_overhead_percentage',
#                    value: '4',
#                    created_at: '2017-02-16T15:51:57.557Z',
#                    updated_at: '2017-02-16T15:51:57.557Z' }]
#
# AppConstant.create(app_constants)

#screen_sizes = [
#  {id: 1, screen_size: 'small', cost: 0.0037 },
#  {id: 2, screen_size: 'medium', cost: 0.0076 },
#  {id: 3, screen_size: 'large', cost: 0.0156 }
#]
#Screen.create(screen_sizes)

# # Create test user
# User.create(username: 'test', role:'admin')

# # Create job listing
# FactoryBot.create_list(:job_listing, 20)

# Create blanks
FactoryBot.create_list(:blank, 20)
