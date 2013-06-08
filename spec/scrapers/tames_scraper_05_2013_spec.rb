require 'spec_helper'

# Problem is that the orders list format has changed. Now shows both "civil opinions" and "civil orders",
# as well as "criminal opinions" and "criminal orders".  Change was noted on 6-8-2013.

describe "Tames format has evolved by June 2013" do

  describe "New example of a Third Court page" do

		before(:all) do
			@coa = "03"
			@date = "2013-06-07".to_date
			VCR.use_cassette "tames/#{@coa}-#{@date.to_s}" do
				@doc = CoaOpScraper.retrieve_list_for_coa_for_date(@coa,@date)
			end
			@data_array = CoaOpScraper::Tames.parse_opinion_list(@doc,@coa)
		end

		it "should retrieve something" do
			@doc.should_not be_nil
		end

		it "should retrieve right number of items" do
			@data_array.count.should eq(12)
		end

		it "should see entry for dno" do
		dno = "03-12-00504-CV"
			@data_array.select { |x| x[:docket_no] == dno }.count.should_not eq(0)
		end

    # problem: this is an order, not an opinion -> Q/ fit into project
		it "should see entry for dno" do
			dno = "03-13-00290-CV"
			@data_array.select { |x| x[:docket_no] == dno }.count.should_not eq(0)
      @data_array.select { |x| x[:docket_no] == dno }.first[:disposition].should eq("ordered")
		end

    # this is a criminal case, down an extra set of boxes now because of civil orders
		it "should see entry for dno" do
			dno = "03-13-00353-CR"
			@data_array.select { |x| x[:docket_no] == dno }.count.should_not eq(0)
		end

    # missing PDF here for the opinion, as of the next day
    # this is a problem at the court level, which should be flagged
		it "should see entry for dno - which has no published PDF?" do
			dno = "03-12-00546-CV"
			@data_array.select { |x| x[:docket_no] == dno }.count.should_not eq(0)
			@data_array.select { |x| x[:docket_no] == dno }.first[:opinion_urls].should be_empty
		end

		it "should see full data for 03-12-00843-CV" do
			dno = "03-12-00843-CV"
			targets = @data_array.select { |x| x[:docket_no] == dno }
			targets.count.should eq(1)
			target = targets.first
			target[:author_string].should eq("Memorandum Opinion by Chief Justice Jones")
			target[:panel_string].should eq("Chief Justice Jones,Justice Goodwin,Justice Field")
			target[:origin].should eq("Appeal from County Court at Law No. 1 of Travis County")
			target[:case_style].should eq("AZ & Associates, L.P. d/b/a Red Robin v. Amstar Engineering, Inc.")
			target[:disposition].downcase.should eq("dismissed on appellant's motion")
			target[:docket_page_url].should eq("Case.aspx?cn=#{dno}")
			target[:opinion_urls].should_not be_empty
			target[:opinion_urls].count.should eq(1)
			target[:opinion_urls]["pdf"].should eq("SearchMedia.aspx?MediaVersionID=0c05922e-d8ec-4483-a616-bf9a3f5c2cfb&MediaID=90bceb92-7e39-4425-a4fa-04f9a8ab0cf5&coa=coa03&DT=Opinion")
		end
		
	end		
	
end
