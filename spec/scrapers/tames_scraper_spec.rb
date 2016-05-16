require 'spec_helper'

describe "TamesScraper" do

  describe "Fairly recent First Court page" do

		before(:all) do
			@coa = "01"
			@date = "2012-01-19".to_date
			VCR.use_cassette "tames/#{@coa}-#{@date.to_s}" do
				@doc = CoaOpScraper.retrieve_list_for_coa_for_date(@coa,@date)
			end
			@data_array = CoaOpScraper::Tames.parse_opinion_list(@doc, @coa)
		end

		it "should retrieve something" do
			@doc.should_not be_nil
		end

		it "should retrieve all items" do
			@data_array.count.should eq(31)
		end

		it "should see entry for dno" do
		dno = "01-10-00113-CV"
			@data_array.select { |x| x[:docket_no] == dno }.count.should_not eq(0)
		end

		it "should see entry for dno" do
			dno = "01-10-00113-CV"
			@data_array.select { |x| x[:docket_no] == dno }.count.should_not eq(0)
		end

		it "should handle entry showing opinion withdrawn" do
			dno = "01-09-00728-CV"
			targets = @data_array.select { |x| x[:docket_no] == dno }
			targets.count.should eq(2)
			target = targets.first
			target[:disposition].should eq("WITHDRAW THIS COURT'S OPINION".downcase)
		end
		
		it "should see full data for 01-10-00585-CV" do
			dno = "01-10-00585-CV"
			targets = @data_array.select { |x| x[:docket_no] == dno }
			targets.count.should eq(1)
			target = targets.first
			target[:author_string].should eq("Memorandum Opinion by Justice Brown")
			target[:panel_string].should eq("Chief Justice Radack,Justice Higley,Justice Brown")
			target[:case_style].should eq("Demetrio Pena Rivas v. Maria Ofelia Rivas")
			target[:origin].should eq("Appeal from 308th District Court of Harris County")
			target[:disposition].downcase.should eq("affirm tc judgment")
			target[:docket_page_url].should eq("Case.aspx?cn=01-10-00585-CV")
			target[:opinion_urls].should_not be_empty
			target[:opinion_urls].count.should eq(2)
			target[:opinion_urls]["html"].should eq("SearchMedia.aspx?MediaVersionID=da12be7f-f1ae-4af8-a985-5969c712cfdb&MediaID=b1d07970-0289-49f3-8101-862a1c36caec&coa=coa01&DT=Opinion")
			target[:opinion_urls]["pdf"].should eq("SearchMedia.aspx?MediaVersionID=bbfc4937-f209-45a6-b8f7-ff44904c5dda&MediaID=ce1fd90e-aade-434c-a80d-11b39ca3677b&coa=coa01&DT=Other")
		end
		
		it "should see all three opinions for 01-10-00113-CV" do
			dno = "01-10-00113-CV"
			targets = @data_array.select { |x| x[:docket_no] == dno }
			targets.count.should eq(3)
		end
	end		
	
	describe "Older orders list with a visiting judge" do	
	# http://www.search.txcourts.gov/Docket.aspx?coa=coa14&FullDate=01/20/2005
	# should see that one of the panels includes a "Judge" not a Justice
	# 14-03-01241-CR
	
		before(:all) do
			@coa = "14"
			@date = "2005-01-20".to_date
			VCR.use_cassette "tames/#{@coa}-#{@date.to_s}" do
				@doc = CoaOpScraper.retrieve_list_for_coa_for_date(@coa,@date)
			end
			@data_array = CoaOpScraper::Tames.parse_opinion_list(@doc, @coa)
		end
	
		it "should handle entry showing opinion withdrawn" do
			dno = "14-03-01241-CR"
			targets = @data_array.select { |x| x[:docket_no] == dno }
			targets.count.should eq(1)
			target = targets.first
			target[:panel_string].should match(/Hudson/)
			target[:panel_string].should match(/Frost/)
			target[:panel_string].should match(/Anderson/)
		end

	end

	describe "Only criminal, no civil" do
	# http://www.search.txcourts.gov/Docket.aspx?coa=coa12&FullDate=01/31/2003

		before(:all) do
			@coa = "12"
			@date = "2003-01-31".to_date
			VCR.use_cassette "tames/#{@coa}-#{@date.to_s}" do
				@doc = CoaOpScraper.retrieve_list_for_coa_for_date(@coa,@date)
			end
			@data_array = CoaOpScraper::Tames.parse_opinion_list(@doc, @coa)
		end
	
		it "should handle entry showing opinion withdrawn" do
			@data_array.count.should eq(1)
		end
	
	end

end
