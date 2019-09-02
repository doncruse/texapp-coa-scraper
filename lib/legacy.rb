# encoding=utf-8
require 'nokogiri'
require 'open-uri'
require 'date'
require 'active_support'
require 'active_support/core_ext'


module CoaOpScraper
  module Legacy

    def self.url_for_coa_for_date(coa,date)
      datestring = date.to_date.strftime("%Y%m%d")
      root_path = "http://www.#{coa.to_i.ordinalize}coa.courts.state.tx.us/"
      root_path + "opinions/docket.asp?FullDate=#{datestring}"
    end

    def self.parse_opinion_list(doc)
      data = Nokogiri::HTML.parse(doc)

      # Note: A quirk in Nokogiri - this TABLE is actually nested inside a P, but	 it's "correcting" the HTML
      # so... I'm relying on finding the relevant <P> and lining each next to the corresponding <TABLE>
      target_zone = data.search("#submission").search("p")								# Also contain the headers
      targets = target_zone.select { |t| t.inner_text.match(/Before/) }		# Focus just on opinion releases
      docket_targets = data.search("#submission").search("table")					# <TABLE> follows each

      # release date
      srd = data.search('#submission').search('p').first.inner_text.split("Opinions").last
      release_date = srd.strip_both_ends.to_date

      results = []
      targets.each_with_index do |t,i|
        next if docket_targets.count < (i + 1)
        # because can't complete the match at the end

        result = Hash.new
        opinions = t.search("a")

        result[:author_string] = opinions.first.inner_text.strip_both_ends
        result[:opinion_urls] = {}
        opinions.each do |op|
          text_part = op.inner_text.downcase
          href_target = op["href"]
          if href_target.downcase.match(/pdfopinion/) or text_part.match(/pdf/)
            result[:opinion_urls]["pdf"] = href_target
          elsif href_target.downcase.match(/htmlopinion/)
            result[:opinion_urls]["html"] = href_target
          elsif text_part.match(/wpd/)
            result[:opinion_urls]["wpd"] = href_target
          end
        end
        spans = t.search("span")
        result[:disposition] = spans.first.inner_text.strip_both_ends
        result[:panel_string] = t.search("b").inner_text.strip_both_ends

        result[:release_date] = release_date				

        source = docket_targets[i].search("td").last.inner_text
        parts = source.split("--")
        if parts.size == 2
          result[:case_style] = parts.first.gsub("  "," ")
          result[:origin] = parts.second
        elsif parts.size == 1
          result[:case_style] = parts.first.gsub("  "," ")
        end

        result[:docket_no] = docket_targets[i].search("a").inner_text
        result[:docket_page_url] = docket_targets[i].search("a").first["href"]
        # ensuring enough info to salvage if I need to
        next if result[:docket_no].nil? or result[:docket_page_url].nil?
        next if result[:docket_no].blank? or result[:docket_page_url].blank?
        results << result
      end
      results
    end # returns an array of opinion_metadata hashes

  end
end
