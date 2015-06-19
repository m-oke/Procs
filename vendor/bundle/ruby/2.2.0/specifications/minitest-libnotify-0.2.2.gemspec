# -*- encoding: utf-8 -*-
# stub: minitest-libnotify 0.2.2 ruby lib

Gem::Specification.new do |s|
  s.name = "minitest-libnotify"
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Peter Suschlik"]
  s.date = "2012-03-20"
  s.description = "Display graphical notfications when testing with minitest."
  s.email = ["peter-minitest-libnotify@suschlik.de"]
  s.homepage = "https://github.com/splattael/minitest-libnotify"
  s.rubyforge_project = "minitest-libnotify"
  s.rubygems_version = "2.4.5"
  s.summary = "Test notifier for minitest via libnotify."

  s.installed_by_version = "2.4.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<minitest>, [">= 0"])
      s.add_runtime_dependency(%q<libnotify>, [">= 0"])
    else
      s.add_dependency(%q<minitest>, [">= 0"])
      s.add_dependency(%q<libnotify>, [">= 0"])
    end
  else
    s.add_dependency(%q<minitest>, [">= 0"])
    s.add_dependency(%q<libnotify>, [">= 0"])
  end
end
