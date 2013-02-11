# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "coa-op-scraper"
  gem.homepage = "http://github.com/doncruse/coa-op-scraper"
  gem.license = "(c)2013 Don Cruse"
  gem.summary = "A scraper for intermediate Texas appellate opinions"
  gem.description = "A scraper for intermediate appellate opinions"
  gem.email = "doncruse@gmail.com"
  gem.authors = ["Don Cruse"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new
task :default => :spec

Rake::Task[:release].prerequisites.delete('gemcutter:release')
