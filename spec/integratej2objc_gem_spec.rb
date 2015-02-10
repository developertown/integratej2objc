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

		@project_path = File.join(@project_root, @project)

		@source_root = "generated"
		@group = "IntegrateJ2Objc_Test_Project/generated"
		@target = "IntegrateJ2Objc_Test_Project"
	end

	it "should fill generated directory with only our generated files" do
		expect(fixture_path(@generated_root)).to have_same_files_as(path_relative_to_test_temp(@generated_root))
		files = create_random_generated_files		
		expect(@generated_files_dir).to contain_only_files(files)
	end

	it "should remove old group and files from project" do
		project = Xcodeproj::Project.open(@project_path)
		@smanger.remove_old_group_and_files(@group, project)

		expect(project).not_to have_group_named(@group)
	end

	it "should create new group in project in appropriate sub group" do
		project = Xcodeproj::Project.open(@project_path)
		prepare_generated_files_for_test
		@smanger.recreate_group_at_root("group1/group2/group3", @project_root, @source_root, project)
		expect("group1/group2/group3").to be_child_of_group("group1/group2", project)
	end

	RSpec::Matchers.define :be_child_of_group do |parent_group, project|
		match do |group|
			group_obj = project[group]
			parent_obj = project[parent_group]
			expect(group_obj.parent).to eql(parent_obj)
		end
	end

	it "should have correct files in new group" do
		project = Xcodeproj::Project.open(@project_path)
		prepare_generated_files_for_test
		@smanger.recreate_group_at_root("group1/group2/group3", @project_root, @source_root, project)
		expect(@new_generated_files).to match_files_in_project_group(project, "group1/group2/group3")
	end
	
	RSpec::Matchers.define :match_files_in_project_group do |project, group|
		match do |files|
							
			group_actual_files = project[group].recursive_children.select do |o| 
				o.kind_of? Xcodeproj::Project::Object::PBXFileReference 
			end.map do |f|
				f.hierarchy_path
			end

			group_actual_files = file_paths_relative_to_path(group_actual_files, project[group].hierarchy_path)

			expect(group_actual_files).to eql(files)
		end
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
		@smanger.integrate_source(project_root: @project_root,
			xcodeproj: @project,
			source_root: @source_root,
			group:@group,
			target:@target)
	end

	def old_files_should_not_be_in_group
		files = files_in_xcodeproject_group
		expect(files).not_to eql(@old_generated_group_files)
	end

	def old_files_should_not_be_in_target
		files = generated_files_in_xcodeproject_target
		expect(files).not_to eql(old_generated_m_files)		
	end

	def generated_files_should_be_in_correct_group
		files = files_in_xcodeproject_group
		expect(files).to eql(@new_generated_files)		
	end

	def generated_files_should_be_in_target
		files = generated_files_in_xcodeproject_target
		expect(files).to eql(new_generated_m_files)
	end

	def old_generated_m_files
		@old_generated_group_files.select{ |f| f.end_with? ".m" }		
	end

	def new_generated_m_files
		@new_generated_files.select { |f| f.end_with? ".m" }
	end

	def files_in_xcodeproject_group
		proj = Xcodeproj::Project.open File.join(@project_root, @project)
		
		files = proj[@group].recursive_children.select do |o| 
			o.kind_of? Xcodeproj::Project::Object::PBXFileReference 
		end.map do |f|
			f.hierarchy_path
		end

		file_paths_relative_to_path(files, proj[@group].hierarchy_path)
	end

	def generated_files_in_xcodeproject_target
		proj = Xcodeproj::Project.open File.join(@project_root, @project)
		
		target = proj.targets.select{ |t| t.name.eql?(@target)}.first

		generated_target_files = target.source_build_phase.files_references.map do |f| 
			f.hierarchy_path 
		end.select do |f| 
			f.start_with?("/#{@group}")
		end

		file_paths_relative_to_path(generated_target_files, proj[@group].hierarchy_path)
	end
	
	def recursive_files_in_generated_files_dir		
		files = all_files_in_directory @generated_files_dir
		file_paths_relative_to_path(files, @generated_files_dir)
	end

	def create_random_generated_files(class_count=4)
		root_count = (class_count / 2).to_i
		FileUtils.remove_dir(@generated_files_dir, true)		
		generated_files = []
		
		generated_files += generate_random_files_at_path(root_count, @generated_files_dir)

		sub_name = random_string
		sub_path = File.join(@generated_files_dir, sub_name)		
		FileUtils.mkdir_p sub_path

		generated_files += generate_random_files_at_path(class_count - root_count, sub_path)

		generated_files.each { |f| touch_file(f) }
		file_paths_relative_to_path(generated_files, @generated_files_dir)
	end

	def generate_random_files_at_path(num_files, path)
		generated_files = []
		num_files.times do 
			f = random_string
			generated_files << File.join(path,"#{f}.h")
			generated_files << File.join(path,"#{f}.m")
		end
		generated_files
	end
end

RSpec::Matchers.define :have_group_named do |group|
	match do |project|
		expect(project[group]).not_to be_nil
	end
end

RSpec::Matchers.define :have_same_files_as do |dir|
	match do |test_dir|
		test_dir_entries = file_paths_relative_to_path(Dir.glob("#{test_dir}/**/*"), test_dir)
		dir_entries = file_paths_relative_to_path(Dir.glob("#{dir}/**/*"), dir)

		expect(test_dir_entries).to eql(dir_entries)
	end
end

RSpec::Matchers.define :contain_only_files do |files|
	match do |dir|
		actual_files = file_paths_relative_to_path(all_files_in_directory(dir), dir)
		expect(actual_files).to eql(files)
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
