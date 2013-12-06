# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = "moab-versioning"
  s.version     = "1.3.2"
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

  s.add_development_dependency "awesome_print"
  s.add_development_dependency "equivalent-xml", ">=0.2.2"
  s.add_development_dependency "rake", ">=0.8.7"
  s.add_development_dependency "rdoc"
  s.add_development_dependency "rspec"
  s.add_development_dependency "yard"
  s.files        = Dir.glob("lib/**/*")
  s.require_path = 'lib'
end

