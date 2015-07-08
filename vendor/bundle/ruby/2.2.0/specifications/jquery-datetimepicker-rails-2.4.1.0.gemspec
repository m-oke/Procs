# -*- encoding: utf-8 -*-
# stub: jquery-datetimepicker-rails 2.4.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "jquery-datetimepicker-rails"
  s.version = "2.4.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Andrey Novikov"]
  s.date = "2014-11-19"
  s.description = "A date and time picker for jQuery and Rails"
  s.email = ["envek@envek.name"]
  s.homepage = "https://github.com/Envek/jquery-datetimepicker-rails"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.5"
  s.summary = "This gem packages the datetimepicker jQuery plugin for Rails 3.1+ asset pipeline"

  s.installed_by_version = "2.4.5" if s.respond_to? :installed_by_version

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
