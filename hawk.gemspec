# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hawk/version'

Gem::Specification.new do |gem|
  gem.name          = "hawk"
  gem.version       = Hawk::VERSION
  gem.authors       = ["Mat Trudel"]
  gem.email         = ["mat@geeky.net"]
  gem.description   = %q{A simple iOS ad-hoc distribution tool}
  gem.summary       = %q{iOS ad-hoc distribution made easy}
  gem.homepage      = %q{http://github.com/mtrudel/hawk}

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('aws-sdk', '~> 1.8')
  gem.add_dependency('osx-plist', '~> 1.0')
  gem.add_dependency('googl', '~> 0')
end
