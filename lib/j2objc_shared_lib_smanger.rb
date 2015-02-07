require 'xcodeproj'

module IntegrateJ2objc
	class J2ObjcSharedLibSmanger
		def integrate_source()
			project_root = options[:project_root]
			project = options[:xcodeproj]
			source_root = options[:source_root]
			group = options[:group]
			target = options[:target]


			command_relative_group_root = File.join(project_root, source_root)

			current_project = Xcodeproj::Project.open File.join(project_root, project)

			remove_old_group_and_files group, current_project

			added_references = recreate_group_at_root(group, project_root, source_root, current_project)


			target_obj = target_named_in_project(target, current_project)

			puts "adding files to #{target_obj.name}:"
			added_references.each do |f|
				puts "\t#{f.hierarchy_path}"
			end
			target_obj.source_build_phase.clear
			target_obj.add_file_references(added_references)

			current_project.save
		end


		
		def files_for_group(group_name, project)
			group_actual = project[group_name]
			puts "getting files for group: #{group_actual.pretty_print}"
			group_actual.files
		end

		def remove_old_group_and_files(group_name, project)
			old_group = project["objc_gen"]
			if old_group then
				remove_group_files_from_project(old_group)				
				old_group.remove_from_project
			end
		end

		def remove_group_files_from_project(group)
			group.files.each do |file| 
				file.remove_from_project
			end
		end

		def recreate_group_at_root(group_name, project_root, path_relative_to_project, project)
			new_group = project.new_group(group_name, path_relative_to_project, :project)
			add_tree_to_group(File.join(project_root, path_relative_to_project), new_group)
		end

		def target_named_in_project(target_name, project) 
			project.targets.objects.select {|t| t.name.eql? target_name }.first						
		end

		def add_tree_to_group(tree_root, group)
			base_path_for_dir = tree_root
			file_references  = []
			return file_references unless File.directory? base_path_for_dir

			dir_obj = Dir.new(base_path_for_dir)


			dir_obj.each do |f| 
				next if path_is_relative_directory? f

				full_file_path = File.join(base_path_for_dir, f)

				if (File.directory? full_file_path) then
					d_group = group.new_group(f, f, :group)					
					puts "added directory: #{d_group.hierarchy_path}"
					file_references += add_tree_to_group(File.join(base_path_for_dir, f),  d_group)
				else					
					file_references << add_file_to_group(f, group)
				end
			end

			file_references
		end

		def path_is_relative_directory?(path)
			return (path.eql?("..") || path.eql?("."))
		end

		def add_file_to_group(file, group)
			return if file.start_with? "."
			file_reference = group.new_file(file, :group)
			puts "added file: #{file_reference.hierarchy_path}"			
			file_reference
		end
		
	end

end