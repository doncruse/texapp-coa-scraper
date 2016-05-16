# encoding=utf-8
require 'nokogiri'
require 'open-uri'
require 'date'
require 'active_support'
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

      raw_release_date = data.search(".panel-heading").search("span").first.inner_text
      release_date = self.date_from_oddball(raw_release_date.strip_both_ends)

      results = []
      targets.each do |t|
        result = Hash.new
        result[:release_date] = release_date
        result[:opinion_urls] = {}
        t.search("a").each do |l|
          link = TamesLink.new(l, coa_number)
          if link.is_docket_link?
            result[:docket_no] = link.docket_no
            result[:docket_page_url] = link.docket_page_url
            next
          end
          if link.is_opinion_link?
            result[:opinion_urls][link.document_type] = link.link_target
          end
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

        tames_style = TamesCaseStyle.new(t)
        result[:case_style] = tames_style.case_style
        result[:origin] = tames_style.case_origin if tames_style.case_origin

        results << result
      end
      results
    end # returns an array of opinion_metadata hashes

    def self.date_from_oddball(date_string)
      return Nil unless date_string.match(/(\d{1,2}\/\d{1,2}\/\d\d\d\d)/)
      parts = $1.split("/")
      whole = parts[2] + "-" + parts[0] + "-" + parts[1]
      whole.to_date
    end

  end
end

