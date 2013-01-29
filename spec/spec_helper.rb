$:.unshift File.dirname(__FILE__) + '/../lib'
require 'coa_op_scraper'
require 'support/vcr'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
end

# per http://www.intridea.com/blog/2012/3/8/polishing-rubies-part-iii
