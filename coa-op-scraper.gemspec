# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = "coa-op-scraper"
  s.version     = File.read(File.expand_path("VERSION", __dir__)).strip
  s.authors     = ["Don Cruse"]
  s.email       = "doncruse@gmail.com"
  s.homepage    = "http://github.com/doncruse/texapp-coa-scraper"
  s.summary     = "A scraper for intermediate Texas appellate opinions"
  s.description = "A scraper for intermediate appellate opinions"
  s.license     = "MIT"

  s.required_ruby_version = ">= 3.0"

  s.files = Dir["lib/**/*.rb"] + %w[README.md LICENSE.txt VERSION]
  s.require_paths    = ["lib"]
  s.extra_rdoc_files = %w[LICENSE.txt README.md]

  # The gem only relies on ActiveSupport's core extensions (ordinalize,
  # blank?, second, to_date, ...), not on the full Rails framework.
  s.add_dependency "activesupport", ">= 7.0"
  s.add_dependency "nokogiri", ">= 1.16"

  # Development and test dependencies live in the Gemfile.
end
