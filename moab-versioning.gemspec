# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "moab-versioning"
  s.version     = "1.2.5"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Richard Anderson", "Lynn McRae", "Hannah Frost"]
  s.email       = ["rnanders@stanford.edu"]
  s.summary     = "Ruby implmentation of digital object versioning toolkit used by the SULAIR Digital Library"
  s.description = "Contains classes to process digital object version content and metadata"

  s.required_rubygems_version = ">= 1.3.6"

  # Runtime dependencies
  s.add_dependency "confstruct"
  s.add_dependency "nokogiri"
  s.add_dependency "hashery", ">=2.0.0"
  s.add_dependency "json"
  s.add_dependency "happymapper"
  s.add_dependency "systemu"

  # Bundler will install these gems too if you've checked out dor-services data from git and run 'bundle install'
  # It will not add these as dependencies if you require dor-services for other projects
  s.add_development_dependency "awesome_print"
  s.add_development_dependency "equivalent-xml", ">=0.2.2"
  s.add_development_dependency "lyberteam-gems-devel", ">=1.0"
  s.add_development_dependency "rake", ">=0.8.7"
  s.add_development_dependency "rcov"
  s.add_development_dependency "rdoc"
  s.add_development_dependency "rspec", "< 2.0" # We're not ready to upgrade to rspec 2
  s.add_development_dependency "yard"
  s.files        = Dir.glob("lib/**/*")
  s.require_path = 'lib'
end

