# Integratej2objc

J2Objc and Gradle will generate your files and put them in a source directory, but they won't update your xcode project to actually reflect the new truth. This gem provides the integratej2objc executable that uses the xcodeproj gem to update your project.  Can be included as a last task after gradle does it's thing.

## Installation
Currently the gem is not deployed to rubygems.  The best way I've found to use it locally is with [bundler](http://bundler.io)

Gemfile entry:
```
gem 'integratej2objc', git:'https://github.com/developertown/integratej2objc.git'
```

`bundle; bundle exec integratej2objc help;`


## Usage

```
Usage:
  integratej2objc integrate_source -g, --group=GROUP -s, --source-root=SOURCE_ROOT -t, --target=TARGET -x, --xcodeproj=XCODEPROJ

Options:
  -x, --xcodeproj=XCODEPROJ      # relative or absolute path to yourproject.xcodeproj, including yourproject.xcodeproj
  -s, --source-root=SOURCE_ROOT  # the relatitve path from yourproject.xcodeproj to the generated sources directory.
  -g, --group=GROUP              # This is the path to the group you are targeting from the xcode project, in Xcode For example in Xcode Project Navigator you see:
           MyProject.xcodeproj
            └ MyProject
                └ generated
           would have a group argument: -g "MyProject/generated"
  -t, --target=TARGET            # the name of the target that generated sources should be added to in your xcode project

For use with any source directory and Xcode project. Removes GROUP and descendant files from XCODEPROJ and then adds all directories and files from SOURCE_ROOT, recursively, to the GROUP and TARGET
```

Worked example given a project structure:

* my_project/
   * shared/
      * generated_objc/
   * ios/
      * my_proj.xcodeproj/

and a group for your generated source files in the my_proj.xcodeproj called "generated" and a target called MyProj

from my_project/

```
integratej2objc integrate_source  -x ios/my_proj.xcodeproj -s ../shared/generated_objc -g generated -t MyProj
```

this will remove the existing `generated` group from my_proj.xcodeproj and all of it's children files. It will then add it back with a path relative to the project file and add all descendant .h and .m files.  these files will then be added to the target so that they will be compiled.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/integratej2objc/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
