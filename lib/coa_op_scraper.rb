# encoding=utf-8
module CoaOpScraper
  require 'legacy'
  require 'tames'
  require 'coa_docket_no'

  require 'date'
  require 'open-uri'
  require 'active_support/core_ext'

  # The Texas appellate websites are sometimes fragile. 
  # These sleep intervals should give ample time between requests.
  HISTORICAL_THROTTLE = 10
  CURRENT_THROTTLE = 5

  @@check_weekends = FALSE

  # A court's placement in one of these two hashes tells you about the webpage format
  # currently used by that court.
  TAMES_COAS = [ "01", "04", "05", "06", "09", "11", "12", "14" ]
  LEGACY_COAS = [ "02", "03", "07", "08", "10", "13" ]

  # This is the method that needs to be invoked by cron, early and late each day.
  def self.update_today!
    target_date = Date.today
    return unless @@check_weekends or target_date.weekday?
    (TAMES_COAS + LEGACY_COAS).each do |coa|
      self.process_list_for_coa_date!(coa, target_date, CURRENT_THROTTLE)
    end
  end

  def self.parse_coa_opinion_list_at(coa, url)
    self.scrape_one_opinion_list(coa, url) || []
  end
  # Each element of the array is a hash, consisting of enough information
  # to identify the case and the URLs for any opinions linked off the court page.

  def self.scrape_one_opinion_list(coa, target_date)
    url = self.url_for_coa_for_date(coa, target_date)
    self.parse_coa_opinion_list_at(coa, url)
  end

  # This method would provide a list of the URLs for a particular COA.
  # This could be combined with the parse_coa_opinion_list_at method above
  # to feed a queue that spead this work out across a period of time to lessen
  # the stress on delicate court servers.
  def self.urls_for_historical_range(coa, start_date, end_date)
    result = []
    (start_date .. end_date).each do |target_date|
      next unless @@check_weekends or target_date.weekday?
      result << self.url_for_coa_for_date(coa, target_date)
    end
    result
  end

  def self.url_for_coa_for_date(coa,date)
    if CoaOpScraper::TAMES_COAS.include?(coa)
      CoaOpScraper::Tames.url_for_coa_for_date(coa,date)
    elsif CoaOpScraper::LEGACY_COAS.include?(coa)
      CoaOpScraper::Legacy.url_for_coa_for_date(coa,date)
    end
  end

  def self.retrieve_list_for_coa_for_date(coa,date)
    url = self.url_for_coa_for_date(coa,date)
    open(url)
  end

  def self.scrape_one_opinion_list(coa,target_date)
    doc = self.retrieve_list_for_coa_for_date(coa,target_date)
    if CoaOpScraper::TAMES_COAS[coa]
      CoaOpScraper::Tames.parse_opinion_list(doc)
    elsif CoaOpScraper::LEGACY_COAS[coa]
      CoaOpScraper::Legacy.parse_opinion_list(doc)
    end
  end

end

# This is required (and helpful) to parse Texas court docket pages
class String
  def nbsp_strip
    strip.gsub(/\u00a0$/,"").gsub(/^\u00a0/,"").strip
  end # gets rid of some pesky unicode found on Texas OCA sites

  def strip_both_ends
    nbsp_strip.nbsp_strip.reverse.nbsp_strip.nbsp_strip.reverse
  end
end

class Date
  def weekday?
    !self.saturday? and !self.sunday?
  end
end
