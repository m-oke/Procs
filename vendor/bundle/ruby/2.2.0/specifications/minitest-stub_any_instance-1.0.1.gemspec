# -*- encoding: utf-8 -*-
# stub: minitest-stub_any_instance 1.0.1 ruby lib

Gem::Specification.new do |s|
  s.name = "minitest-stub_any_instance"
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Sammy Larbi", "Vasiliy Ermolovich"]
  s.date = "2015-01-24"
  s.description = "Adds a method to MiniTest that stubs any instance of a class."
  s.email = ["sam@codeodor.com"]
  s.homepage = "https://github.com/codeodor/minitest-stub_any_instance"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.5.1"
  s.summary = ""

  s.installed_by_version = "2.4.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
