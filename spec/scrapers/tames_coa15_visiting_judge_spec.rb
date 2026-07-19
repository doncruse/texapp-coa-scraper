require 'spec_helper'

# Fifteenth Court of Appeals, 2026-07-09.
# https://search.txcourts.gov/Docket.aspx?coa=coa15&FullDate=07/09/2026
#
# This date was recorded specifically because it contains two row shapes that
# no other cassette in this suite covers:
#
#   1. A panel that includes a judge sitting by assignment, styled by the court
#      as "The Honorable Rose" rather than "Justice Rose". The panel parser
#      keeps only tokens matching /Ju[ds]/, so this member is silently dropped
#      and a three-member panel is reported as two. See the pending example.
#
#   2. An Order row rather than an opinion row. Note its media URL ends in
#      DT=Order, where opinion rows end in DT=Opinion -- a more reliable
#      discriminator than sniffing the author string.
describe "Fifteenth Court of Appeals (TAMES), 2026-07-09" do
  before(:all) do
    @coa  = "15"
    @date = "2026-07-09".to_date
    VCR.use_cassette "tames/#{@coa}-#{@date}" do
      @doc = CoaOpScraper.retrieve_list_for_coa_for_date(@coa, @date)
    end
    @data_array = CoaOpScraper::Tames.parse_opinion_list(@doc, @coa)
  end

  it "parses every row in the list" do
    expect(@data_array.count).to eq(2)
  end

  describe "the 15-25-00033-CV row (panel includes an assigned judge)" do
    let(:target) do
      rows = @data_array.select { |r| r[:docket_no] == "15-25-00033-CV" }
      expect(rows.count).to eq(1)
      rows.first
    end

    it "captures the case style and origin" do
      expect(target[:case_style]).to eq("Edith Okechukwu Omietimi v. Texas Board of Nursing")
      expect(target[:origin]).to eq("Appeal from 419th District Court of Travis County")
    end

    it "captures the disposition, release date, and authoring justice" do
      expect(target[:disposition]).to eq("affirmed")
      expect(target[:release_date]).to eq(@date)
      expect(target[:author_string]).to eq("Memorandum Opinion by Justice Field")
    end

    it "captures the two panel members styled as Justices" do
      expect(target[:panel_string]).to include("Chief Justice Brister")
      expect(target[:panel_string]).to include("Justice Field")
    end

    it "captures the full three-member panel, including the assigned judge" do
      pending "panel filter in Tames.parse_opinion_list keeps only /Ju[ds]/ tokens, dropping 'The Honorable Rose'"
      # The court's markup for this row is:
      #   Chief Justice Brister <br>Justice Field <br>The Honorable Rose <br>
      # A judge sitting by assignment is styled "The Honorable X", so the
      # panel here is three members, not two.
      expect(target[:panel_string]).to eq("Chief Justice Brister,Justice Field,The Honorable Rose")
    end
  end

  describe "the 15-26-00093-CV row (an order, not an opinion)" do
    let(:target) do
      rows = @data_array.select { |r| r[:docket_no] == "15-26-00093-CV" }
      expect(rows.count).to eq(1)
      rows.first
    end

    it "reports 'Order' in place of an authoring justice" do
      expect(target[:author_string]).to eq("Order")
    end

    it "carries the order's disposition and full panel" do
      expect(target[:disposition]).to eq("case transferred to another coa")
      expect(target[:panel_string]).to eq("Chief Justice Brister,Justice Field,Justice Farris")
    end

    it "marks the document type as Order in the media URL" do
      # Opinion rows carry DT=Opinion here. Consumers that need to tell an
      # order from an opinion should prefer this over the author string.
      expect(target[:opinion_urls]["pdf"]).to include("DT=Order")
      expect(target[:opinion_urls]["pdf"]).not_to include("DT=Opinion")
    end
  end
end
