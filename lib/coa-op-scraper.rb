# encoding=utf-8
module CoaOpScraper
  require 'legacy'
  require 'tames'
  require 'coa_docket_no'
  require 'tames_link'
  require 'tames_case_style'

  require 'date'
  require 'open-uri'
  require 'active_support'
  require 'active_support/core_ext'

  # The Texas appellate websites are sometimes fragile.
  # These sleep intervals should give ample time between requests.
  HISTORICAL_THROTTLE = 10
  CURRENT_THROTTLE = 5

  @@check_weekends = false

  # A court's placement in one of these two hashes tells you about the webpage format
  # currently used by that court.
  TAMES_COAS = [ "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14" ]
  LEGACY_COAS = [ ]

  ############################################################
  # This is the easiest method to use here.  Feed it a COA value
  # (in the form "03", for example) and the date for which you
  # want the results (in the form of a Ruby date object).
  #
  def self.scrape_one_opinion_list(coa,target_date)
    doc = self.retrieve_list_for_coa_for_date(coa,target_date)
    if CoaOpScraper::TAMES_COAS.include?(coa)
      CoaOpScraper::Tames.parse_opinion_list(doc, coa)
    elsif CoaOpScraper::LEGACY_COAS.include?(coa)
      CoaOpScraper::Legacy.parse_opinion_list(doc)
    end
  end

  ############################################################
  # These methods would be useful to populate a queue of opinion
  # lists to check later.
  #
  # The #urls_for_historical_range method will, as expected,
  # compute a list of the URLs that are appropriate (excluding
  # weekends by default).
  #
  # The #parse_coa_opinion_list_at method will take a coa number
  # and a URL and return back a list of the results.

  def self.urls_for_historical_range(coa, start_date, end_date)
    result = []
    (start_date .. end_date).each do |target_date|
      next unless @@check_weekends or target_date.weekday?
      result << self.url_for_coa_for_date(coa, target_date)
    end
    result
  end # returns an array of URLs

  def self.parse_coa_opinion_list_at(coa, url)
    self.scrape_one_opinion_list(coa, url) || []
  end # takes a URL, returns a list of the opinion data

protected

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
