# coding: utf-8
Gem::Specification.new do |spec|
  spec.name          = "integratej2objc"
  spec.version       = "0.0.1"
  spec.authors       = ["Jon Nolen"]
  spec.email         = ["jon.nolen@gmail.com"]
  spec.summary       = %q{Provides integratej2objc executable which takes generated source files and replaces or adds a group to an Xcode Project file.}
  # spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   << "integratej2objc"
  
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "thor", "~> 0.19"
  spec.add_runtime_dependency "xcodeproj", "~> 0.21"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
