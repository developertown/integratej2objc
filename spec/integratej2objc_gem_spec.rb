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

	it "should not fail if test_temp doesn't exist." do
		clean_test_temp

		clean_test_temp
	end

	it "should create a file at the given path" do
		file = path_relative_to_test_temp(File.join("asdf", "magicFile.txt"))
		touch_file(file)
		expect(File.exists?(file)).to be_truthy
	end
end


describe IntegrateJ2objc::J2ObjcSharedLibSmanger do  

	before :each do
		clean_test_temp
		prepare_xcodeproject_for_test
		@smanger = IntegrateJ2objc::J2ObjcSharedLibSmanger.new()
		@generated_root = File.join("IntegrateJ2Objc_Test_Project","generated")
	end

	it "works exactly like before these infernal tests" do
		@generated_files_dir = path_relative_to_test_temp(@generated_root)
		@old_generated_files = Dir.entries(@generated_root).map
		@new_generated_files = create_random_generated_files				
		integrate_generated_files
		old_files_should_not_be_in_group
		generated_files_should_be_in_correct_group
		generated_files_should_be_in_target
	end

	it "should fill generated directory with only our generated files" do
		expect(fixture_path(@generated_root)).to have_same_files_as(path_relative_to_test_temp(@generated_root))
		files = create_random_generated_files		
		expect(path_relative_to_test_temp(@generated_root)).to contain_only_files(files)
	end

	def prepare_xcodeproject_for_test
		@path_for_xcode_project = cp_fixture_to_test_temp("integrateJ2Objc_Test_Project")
	end

	def prepare_generated_files_for_test
		@new_source_files = create_random_generated_files
	end

	def integrate_generated_files
		fail("not implemented")
	end

	def old_files_should_not_be_in_group
		fail("not implemented")
	end

	def generated_files_should_be_in_correct_group
		fail("not implemented")
	end

	def generated_files_should_be_in_target
		fail("not implemented")
	end

	def create_random_generated_files(class_count=4)		
		FileUtils.remove_dir(path_relative_to_test_temp(@generated_root), true)
		
		generated_files = []
		class_count.times do 
			f = random_string
			generated_files << path_relative_to_test_temp(File.join(@generated_root,"#{f}.h"))
			generated_files << path_relative_to_test_temp(File.join(@generated_root,"#{f}.m"))
		end

		generated_files.each { |f| touch_file(f) }

		generated_files
	end
end

RSpec::Matchers.define :have_same_files_as do |dir|
	match do |test_dir|
		expect(Dir.entries(test_dir)).to eql(Dir.entries(dir))
	end
end


RSpec::Matchers.define :contain_only_files do |files|
	match do |dir|
		diff  = Dir.entries(dir).reject do |e| 
			e.match(/(\.)|(\.\.)/) || files.any?{|f| f.ends_with(e)}			
		end
		expect(diff.length).to eql(0)
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
