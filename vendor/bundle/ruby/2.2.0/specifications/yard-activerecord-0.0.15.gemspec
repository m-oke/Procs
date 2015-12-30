# -*- encoding: utf-8 -*-
# stub: yard-activerecord 0.0.15 ruby lib

Gem::Specification.new do |s|
  s.name = "yard-activerecord"
  s.version = "0.0.15"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Theodor Tonum"]
  s.date = "2015-06-02"
  s.description = "\n    YARD-Activerecord is a YARD extension that handles and interprets methods\n    used when developing applications with ActiveRecord. The extension handles\n    attributes, associations, delegates and scopes. A must for any Rails app\n    using YARD as documentation plugin. "
  s.email = ["theodor@tonum.no"]
  s.homepage = "https://github.com/theodorton/yard-activerecord"
  s.licenses = ["MIT License"]
  s.rubygems_version = "2.4.5.1"
  s.summary = "ActiveRecord Handlers for YARD"

  s.installed_by_version = "2.4.5.1" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<yard>, [">= 0.8.3"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<yard>, [">= 0.8.3"])
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<yard>, [">= 0.8.3"])
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
