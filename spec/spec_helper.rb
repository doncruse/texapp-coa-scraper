$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "coa-op-scraper"
require "support/vcr"

RSpec.configure do |config|
  # The existing specs use the older `should` syntax; keep it enabled
  # alongside `expect` rather than rewriting every assertion.
  config.expect_with(:rspec) { |c| c.syntax = %i[should expect] }

  config.filter_run_when_matching :focus
end
