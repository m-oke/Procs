# -*- encoding: utf-8 -*-
# stub: hirb-unicode 0.0.5 ruby lib

Gem::Specification.new do |s|
  s.name = "hirb-unicode"
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["miaout17"]
  s.date = "2011-08-08"
  s.description = "Unicode support for hirb"
  s.email = ["miaout17 at gmail dot com"]
  s.homepage = ""
  s.rubyforge_project = "hirb-unicode"
  s.rubygems_version = "2.4.5"
  s.summary = "Unicode support for hirb"

  s.installed_by_version = "2.4.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hirb>, ["~> 0.5"])
      s.add_runtime_dependency(%q<unicode-display_width>, ["~> 0.1.1"])
      s.add_development_dependency(%q<bacon>, [">= 1.1.0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<mocha-on-bacon>, [">= 0"])
      s.add_development_dependency(%q<bacon-bits>, [">= 0"])
    else
      s.add_dependency(%q<hirb>, ["~> 0.5"])
      s.add_dependency(%q<unicode-display_width>, ["~> 0.1.1"])
      s.add_dependency(%q<bacon>, [">= 1.1.0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<mocha-on-bacon>, [">= 0"])
      s.add_dependency(%q<bacon-bits>, [">= 0"])
    end
  else
    s.add_dependency(%q<hirb>, ["~> 0.5"])
    s.add_dependency(%q<unicode-display_width>, ["~> 0.1.1"])
    s.add_dependency(%q<bacon>, [">= 1.1.0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<mocha-on-bacon>, [">= 0"])
    s.add_dependency(%q<bacon-bits>, [">= 0"])
  end
end
