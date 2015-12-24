# -*- encoding: utf-8 -*-
# stub: minitest-power_assert 0.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "minitest-power_assert"
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["SHIBATA Hiroshi"]
  s.date = "2015-04-30"
  s.description = "Power Assert for Minitest."
  s.email = ["hsbt@ruby-lang.org"]
  s.homepage = "https://github.com/hsbt/minitest-power_assert"
  s.licenses = ["2-clause BSDL"]
  s.rubygems_version = "2.4.5.1"
  s.summary = "Power Assert for Minitest."

  s.installed_by_version = "2.4.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<minitest>, [">= 0"])
      s.add_runtime_dependency(%q<power_assert>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.6"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<minitest>, [">= 0"])
      s.add_dependency(%q<power_assert>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.6"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<minitest>, [">= 0"])
    s.add_dependency(%q<power_assert>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.6"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
