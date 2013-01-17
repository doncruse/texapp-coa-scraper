require 'spec_helper'

describe "LegacyScraper" do

  describe "Fairly recent Third Court page" do

		before(:all) do
			@coa = "03"
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
			@data_array.count.should eq(5)
		end

		it "items should not be empty hashes" do
			@data_array.first.keys.should_not be_empty
		end

		it "should see entry for 03-12-00177-CV" do
			dno = "03-12-00177-CV"
			@data_array.select { |x| x[:docket_no] == dno }.count.should_not eq(0)
		end

		it "should see entry for 03-11-00836-CR (Abated with opinion)" do
			dno = "03-11-00836-CR"
			@data_array.select { |x| x[:docket_no] == dno }.count.should_not eq(0)
		end

		it "should see full data for 03-12-00759-CV" do
			dno = "03-12-00759-CV"
			targets = @data_array.select { |x| x[:docket_no] == dno }
			targets.count.should eq(1)
			target = targets.first
			target[:author_string].should eq("Opinion by Justice Puryear")
			target[:release_date].should eq(@date)
			target[:panel_string].should eq("(Before Justices Puryear, Pemberton and Rose)")
			target[:case_style].should eq("In re Carol Gino")
			target[:origin].should eq("Appeal from 335th District Court of Bastrop County")
			target[:disposition].downcase.should eq("motion or writ denied:")
			target[:docket_page_url].should eq("/opinions/case.asp?FilingID=17581")
			target[:opinion_urls].should_not be_empty
			target[:opinion_urls]["html"].should eq("/opinions/htmlopinion.asp?OpinionId=21723")
			target[:opinion_urls]["pdf"].should eq("/opinions/PDFOpinion.asp?OpinionId=21723")
			target[:opinion_urls].count.should eq(2)
		end
	end
		
	# http://www.2ndcoa.courts.state.tx.us/opinions/docket.asp?FullDate=20030220
	describe "Older Second Court page" do

		before(:all) do
			@coa = "02"
			@date = "2003-02-20".to_date
			VCR.use_cassette "legacy/#{@coa}-#{@date.to_s}" do
				@doc = CoaOpScraper.retrieve_list_for_coa_for_date(@coa,@date)
			end
			@data_array = CoaOpScraper::Legacy.parse_opinion_list(@doc)
		end

		it "should retrieve something" do
			@doc.should_not be_nil
		end

		it "should retrieve right number of items" do
			@data_array.count.should eq(28)
		end

		it "items should not be empty hashes" do
			@data_array.first.keys.should_not be_empty
		end

		it "should see entry for 02-01-00399-CR" do
			dno = "02-01-00399-CR"
			@data_array.select { |x| x[:docket_no] == dno }.count.should_not eq(0)
		end

		it "should see entry for 02-02-00248-CV (complex authorship credit)" do
			dno = "02-02-00248-CV"
			@data_array.select { |x| x[:docket_no] == dno }.count.should_not eq(0)
		end

		it "should see full data for 02-01-00385-CV" do
			dno = "02-01-00385-CV"
			targets = @data_array.select { |x| x[:docket_no] == dno }
			targets.count.should eq(1)
			target = targets.first
			target[:author_string].should eq("Opinion by Chief Justice Cayce")
			target[:release_date].should eq(@date)
			target[:panel_string].should eq("(Before Chief Justice Cayce, Justices Day and Gardner)")
			target[:case_style].should eq("Millennium Properties & Development, Inc. d/b/a Millennium Home Builders v. Dyana M. Lee")
			target[:origin].should eq("Appeal from 393rd District Court of Denton County")
			target[:disposition].downcase.should eq("affirmed:")
			target[:docket_page_url].should eq("/opinions/case.asp?FilingID=15916")
			target[:opinion_urls].should_not be_empty
			target[:opinion_urls].count.should eq(1)
			target[:opinion_urls]["html"].should eq("/opinions/htmlopinion.asp?OpinionId=14367")
		end
	end
		
		
end
