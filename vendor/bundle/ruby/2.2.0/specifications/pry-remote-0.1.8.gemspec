# -*- encoding: utf-8 -*-
# stub: pry-remote 0.1.8 ruby lib

Gem::Specification.new do |s|
  s.name = "pry-remote"
  s.version = "0.1.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Mon ouie"]
  s.date = "2014-01-29"
  s.description = "Connect to Pry remotely using DRb"
  s.email = "mon.ouie@gmail.com"
  s.executables = ["pry-remote"]
  s.files = ["bin/pry-remote"]
  s.homepage = "http://github.com/Mon-Ouie/pry-remote"
  s.rubygems_version = "2.4.5"
  s.summary = "Connect to Pry remotely"

  s.installed_by_version = "2.4.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<slop>, ["~> 3.0"])
      s.add_runtime_dependency(%q<pry>, ["~> 0.9"])
    else
      s.add_dependency(%q<slop>, ["~> 3.0"])
      s.add_dependency(%q<pry>, ["~> 0.9"])
    end
  else
    s.add_dependency(%q<slop>, ["~> 3.0"])
    s.add_dependency(%q<pry>, ["~> 0.9"])
  end
end
