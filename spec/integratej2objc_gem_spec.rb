require 'spec_helper'

describe "spec helper" do
	before :each do
		@fixture = cp_fixture_to_test_temp("test_fixture.txt")
	end
	
	it "should do the right thing with copying a fixture" do		
		expect(@fixture).to be_a_file_at_path_containing_text("test_temp/test_fixture.txt", "A File!")
	end

	it "should remove test temp directory entirely" do
	 	clean_test_temp
	 	expect(test_temp).to no_longer_exist
	end
end


describe IntegrateJ2objc::J2ObjcSharedLibSmanger do  

	before :each do
		clean_test_temp
	end

	it "it works exactly like before these infernal tests" do
		
	end


end

RSpec::Matchers.define :no_longer_exist do 
	match do |file|
		expect(File.exists?(file)).to be_falsey
	end
end

RSpec::Matchers.define :be_a_file_at_path_containing_text do |path, text|
	match do |file|
		expect(file).to(end_with(path)) &&
		expect(File.exists?(file)).to(be_truthy) &&
		expect(File.read(file)).to(eql(text))
	end
end
