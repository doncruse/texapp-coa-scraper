require 'spec_helper'

# The statewide Fifteenth Court of Appeals (coa15) came online in Sept 2024
# and publishes on the same TAMES docket system as the regional courts.
# https://search.txcourts.gov/Docket.aspx?coa=coa15&FullDate=06/30/2026
describe "Fifteenth Court of Appeals (TAMES)" do
  before(:all) do
    @coa  = "15"
    @date = "2026-06-30".to_date
    VCR.use_cassette "tames/#{@coa}-#{@date}" do
      @doc = CoaOpScraper.retrieve_list_for_coa_for_date(@coa, @date)
    end
    @data_array = CoaOpScraper::Tames.parse_opinion_list(@doc, @coa)
  end

  it "retrieves the page" do
    expect(@doc).not_to be_nil
  end

  it "parses every row in the list" do
    expect(@data_array.count).to eq(6)
  end

  describe "the 15-25-00164-CV row" do
    let(:target) do
      rows = @data_array.select { |r| r[:docket_no] == "15-25-00164-CV" }
      expect(rows.count).to eq(1)
      rows.first
    end

    it "captures the case style and origin" do
      expect(target[:case_style]).to eq("Interra Credit Union v. Enrique Figueroa Laboy")
      expect(target[:origin]).to eq("Appeal from 395th District Court of Williamson County")
    end

    it "captures the disposition and release date" do
      expect(target[:disposition]).to eq("reversed and remanded")
      expect(target[:release_date]).to eq(@date)
    end

    it "captures the authoring justice and the full panel (whitespace normalized)" do
      expect(target[:author_string]).to eq("Memorandum Opinion by Justice Farris")
      expect(target[:panel_string]).to eq("Chief Justice Brister,Justice Field,Justice Farris")
    end

    it "captures the docket page link" do
      expect(target[:docket_page_url]).to eq("Case.aspx?cn=15-25-00164-CV")
    end

    it "captures the opinion PDF, rewriting the unevaluated coa= placeholder" do
      pdf = target[:opinion_urls]["pdf"]
      expect(pdf).to eq("SearchMedia.aspx?MediaVersionID=fedbe1e1-858d-4f4e-9789-a5c9c72e06b8&MediaID=d5a912a7-6501-4e41-857a-edbda875f195&coa=coa15&DT=Opinion")
      # The raw href carries a literal JS template in the coa= param; TamesLink
      # must rewrite it to the real court number rather than leave it in.
      expect(pdf).to include("coa=coa15")
      expect(pdf).not_to include("CurrentWebState")
    end
  end
end
