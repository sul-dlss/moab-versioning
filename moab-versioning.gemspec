# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name        = 'moab-versioning'
  s.version     = '4.3.0'
  s.licenses    = ['Apache-2.0']
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Darren Weber', 'Richard Anderson', 'Lynn McRae', 'Hannah Frost']
  s.email       = ['darren.weber@stanford.edu']
  s.summary     = 'Ruby implementation of digital object versioning toolkit used by the SULAIR Digital Library'
  s.description = 'Contains classes to process digital object version content and metadata'
  s.homepage    = 'https://github.com/sul-dlss/moab-versioning'

  s.required_ruby_version = '~> 2.3'

  # Runtime dependencies
  s.add_dependency 'confstruct'
  s.add_dependency 'druid-tools', '>= 1.0.0 ' # druid validation, druid-tree, etc.; needs 1.0.0 for strict validation
  s.add_dependency 'json'
  s.add_dependency 'nokogiri' # XML parsing
  s.add_dependency 'nokogiri-happymapper' # Object to XML Mapping Library, using Nokogiri

  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'equivalent-xml'
  s.add_development_dependency 'pry-byebug' unless ENV['CI']
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rubocop', '~> 0.79.0' # avoid code churn due to rubocop changes
  s.add_development_dependency 'rubocop-rspec', '~> 1.37.1' # avoid code churn due to rubocop-rspec changes

  s.files        = Dir.glob('lib/**/*')
  s.require_path = 'lib'
end
