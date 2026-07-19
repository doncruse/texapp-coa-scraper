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
        # The origin is whatever cell text follows the style <span>. Slice the
        # span text off literally rather than interpolating it into a Regexp:
        # arbitrary style text breaks the match on regex-special characters in
        # long/complex names (e.g. an 878-char style with parentheses/brackets),
        # where .match returns nil and .captures then raises. new_format? already
        # guarantees the cell begins with the span text.
        return nil unless overall_text.start_with?(text_within_span)
        capture = overall_text[text_within_span.length..].to_s.strip_both_ends
        capture if capture.size > 0
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
