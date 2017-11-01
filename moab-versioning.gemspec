lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

Gem::Specification.new do |s|
  s.name        = 'moab-versioning'
  s.version     = '2.2.0'
  s.licenses    = ['Apache-2.0']
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Darren Weber', 'Richard Anderson', 'Lynn McRae', 'Hannah Frost']
  s.email       = ['darren.weber@stanford.edu']
  s.summary     = 'Ruby implementation of digital object versioning toolkit used by the SULAIR Digital Library'
  s.description = 'Contains classes to process digital object version content and metadata'
  s.homepage    = 'https://github.com/sul-dlss/moab-versioning'

  s.required_ruby_version = '~> 2.1'

  # Runtime dependencies
  s.add_dependency 'confstruct'
  s.add_dependency 'nokogiri' # XML parsing
  s.add_dependency 'nokogiri-happymapper' # Object to XML Mapping Library, using Nokogiri
  s.add_dependency 'json'
  s.add_dependency 'systemu' # universal capture of stdout and stderr and handling of child process pid
  s.add_dependency 'druid-tools', '>= 1.0.0 ' # druid validation, druid-tree, etc.; needs 1.0.0 for strict validation

  s.add_development_dependency 'awesome_print'
  s.add_development_dependency 'equivalent-xml'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'rubocop', '~> 0.50.0' # avoid code churn due to rubocop changes
  s.add_development_dependency 'rubocop-rspec', '~> 1.18.0' # avoid code churn due to rubocop-rspec changes

  s.files        = Dir.glob('lib/**/*')
  s.require_path = 'lib'
end
