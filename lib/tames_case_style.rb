# encoding: utf-8
module CoaOpScraper
  module Tames
    class TamesCaseStyle

      # passing in a Nokogiri <TR> object
      def initialize(target_row, force_new_format=nil)
        @target = target_row
        @new_format = force_new_format
      end
      
      def case_style
        if new_format?
          text_within_span
        else
          split_into_parts.first.strip_both_ends
        end
      end

      def case_origin
        if new_format?
          text_outside_of_span
        else
          split_into_parts.second.strip_both_ends
        end
      end

      protected

      def right_cell
        @target.search("td")[-3]
      end

      def parts_divider
        "--"
      end

      def split_into_parts
        to_s.split(parts_divider)
      end

      def to_s
        right_cell.inner_text.strip_both_ends
      end

      def text_within_span
        @target.search("td/span").first.inner_text.strip_both_ends
      end

      def overall_text
        to_s
      end

      def text_outside_of_span
        possible_match = overall_text.match(/#{text_within_span}(.*)/)
        capture = possible_match.captures.first
        capture.strip_both_ends if capture and capture.strip_both_ends.size > 0
      end # might return nil

      # <td><span>Party Name v. Other Party</span> Court name where from</td>
      def new_format? 
        @new_format ||= (not_divided_by_punctuation and
                         begins_with_spanned_text)
      end

      def begins_with_spanned_text
        text_within_span[0,7] == overall_text[0,7]
      end

      def isnt_only_spanned_text
        text_within_span != overall_text
      end

      def not_divided_by_punctuation
        split_into_parts.size == 1
      end

    end
  end
end
# needs String#strip_both_ends
