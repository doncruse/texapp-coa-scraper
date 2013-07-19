# encoding: utf-8
module CoaOpScraper
  module Tames
    class TamesLink
      # object being passed is a nokogiri link
      def initialize(link, coa_number=nil)
        @link = link
        @coa_number = coa_number
      end

      def is_docket_link?
        @link.inner_text.match(/\d\d\d\d/)
      end

      def docket_no
        @link.inner_text if self.is_docket_link?
      end

      def docket_page_url
        @link["href"] if self.is_docket_link?
      end

      def is_opinion_link?
        link_target and document_type
      end

      def link_anchor
        @link.inner_text.downcase
      end

      def link_target
        if @coa_number
          @link["href"].gsub(/(?<=coa=).*CurrentWebState.*(?=&DT)/,"coa#{@coa_number.to_s}")
        else
          @link["href"]
        end
      end
      
      def document_type
        case link_anchor
        when /pdf/
          "pdf"
        when /htm/
          "html"
        when /wpd/
          "wpd"
        when /htm/
          "html"
        when /doc/
          "doc"
        else
          link_anchor.downcase.gsub("","").gsub("","").strip_both_ends
        end
      end

    end
  end
end
