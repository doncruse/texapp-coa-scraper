require "vcr"
require "webmock/rspec"

VCR.configure do |c|
  c.cassette_library_dir = "spec/vcr"
  c.hook_into :webmock
  c.default_cassette_options = {
    serialize_with: :json,
    # The webmock adapter sorts query params alphabetically, which the old
    # fakeweb adapter did not. Match on parsed query params (order-insensitive)
    # instead of the raw URI string so the existing cassettes still replay.
    match_requests_on: %i[method host path query]
  }
end

RSpec.configure do |c|
  c.around(:each, :vcr) do |example|
    name = example.metadata[:full_description].split(/\s+/, 2).join("/").underscore.gsub(/[^\w\/]+/, "_")
    VCR.use_cassette(name) { example.call }
  end
end
