# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = 'moab-versioning'
  s.version     = '1.3.3'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Darren Weber', 'Richard Anderson', 'Lynn McRae', 'Hannah Frost']
  s.email       = ['darren.weber@stanford.edu']
  s.summary     = 'Ruby implmentation of digital object versioning toolkit used by the SULAIR Digital Library'
  s.description = 'Contains classes to process digital object version content and metadata'

  s.required_rubygems_version = '>= 1.3.6'

  # Runtime dependencies
  s.add_dependency 'confstruct'
  s.add_dependency 'nokogiri'
  s.add_dependency 'nokogiri-happymapper'
  #s.add_dependency 'happymapper'
  s.add_dependency 'json'
  s.add_dependency 'systemu'

  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'equivalent-xml'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'rspec', '< 3.0.0'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'pry'

  s.files        = Dir.glob('lib/**/*')
  s.require_path = 'lib'
end

