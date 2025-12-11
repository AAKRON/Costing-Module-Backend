# Ruby 3.1.4 compatibility - ensure stdlib gems are loaded before Rails
# These were extracted from Ruby core in 3.x and need explicit loading

require 'logger'
require 'ostruct' 
require 'bigdecimal'
require 'mutex_m'
require 'drb'

# Ensure Logger constant is available globally
Object.const_set('Logger', ::Logger) unless defined?(::Logger)