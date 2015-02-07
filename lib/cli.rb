

require 'rubygems'
require 'thor'

module IntegrateJ2objc
	class CLI < Thor
		desc "integrate_source", 
		%[For use with any source directory and Xcode project. Removes GROUP and descendant files] +
		%[ from XCODEPROJ and then adds all directories and files from SOURCE_ROOT, recursively, to] +
		%[ the GROUP and TARGET]
		method_option :project_root, required: true, 
		type: :string, 
		aliases: "-p"
		method_option :xcodeproj, required: true, type: :string, aliases: "-x"
		method_option :source_root, required: true, type: :string, aliases: "-s"
		method_option :group, required: true, type: :string, aliases: "-g"
		method_option :target, required: true, type: :string, aliases: "-t"		
		def integrate_source()
			J2ObjcSharedLibSmanger.new().integrate_source(options);
		end
	end
end