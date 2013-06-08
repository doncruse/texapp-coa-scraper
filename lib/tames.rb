# encoding=utf-8
require 'nokogiri'
require 'open-uri'
require 'date'
require 'active_support/core_ext'

module CoaOpScraper
  module Tames

    def self.url_for_coa_for_date(coa,date)
      datestring = date.to_date.strftime("%m/%d/%Y")
      root_path = "http://www.search.txcourts.gov/Docket.aspx?coa="
      root_path + "coa#{coa}&FullDate=#{datestring}"
    end

    def self.parse_opinion_list(doc, coa_number=nil)
      data = Nokogiri::HTML.parse(doc)

      main_targets = data.search("table[class=rgMasterTable]").search("tr[class=rgRow]")
      alt_targets = data.search("table[class=rgMasterTable]").search("tr[class=rgAltRow]")
      targets = main_targets + alt_targets

      raw_release_date = data.search("span.TitleBlue").search("span")[1].inner_text
      release_date = self.date_from_oddball(raw_release_date.strip_both_ends)

      results = []
      targets.each do |t|
        result = Hash.new
        result[:release_date] = release_date
        result[:opinion_urls] = {}
        t.search("a").each do |link|
          if link.inner_text.match(/\d\d\d\d/)
            result[:docket_no] = link.inner_text
            result[:docket_page_url] = link["href"]
            next
          end
          text_part = link.inner_text.downcase
          possible_link = link["href"]
          possible_link.gsub!(/(?<=coa=).*CurrentWebState.*(?=&DT)/,"coa#{coa_number.to_s}") if coa_number
#          \" + this.CurrentWebState.CurrentCourt + @\"
          if text_part.match(/pdf/)
            result[:opinion_urls]["pdf"] = possible_link
          elsif text_part.match(/htm/)
            result[:opinion_urls]["html"] = possible_link
          elsif text_part.match(/wpd/)
            result[:opinion_urls]["wpd"] = possible_link
          elsif text_part.match(/doc/)
            result[:opinion_urls]["doc"] = possible_link
          else
            unknown_type = text_part.downcase.gsub("","").gsub("","").strip_both_ends
            result[:opinion_urls]["#{unknown_type}"] = link["href"]
          end # if/thens of opinion types
        end # link/opinion loop

        # within the opinion set
        # N.B., this also contains information about dissent/memorandum/etc.
        if t.search("div").search("td").first
          result[:author_string] = t.search("div").search("td").first.inner_text
        end

        # other <TD> elements
        # last one is the panel
        # penultimate is the disposition
        # antepenultimate is the case style--origin

        result[:panel_string] = t.search("td")[-1].to_html.split(/[<>]/).select { |x| x.match(/Ju[ds]/) }.join(",").gsub("  "," ")
        result[:disposition] = t.search("td")[-2].inner_text.downcase.strip_both_ends.gsub(/:$/,"")

        source = t.search("td")[-3].inner_text
        parts = source.split("--")
        if parts.size == 2
          result[:case_style] = parts.first.strip_both_ends
          result[:origin] = parts.second.strip_both_ends
        elsif parts.size == 1
          fallback = t.search("td/span").first
          # Added 2013-06-07 to deal with new formats of COA3, with bolded text
          if fallback and fallback.inner_text[0,10] == parts.first[0,10]
            result[:case_style] = fallback.inner_text.strip_both_ends
            if result[:case_style] != parts.first.strip_both_ends
              fallback_origin = parts.first.strip_both_ends
              fallback_origin.slice!(result[:case_style])
              result[:origin] = fallback_origin.strip_both_ends if fallback_origin and fallback_origin.size > 0 
            end
          else
            result[:case_style] = parts.first.strip_both_ends
          end
        end
        # ensuring enough info to salvage if I need to
        #next if result[:docket_no].nil? or result[:docket_page_url].nil?
        #next if result[:docket_no].blank? or result[:docket_page_url].blank?
        results << result
      end
      results
    end # returns an array of opinion_metadata hashes

    def self.date_from_oddball(date_string)
      return Nil unless date_string.match(/\d\d\/\d\d\/\d\d\d\d/)
      parts = date_string.split("/")
      whole = parts[1] + "-" + parts[0] + "-" + parts[2]
      whole.to_date
    end

  end
end

