require 'rubygems'
require 'hashery/orderedhash'
require 'pathname'
require 'yard'
include YARD

class String
  def snake_case
    self.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
        gsub(/([a-z\d])([A-Z])/, '\1_\2').
        tr("-", "_").
        downcase
  end
end

class Symbol
  def snake_case
    self.to_s.snake_case
  end
end

class SpecGenerator

  def initialize(rootpath)
    @rootpath = rootpath
    @ios = $stdout
  end

  def generate_tests
    spec_pathname = Pathname(@rootpath).join('spec', 'temp', "temp_unit_tests")
    classes = get_classes
    classes.each do |cls|
      test_pathname = spec_pathname.join(cls.path.snake_case + "_spec.rb")
      test_pathname.parent.mkpath
      #puts test_pathname.to_s
      unless test_pathname.exist?
        begin
          @constructor_params = Array.new
          @indent = 0
          @ios = test_pathname.open("w")
          process_class(cls)
        ensure
          @ios.close
        end
      end
    end
  end

  def get_classes()
    yardoc = File.join(@rootpath, '.yardoc')
    Registry.load!(yardoc) # loads all objects into memory
    Registry.all(:class) # Array
  end

  # @param string [String]
  def output(string)
    @ios.puts "  "*@indent + string
  end

  # @param cls [CodeObjects::ClassObject]
  def process_class(cls)
    output %q{require File.join('..', '..','spec_helper')}
    output ""
    output "# Unit tests for class {#{cls.path}}"
    output "describe '#{cls.path}' do"
    @indent += 1
    mhash = categorize_members(cls)
    if mhash[:class_attributes].size > 0
      process_attributes(cls, :class, mhash[:class_attributes])
    end
    if mhash[:class_methods].size > 0
      process_methods(cls, :class, mhash)
    end

    process_constructor(cls, mhash)

    if mhash[:instance_attributes].size > 0
      process_attributes(cls, :instance, mhash[:instance_attributes])
    end
    if mhash[:instance_methods].size > 0
      process_methods(cls, :instance, mhash)
    end

    @indent -= 1
    output ""
    output "end"
  end

  # @param cls [CodeObjects::ClassObject]
  def categorize_members(cls)
    mhash = {
        :class_attributes => OrderedHash.new,
        :instance_attributes => OrderedHash.new,
        :class_methods => Array.new,
        :instance_methods => Array.new
    }
    cls.children.each do |member|
      attr_symbol = member.name.to_s.gsub(/=$/, '').to_sym
      if member.name == :initialize
        mhash[:constructor] = member
      elsif cls.class_attributes[attr_symbol]
        mhash[:class_attributes][attr_symbol] = cls.class_attributes[attr_symbol]
      elsif cls.instance_attributes[attr_symbol]
        mhash[:instance_attributes][attr_symbol] = cls.instance_attributes[attr_symbol]
      elsif member.scope == :class
        mhash[:class_methods] << member
      elsif member.scope == :instance
        mhash[:instance_methods] << member
      end
    end
    mhash
  end

  def process_constructor(cls, mhash)
    output ""
    output "describe '=========================== CONSTRUCTOR ===========================' do"

    @indent += 1
    method = mhash[:constructor]
    if method.respond_to?(:docstring)
      @constructor_params = method.docstring.tags(:param)

      output ""
      output "# Unit test for constructor: {#{method.path}}"
      output "# Which returns an instance of: [#{cls.path}]"
      output "# For input parameters:"
      @constructor_params.each do |p|
        output "# * #{p.name} [#{p.types.join(', ')}] = #{p.text.gsub(/\n/, ' ')} "
      end
      output "specify '#{method.path}' do"
      @indent += 1

      cls_instance = cls.name.snake_case
      param_list = (@constructor_params.collect { |p| p.name }).join(', ')

      output " "
      output "# test initialization with required parameters (if any)"
      @constructor_params.each do |p|
        if p.name == 'opts'
          output "opts = {}"
        else
          output "#{p.name} = #{value_for(p.name, p.types[0])} "
        end
      end
      output "#{cls_instance} = #{cls.name}.new(#{param_list})"
      output "#{cls_instance}.should be_instance_of(#{cls.name})"
      @constructor_params.each do |p|
        unless p.name == 'opts'
          output "#{cls_instance}.#{p.name}.should == #{p.name}"
        end
      end

      arrays_and_hashes = attribute_arrays_and_hashes(mhash)
      if arrays_and_hashes.size > 0
        output " "
        output "# test initialization of arrays and hashes"
        arrays_and_hashes.each do |attr_name, type|
          output "#{cls_instance}.#{attr_name}.should be_kind_of(#{type})"
        end
      end

      @constructor_params.each do |p|
        if p.name == 'opts'
          output " "
          output "# test initialization with options hash"
          output "opts = OrderedHash.new"
          attribute_name_type_pairs(mhash).each do |name, type|
            output "opts[:#{name}] = #{value_for(name, type)}"
          end
          output "#{cls_instance} = #{cls.name}.new(#{param_list})"
          attribute_name_type_pairs(mhash).each do |name, type|
            output "#{cls_instance}.#{name}.should == opts[:#{name}]"
          end
        end
      end

      output_source(method)
      @indent -= 1

      output "end"

    end
    @indent -= 1
    output ""
    output "end"
  end

  def process_attributes(cls, scope, attributes)
    output ""
    output "describe '=========================== #{scope.to_s.upcase} ATTRIBUTES ===========================' do"
    @indent += 1

    if scope == :instance
      output ""
      output "before(:all) do"
      @indent += 1
      @constructor_params.each do |p|
        if p.name == 'opts'
          output "opts = {}"
        else
          output "#{p.name} = #{value_for(p.name, p.types[0])} "
        end
      end
      cls_instance = cls.name.snake_case
      param_list = (@constructor_params.collect { |p| p.name }).join(', ')
      output "@#{cls_instance} = #{cls.name}.new(#{param_list})"
      @indent -= 1
      output "end"
    end

    attributes.values.each do |attribute|
      write = attribute[:write]
      read = attribute[:read]
      return_tag = read.docstring.tag(:return)
      return_type = return_tag.types[0]
      output ""
      output "# Unit test for attribute: {#{read.path}}"
      output "# Which stores: [#{return_type}] #{return_tag.text.gsub(/\n/, ' ')}"
      output "specify '#{read.path}' do"

      @indent += 1
      output "value = #{value_for(read.name, return_type)}"
      case scope
        when :class
          output "#{write.path} value"
          output "#{read.path}.should == value"
        when :instance
          output "@#{cls.name.snake_case}.#{write.name} value"
          output "@#{cls.name.snake_case}.#{read.name}.should == value"
      end

      output_source(write)
      output_source(read)

      @indent -= 1
      output "end"
    end
    @indent -= 1

    output ""
    output "end"
  end

  def process_methods(cls, scope, mhash)
    output ""
    output "describe '=========================== #{scope.to_s.upcase} METHODS ===========================' do"
    @indent += 1

    if scope == :instance
      output ""
      output "before(:each) do"
      @indent += 1
      @constructor_params.each do |p|
        if p.name == 'opts'
          output "@opts = {}"
        else
          output "@#{p.name} = #{value_for(p.name, p.types[0])} "
        end
      end
      cls_instance = cls.name.snake_case
      param_list = (@constructor_params.collect { |p| '@'+p.name }).join(', ')
      output "@#{cls_instance} = #{cls.name}.new(#{param_list})"
      output ""
      attribute_name_type_pairs(mhash).each do |name, type|
        output "@#{cls_instance}.#{name} = #{value_for(name, type)}"
      end
      @indent -= 1
      output "end"
    end

    case scope
      when :class
        methods =mhash[:class_methods]
      when :instance
        methods =mhash[:instance_methods]
    end

    methods.each do |method|
      begin
        return_tag = method.docstring.tag(:return)
        return_type = return_tag.types[0]


        params = method.docstring.tags(:param)

        output ""
        output "# Unit test for method: {#{method.path}}"
        output "# Which returns: [#{return_type}] #{return_tag.text.gsub(/\n/, ' ')}"
        if params.length > 0
          output "# For input parameters:"
          params.each do |p|
            output "# * #{p.name} [#{p.types.join(', ')}] = #{p.text.gsub(/\n/, ' ')} "
          end
        else
          output "# For input parameters: (None)"
        end

        output "specify '#{method.path}' do"

        @indent += 1
        params.each do |p|
          output "#{p.name} = #{value_for(p.name, p.types[0])} "
        end
        param_list = (params.collect { |p| p.name }).join(', ')
        if return_type == 'void'
          case scope
            when :class
              output "#{method.path}(#{param_list})"
            when :instance
              output "@#{cls.name.snake_case}.#{method.name}(#{param_list})"
          end
        else
          case scope
            when :class
              output "#{method.path}(#{param_list}).should == "
            when :instance
              output "@#{cls.name.snake_case}.#{method.name}(#{param_list}).should == "
          end
        end

        output_source(method)
        @indent -= 1

        output "end"

      rescue Exception => e
        raise "Error processing method: #{method.path} - " + e.message
        e.backtrace
      end
    end
    @indent -= 1

    output ""
    output "end"
  end


  def value_for(name, return_type)
    case return_type
      when 'Symbol'
        ":test_#{name}"
      when 'Integer'
        rand(100).to_s
      when 'String'
        "'Test #{name}'"
      when 'Boolean'
        "true"
      when 'Pathname'
        "Pathname.new('/test/#{name}')"
      when 'Time'
        "Time.now"
      else
        type = return_type.split(/[<>]/)
        if type.length > 1
          case type[0]
            when 'Array'
              "[#{value_for(name, type[1])}]"
            when 'Hash', 'OrderedHash'
              key, value = type[1].split(/[,]/)
              "{#{value_for(name, key)} => #{value_for(name, value)}}"
            else
              "mock(#{return_type}.name)"
          end
        else
          "mock(#{return_type}.name)"
        end
    end
  end

  def attribute_arrays_and_hashes(mhash)
    arrays_and_hashes = OrderedHash.new
    attribute_name_type_pairs(mhash).each do |name, type|
      if type.include?('Array')
        arrays_and_hashes[name] = 'Array'
      elsif type.include?('Hash')
          arrays_and_hashes[name] = 'Hash'
      end
    end
    arrays_and_hashes
  end

  def attribute_name_type_pairs(mhash)
    pairs = OrderedHash.new
    mhash[:instance_attributes].values.each do |attribute|
      read = attribute[:read]
      return_tag = read.docstring.tag(:return)
      pairs[read.name] =return_tag.types[0]
    end
    pairs
  end

  def output_source(method)
    output " "
    lines = method.source.split(/\n/)
    lines.each { |line| output "# #{line}" }
  end

end


sg = SpecGenerator.new(File.expand_path(File.join(File.dirname(__FILE__), '..', '..')))
sg.generate_tests
