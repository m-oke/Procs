# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'pathname'
require 'minitest/filesystem/version'

signing_key_file = ENV['RUBYGEMS_SIGNING_KEY_FILE']

Gem::Specification.new do |gem|
  gem.name          = "minitest-filesystem"
  gem.version       = Minitest::Filesystem::VERSION
  gem.authors       = ["Stefano Zanella"]
  gem.email         = ["zanella.stefano@gmail.com"]
  gem.description   = %q{Minitest exstension to check filesystem contents}
  gem.summary       = %q{Adds assertions and expectations to check the content
                         of a filesystem tree with minitest}
  gem.homepage      = "https://github.com/stefanozanella/minitest-filesystem"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|gem|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "bundler", "~> 1.3"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "minitest"
  gem.add_development_dependency "coveralls"
  gem.add_development_dependency "flog"
  gem.add_development_dependency "flay"

  gem.signing_key = Pathname.new(signing_key_file).expand_path if signing_key_file
  gem.cert_chain  = ["rubygems-stefanozanella.crt"]
end
