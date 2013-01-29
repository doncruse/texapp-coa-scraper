require 'spec_helper'

describe "Main Controller" do

	it "should know what a weekend is" do
		target_date = "2012-12-31".to_date # Monday
		target_date.weekday?.should eq(true)
		target_date = "2012-12-30".to_date # Sunday
		target_date.weekday?.should eq(false)
		target_date = "2012-12-29".to_date # Saturday
		target_date.weekday?.should eq(false)
	end

	it "should be able to access CoaDocketNo model" do
		d = CoaOpScraper::CoaDocketNo.new("3-4-24-CR")
		d.canonical.should eq("03-04-00024-CR")
	end
end
