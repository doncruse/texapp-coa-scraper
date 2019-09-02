require 'spec_helper'

describe "Courts moved from legacy to Tames" do

  describe "Fairly recent Third Court page" do

		before(:all) do
			@coa = "03"
			@date = "2013-01-10".to_date
			VCR.use_cassette "tames/#{@coa}-#{@date.to_s}" do
				@doc = CoaOpScraper.retrieve_list_for_coa_for_date(@coa,@date)
			end
			@data_array = CoaOpScraper::Tames.parse_opinion_list(@doc,@coa)
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
			target[:author_string].should eq("Memorandum Opinion by Justice Puryear")
			target[:release_date].should eq(@date)
			target[:panel_string].should match(/Justice Puryear/)
			target[:panel_string].should match(/Justice Pemberton/)
			target[:panel_string].should match(/Justice Rose/)
			target[:case_style].should eq("In re Carol Gino")
			target[:origin].should eq("Appeal from 335th District Court of Bastrop County")
			target[:disposition].downcase.should eq("motion or writ denied")
			target[:docket_page_url].should eq("Case.aspx?cn=#{dno}")
			target[:opinion_urls].should_not be_empty
			target[:opinion_urls]["html"].should eq("SearchMedia.aspx?MediaVersionID=a9f5022b-84bd-448f-8774-0f400ef8b95c&MediaID=b7a87b05-7aae-4e36-873f-5563accbf383&coa=coa03&DT=Opinion")
			target[:opinion_urls]["pdf"].should eq("SearchMedia.aspx?MediaVersionID=99422161-2e20-49b0-a117-07b032c5101b&MediaID=1a202f35-7165-4afe-821d-dadad6abc641&coa=coa03&DT=Opinion")
			target[:opinion_urls].count.should eq(2)
		end
	end
		
	# http://www.2ndcoa.courts.state.tx.us/opinions/docket.asp?FullDate=20030220
	describe "Older Second Court page" do

		before(:all) do
			@coa = "02"
			@date = "2003-02-20".to_date
			VCR.use_cassette "tames/#{@coa}-#{@date.to_s}" do
				@doc = CoaOpScraper.retrieve_list_for_coa_for_date(@coa,@date)
			end
			@data_array = CoaOpScraper::Tames.parse_opinion_list(@doc,@coa)
		end

		it "should retrieve something" do
			@doc.should_not be_nil
		end

		it "should retrieve right number of items" do
			@data_array.count.should eq(30)
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
			target[:author_string].should eq("Memorandum Opinion by Chief Justice Cayce")
			target[:release_date].should eq(@date)
			target[:panel_string].should eq("Chief Justice Cayce,Justice Day,Justice Gardner,Chief Justice Cayce")
      # Note: this is incorrect - only three Justices - but this is a "correct" scrape of the page
			target[:case_style].should eq("Millennium Properties & Development, Inc. d/b/a Millennium Home Builders v. Dyana M. Lee")
			target[:origin].should eq("Appeal from 393rd District Court of Denton County")
			target[:disposition].downcase.should eq("affirmed")
			target[:docket_page_url].should eq("Case.aspx?cn=#{dno}")
			target[:opinion_urls].should_not be_empty
			target[:opinion_urls].count.should eq(2)
			target[:opinion_urls]["html"].should eq("SearchMedia.aspx?MediaVersionID=902e2f87-66a2-4775-8e13-6a42337e762f&MediaID=24f69484-2581-4f22-89de-498a4d609014&coa=COA02&DT=Opinion")
		end
	end
		
		
end
