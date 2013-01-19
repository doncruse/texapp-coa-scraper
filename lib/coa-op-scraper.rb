# encoding=utf-8
module CoaOpScraper
  require 'legacy'
  require 'tames'
  require 'scraped_coa_opinion'
  require 'coa_docket_no'
	require 'date'
	require 'open-uri'
  require 'active_support/core_ext'

  # The Texas appellate websites are sometimes fragile. 
  # These sleep intervals should give ample time between requests.
  HISTORICAL_THROTTLE = 10
  CURRENT_THROTTLE = 5

	@@check_weekends = FALSE

  # These hashes perform two functions. (I feel a refactoring coming.)
  # First, the assignment of a particular court of appeals number to a hash
  # signals which of the two logic modules should be invoked - "tames" or "legacy".
  # Second, the value here represents part of the substring of the URL for that
  # court of appeals's website.  (This value is critical to accessing "legacy" courts.)
  TAMES_COAS = { 
    "01" => "1stcoa",
    "04" => "4thcoa",
    "05" => "5thcoa",
    "06" => "6thcoa",
    "09" => "9thcoa",
    "12" => "12thcoa",
    "14" => "14thcoa"
  }

  LEGACY_COAS = { 
    '02' => '2ndcoa',
    '03' => '3rdcoa',
    '07' => '7thcoa',
    '08' => '8thcoa',
    '10' => '10thcoa',
    '11' => '11thcoa',
    '13' => '13thcoa'										
  }

    # This is the method that needs to be invoked by cron, early and late each day.
		def self.update_today!
			target_date = Date.today
      return unless @@check_weekends or target_date.weekday?
			(TAMES_COAS.keys + LEGACY_COAS.keys).each do |coa|
        self.process_list_for_coa_date!(coa, target_date, CURRENT_THROTTLE)
			end
		end

    # This method comprises the heart of the loops.
		def self.process_list_for_coa_date!(coa, target_date, delay=0)
      url = self.url_for_coa_for_date(coa, target_date)
      data = self.scrape_one_opinion_list(coa, url)
			self.store_scraped_opinion_array(data)
      sleep delay
    end

    # Takes an array of opinion data hashes and then carefully
    # places each one into the storage engine.  Here, that is
    # implemented by instantiating a new ScrapedCoaOpinion
    # object.
    def self.store_scraped_opinion_array(data_array)
      data_array.each do |opinion_hash|
        op = CoaOpScraper::ScrapedCoaOpinion.new(opinion_hash)
        op.save  # folds in a check for uniqueness
      end
    end

    # Be aware: There is no check here to see whether the page has already been
    # scraped, so this can result in significant repeated work.  This method
    # should only need to be invoked once -- unless the courts later add
    # information to the "back catalog" (like adding opinion PDFs where they
    # currently just have placeholders on the orders list).
		def self.populate_historical_range(coa, start_date, end_date)
			(start_date .. end_date).each do |target_date|
        next unless @@check_weekends or target_date.weekday?
        self.process_list_for_coa_date!(coa, target_date, HISTORICAL_THROTTLE)
			end
		end

    # Idea is that this could be invoked from outside the gem, and then 
    # each of these URLs could be inserted into a queue to spread out the
    # load against the server. (An improvement would be a method that took
    # a function as an argument and did that function on each element.)
		def self.urls_for_historical_range(coa, start_date, end_date)
      result = []
			(start_date .. end_date).each do |target_date|
        next unless @@check_weekends or target_date.weekday?
        result << self.url_for_coa_for_date(coa, target_date)
			end
      result
		end

		def self.url_for_coa_for_date(coa,date)
			if CoaOpScraper::TAMES_COAS[coa]
				CoaOpScraper::Tames.url_for_coa_for_date(coa,date)
			elsif CoaOpScraper::LEGACY_COAS[coa]
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
