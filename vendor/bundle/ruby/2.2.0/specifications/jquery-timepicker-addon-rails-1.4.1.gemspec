# -*- encoding: utf-8 -*-
# stub: jquery-timepicker-addon-rails 1.4.1 ruby lib

Gem::Specification.new do |s|
  s.name = "jquery-timepicker-addon-rails"
  s.version = "1.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["William Van Etten"]
  s.date = "2013-11-20"
  s.description = "This gem provides jquery-ui-timepicker-addon.js and jquery-ui-timepicker-addon.css for your Rails 3 application."
  s.email = ["bill@bioteam.net"]
  s.homepage = "http://rubygems.org/gems/jquery-timepicker-addon-rails"
  s.rubygems_version = "2.4.5"
  s.summary = "Use jquery-ui-timepicker-addon with Rails 3/4"

  s.installed_by_version = "2.4.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<railties>, [">= 3.1"])
    else
      s.add_dependency(%q<railties>, [">= 3.1"])
    end
  else
    s.add_dependency(%q<railties>, [">= 3.1"])
  end
end
