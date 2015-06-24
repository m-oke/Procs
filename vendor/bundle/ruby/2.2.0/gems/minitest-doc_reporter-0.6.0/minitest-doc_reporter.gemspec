# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'minitest/doc_reporter/version'

Gem::Specification.new do |spec|
  spec.name          = "minitest-doc_reporter"
  spec.version       = Minitest::DocReporter::VERSION
  spec.authors       = ["Jason Thompson"]
  spec.email         = ["jason@jthompson.ca"]
  spec.description   = %q{A detailed spec-by-spec report for Minitest}
  spec.summary       = %q{Provides a detailed report modelled after the documentation report style in rspec.}
  spec.homepage      = "http://github.com/jasonthompson/minitest-doc_reporter"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"

  spec.add_runtime_dependency "minitest", "~> 5.0"
  spec.add_runtime_dependency "ansi"
end
