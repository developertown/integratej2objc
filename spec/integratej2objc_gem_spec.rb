require 'spec_helper'
require 'pry'
require 'pathname'

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
		@generated_files_dir = path_relative_to_test_temp(@generated_root)

		@project_root = path_relative_to_test_temp("IntegrateJ2Objc_Test_Project")
		@project = "IntegrateJ2Objc_Test_Project.xcodeproj"
		@source_root = "generated"
		@group = "IntegrateJ2Objc_Test_Project/generated"
		@target = "IntegrateJ2Objc_Test_Project"
	end

	it "works exactly like before these infernal tests" do		
		capture_old_generated_files
		prepare_generated_files_for_test
		old_files_should_be_in_group
		
		integrate_generated_files
		
		old_files_should_not_be_in_group
		old_files_should_not_be_in_target

		generated_files_should_be_in_correct_group
		generated_files_should_be_in_target
	end

	it "should fill generated directory with only our generated files" do
		expect(fixture_path(@generated_root)).to have_same_files_as(path_relative_to_test_temp(@generated_root))
		files = create_random_generated_files		
		expect(@generated_files_dir).to contain_only_files(files)
	end


	def prepare_xcodeproject_for_test
		@path_for_xcode_project = cp_fixture_to_test_temp("integrateJ2Objc_Test_Project")
	end

	def capture_old_generated_files		
		@old_generated_group_files = recursive_files_in_generated_files_dir		
	end

	def prepare_generated_files_for_test
		@new_generated_files = create_random_generated_files
	end

	def old_files_should_be_in_group
		files = files_in_xcodeproject_group
		expect(files).to eql(@old_generated_group_files)
	end

	def integrate_generated_files
		
	end

	def old_files_should_not_be_in_group
		files = files_in_xcodeproject_group
		expect(files).not_to eql(@old_generated_group_files)
	end

	def old_files_should_not_be_in_target
		files = generated_files_in_xcodeproject_target
		expect(files).no_to eql(old_generated_m_files)		
	end

	def generated_files_should_be_in_correct_group
		fail("not implemented")
	end

	def generated_files_should_be_in_target
		fail("not implemented")
	end

	def old_generated_m_files
		@old_generated_group_files.select{ |f| f.end_with? ".m" }		
	end

	def files_in_xcodeproject_group
		proj = Xcodeproj::Project.open File.join(@project_root, @project)
		group_hierarchy_path_name = Pathname.new(proj[@group].hierarchy_path)
		files = proj[@group].recursive_children.select do |o| 
			o.kind_of? Xcodeproj::Project::Object::PBXFileReference 
		end.map do |f|
			Pathname.new(f.hierarchy_path).relative_path_from(group_hierarchy_path_name).to_s
		end.sort
	end

	def generated_files_in_xcodeproject_target
		proj = Xcodeproj::Project.open File.join(@project_root, @project)
		group_hierarchy_path_name = Pathname.new(proj[@group].hierarchy_path)
		target = proj.targets.select{ |t| t.name.eql?(@target)}.first

		generated_target_files = target.source_build_phase.files_references.map do |f| 
			f.hierarchy_path 
		end.select do |f| 
			f.start_with?("/IntegrateJ2Objc_Test_Project/generated/")
		end.map do |f|
			Pathname.new(f).relative_path_from(group_hierarchy_path_name).to_s
		end.sort		
	end
	
	def recursive_files_in_generated_files_dir
		generated_files_dir_pathname = Pathname.new(@generated_files_dir)
		Dir.glob("#{@generated_files_dir}/**/*").select{|f| !File.directory?(f) }.map do |f|
			Pathname.new(f).relative_path_from(generated_files_dir_pathname).to_s
		end.sort
	end

	def create_random_generated_files(class_count=4)		
		FileUtils.remove_dir(path_relative_to_test_temp(@generated_root), true)
		
		generated_files = []
		class_count.times do 
			f = random_string
			generated_files << path_relative_to_test_temp(File.join(@generated_root,"#{f}.h"))
			generated_files << path_relative_to_test_temp(File.join(@generated_root,"#{f}.m"))
		end

		sub_name = random_string
		sub_path = path_relative_to_test_temp(File.join(@generated_root, sub_name))
		FileUtils.mkdir_p sub_path

		class_count.times do
			f = random_string
			generated_files << File.join(sub_path, "#{f}.h")
			generated_files << File.join(sub_path, "#{f}.m")			
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
