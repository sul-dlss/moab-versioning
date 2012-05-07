rootpath = File.expand_path(File.join(File.dirname(__FILE__), '..'))
puts rootpath
lib = File.join(rootpath,'lib')
$LOAD_PATH.unshift(lib)  unless $LOAD_PATH.include?(lib)
require 'moab'
#spec_helper = File.join(rootpath,'spec','spec_helper')

class SpecGeneratorOld

  attr_accessor :c
  attr_accessor :members

  def initialize(c)
    @c=c
    #require camel_to_snake_case(c.name)
    i_members = c.instance_methods(include_super=false)
    i_setters = i_members.grep /[^=][=]$/
    i_getters = i_setters.collect { |s| s.gsub(/[=]$/,'') }
    @members = Hash.new
    @members['Instance Variables'] = (i_getters).sort
    @members['Instance Methods'] = (i_members - i_setters - i_getters).sort
    @members['Class Methods'] = c.methods(include_super=false).sort
  end

  def generate
    puts "require 'spec_helper'"
    puts ""
    puts "describe '#{@c.name}' do"
    puts ""
    ['Instance Variables','Instance Methods','Class Methods'].each do |type |
      puts "  context '#{type}' do"
      puts ""
      @members[type].each do |member|
        puts "    describe '##{member}' do"
        puts "      pending"
        puts "    end"
        puts ""
      end
      puts "  end"
      puts ""
    end
    puts "end"
  end

  def camel_to_snake_case(camel)
    camel.gsub(/(.)([A-Z])/,'\1_\2').downcase
  end

end