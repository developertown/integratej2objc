$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'j2objc_shared_lib_smanger'
require 'fileutils'

SAMPLE_ARRAY = [*'A'..'Z'].freeze

def fixture_dir
	File.join(File.dirname(__FILE__), "fixture")
end

def test_temp
	File.join(fixture_dir, "test_temp")
end

def ensure_path(path)
	FileUtils.mkdir_p(path)
end

def ensure_test_temp
	ensure_path(test_temp)
end

def clean_test_temp
	FileUtils.remove_dir(test_temp, true)
end

def fixture_path(fixture)
	File.join(fixture_dir, fixture)
end

def temp_fixture_copy_path(fixture)
	File.join(test_temp, fixture)
end

def cp_fixture_to_test_temp(fixture)
	ensure_test_temp
	FileUtils.cp_r(fixture_path(fixture), test_temp)
	temp_fixture_copy_path(fixture)
end

def path_relative_to_test_temp(file)
	File.join(test_temp, file)
end

def touch_file(file)
	ensure_path(File.dirname(file))
	FileUtils.touch(file)
end

def random_string(set = SAMPLE_ARRAY, len = 5)		
	len.times.map{ set.sample }.join
end
