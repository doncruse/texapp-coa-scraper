require 'spec_helper'

describe "LegacyScraper" do
  # down to just one COA, the Thirteenth Court.

  describe "Thirteenth Court page" do
=begin

		before(:all) do
			@coa = "13"
			@date = "2013-01-10".to_date
			VCR.use_cassette "legacy/#{@coa}-#{@date.to_s}" do
				@doc = CoaOpScraper.retrieve_list_for_coa_for_date(@coa,@date)
			end
			@data_array = CoaOpScraper::Legacy.parse_opinion_list(@doc)
		end

		it "should retrieve something" do
			@doc.should_not be_nil
		end

		it "should retrieve right number of items" do
			@data_array.count.should eq(13)
		end

		it "items should not be empty hashes" do
			@data_array.first.keys.should_not be_empty
		end

		it "should see entry for 13-12-00530-CV" do
			dno = "13-12-00530-CV"
			@data_array.select { |x| x[:docket_no] == dno }.count.should_not eq(0)
		end

		it "should see entry for 13-12-00616-CR (Dismissed with opinion)" do
			dno = "13-12-00616-CR"
			@data_array.select { |x| x[:docket_no] == dno }.count.should_not eq(0)
		end

		it "should see full data for 13-12-00507-CV" do
			dno = "13-12-00507-CV"
			targets = @data_array.select { |x| x[:docket_no] == dno }
			targets.count.should eq(1)
			target = targets.first
			target[:author_string].should eq("Per Curiam")
			target[:release_date].should eq(@date)
			target[:panel_string].should eq("(Before Justices Rodriguez, Garza and Perkes)")
			target[:case_style].upcase.should eq("RAYMOND HOLTON, TERESA WALLIS AND ALL OCCUPANTS V. GREEN TREE SERVICING LLC, SUCCESSOR BY MERGER TO WALTER MORTGAGE COMPANY, LLC")
			target[:origin].should eq("Appeal from County Court at Law of San Patricio County")
			target[:disposition].downcase.should eq("dismissed as moot:")
			target[:docket_page_url].should eq("/opinions/case.asp?FilingID=20786")
			target[:opinion_urls].should_not be_empty
			target[:opinion_urls]["html"].should eq("/opinions/htmlopinion.asp?OpinionId=20649")
			target[:opinion_urls]["pdf"].should eq("/opinions/PDFOpinion.asp?OpinionId=20649")
			target[:opinion_urls].count.should eq(2)
		end
=end
	end
end
