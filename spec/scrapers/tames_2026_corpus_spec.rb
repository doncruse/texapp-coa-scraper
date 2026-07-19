require 'spec_helper'

# Smoke coverage over the July 2026 cassettes recorded across all courts.
# Each page must parse without raising, and every page must be internally
# consistent with what was requested (a guard against the court site's
# occasional habit of serving a cached page for the wrong court/date).
describe "July 2026 TAMES corpus" do
  # coa => [date, expected_row_count]
  CASES = {
    "01" => ["2026-07-07", 22],
    "02" => ["2026-07-09", 17],
    "04" => ["2026-07-09", 22],  # orders only -- no opinions
    "05" => ["2026-07-15", 21],
    "06" => ["2026-07-10", 3],
    "07" => ["2026-07-14", 3],   # per curiams
    "08" => ["2026-07-07", 11],  # includes an 878-char case style
    "09" => ["2026-07-15", 2],   # criminal only
    "10" => ["2026-07-10", 1],
    "11" => ["2026-07-10", 13],
    "15" => ["2026-07-14", 2],   # majority + dissent cluster
  }

  CASES.each do |coa, (date_s, expected_count)|
    date = date_s.to_date

    describe "coa#{coa} on #{date_s}" do
      let(:rows) do
        doc = nil
        VCR.use_cassette("tames/#{coa}-#{date}") do
          doc = CoaOpScraper.retrieve_list_for_coa_for_date(coa, date)
        end
        CoaOpScraper::Tames.parse_opinion_list(doc, coa)
      end

      it "parses every row without raising" do
        expect(rows.count).to eq(expected_count)
      end

      it "returns only this court's dockets (identity guard)" do
        expect(rows.map { |r| r[:docket_no].to_s[0, 2] }.uniq).to eq([coa])
      end

      it "stamps every row with the requested release date (identity guard)" do
        expect(rows.map { |r| r[:release_date] }.uniq).to eq([date])
      end
    end
  end

  # Regression: an 878-character case style used to crash case-origin parsing,
  # because the style text was interpolated into a Regexp and failed to match.
  describe "coa08 long case style (08-25-00038-CV)" do
    let(:target) do
      doc = nil
      VCR.use_cassette("tames/08-2026-07-07") do
        doc = CoaOpScraper.retrieve_list_for_coa_for_date("08", "2026-07-07".to_date)
      end
      CoaOpScraper::Tames.parse_opinion_list(doc, "08").find { |r| r[:docket_no] == "08-25-00038-CV" }
    end

    it "captures the very long case style intact" do
      expect(target[:case_style].length).to be > 800
    end

    it "still recovers the origin that follows the style span" do
      expect(target[:origin]).to match(/\ACourt|\AAppeal|County/)
    end
  end
end
