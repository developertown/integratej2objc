$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'j2objc_shared_lib_smanger'
require 'fileutils'

def fixture_dir
	File.join(File.dirname(__FILE__), "fixture")
end

def test_temp
	File.join(fixture_dir, "test_temp")
end

def ensure_test_temp
	FileUtils.mkdir_p(test_temp)
end

def clean_test_temp
	FileUtils.rm_r(test_temp)
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

