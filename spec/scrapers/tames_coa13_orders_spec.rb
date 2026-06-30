require 'spec_helper'

# Characterization test: pins what the scraper does *today* with a docket page
# made up entirely of orders (not opinions on the merits).
# https://search.txcourts.gov/Docket.aspx?coa=coa13&FullDate=06/29/2026
#
# The 2016-era Tames parser has no concept of order-vs-opinion: it emits one
# hash per master-table row and files any PDF under the "pdf" key, regardless
# of whether the document is an opinion or an order. The only signals that a
# row is an order are author_string == "Order" and DT=Order inside the PDF URL.
# This spec documents that behavior so we notice if/when it changes.
describe "Thirteenth Court of Appeals orders list (TAMES)" do
  before(:all) do
    @coa  = "13"
    @date = "2026-06-29".to_date
    VCR.use_cassette "tames/#{@coa}-#{@date}" do
      @doc = CoaOpScraper.retrieve_list_for_coa_for_date(@coa, @date)
    end
    @data_array = CoaOpScraper::Tames.parse_opinion_list(@doc, @coa)
  end

  it "passes order rows through rather than filtering them out" do
    expect(@data_array.count).to eq(2)
    expect(@data_array.map { |r| r[:docket_no] }).to contain_exactly(
      "13-26-00153-CV", "13-26-00112-CR"
    )
  end

  it "treats every row as an order (no opinion-on-the-merits author/panel)" do
    @data_array.each do |row|
      expect(row[:author_string]).to match(/\AOrder\s*\z/)  # not "... Opinion by Justice X"
      expect(row[:panel_string]).to eq("")                  # orders list no panel here
    end
  end

  it "files the order PDF under the opinion 'pdf' key, carrying DT=Order" do
    @data_array.each do |row|
      expect(row[:opinion_urls].keys).to eq(["pdf"])
      expect(row[:opinion_urls]["pdf"]).to include("DT=Order")
      expect(row[:opinion_urls]["pdf"]).to include("coa=coa13")     # placeholder rewritten
      expect(row[:opinion_urls]["pdf"]).not_to include("CurrentWebState")
    end
  end

  describe "the 13-26-00153-CV row (order, no disposition shown)" do
    let(:order) { @data_array.find { |r| r[:docket_no] == "13-26-00153-CV" } }

    it "captures style, origin and docket link" do
      expect(order[:case_style]).to eq("In the Matter of the Marriage of Iris Cristina Joseph and Murphy Joseph III and in the Interest of P.R.J., a Child")
      expect(order[:origin]).to eq("Appeal from County Court at Law No 10 of Hidalgo County")
      expect(order[:docket_page_url]).to eq("Case.aspx?cn=13-26-00153-CV")
      expect(order[:release_date]).to eq(@date)
    end

    it "leaves disposition blank (none shown on the order row)" do
      expect(order[:disposition]).to eq("")
    end
  end

  describe "the 13-26-00112-CR row (abated)" do
    let(:order) { @data_array.find { |r| r[:docket_no] == "13-26-00112-CR" } }

    it "captures the disposition that is present" do
      expect(order[:disposition]).to eq("abated")
      expect(order[:case_style]).to eq("Emmett Barrera Jr. a/k/a Emmett Barrera v. The State of Texas")
      expect(order[:origin]).to eq("Appeal from 347th District Court of Nueces County")
    end
  end
end
