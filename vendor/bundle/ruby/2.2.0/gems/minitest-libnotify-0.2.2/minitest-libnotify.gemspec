# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "minitest/libnotify/version"

Gem::Specification.new do |s|
  s.name        = "minitest-libnotify"
  s.version     = MiniTest::Libnotify::VERSION
  s.authors     = ["Peter Suschlik"]
  s.email       = ["peter-minitest-libnotify@suschlik.de"]
  s.homepage    = "https://github.com/splattael/minitest-libnotify"
  s.summary     = %q{Test notifier for minitest via libnotify.}
  s.description = %q{Display graphical notfications when testing with minitest.}

  s.rubyforge_project = "minitest-libnotify"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'minitest'
  s.add_runtime_dependency 'libnotify'
end
