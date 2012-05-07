#$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
require 'rubygems'
require 'hashery/orderedhash'
require 'pathname'
require 'yard'
include YARD
require 'serializer'
require 'moab'
require 'stanford'
include Serializer
include Moab
include Stanford

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

class ApiClass
  attr_accessor :class_name
  attr_accessor :yard_class
  attr_accessor :mhash
  attr_accessor :ruby_class
  attr_accessor :xml_tag
  attr_accessor :description
  attr_accessor :model

  def self.class_hash=(class_hash)
    @@class_hash = class_hash
  end

  def self.rootpath=(rootpath)
    @@rootpath = rootpath
  end

  def initialize(class_name)
    @class_name = class_name
    @yard_class = @@class_hash[class_name]
    if yard_class.nil?
      raise "class_hash[#{class_name}] is Nil"
    end
    @mhash = categorize_members(@yard_class)
    if @yard_class.path.include?('::')
      ruby_module = Object::const_get(yard_class.path.split(/::/)[0])
      @ruby_class = ruby_module.const_get(yard_class.name)
    else
      @ruby_class = Object::const_get(yard_class.path)
    end

    if @ruby_class.respond_to?(:tag_name)
      @xml_tag = "<#{ruby_class.tag_name}>"
    else
      @xml_tag = '-'
    end
    docstring_all = confluence_translate(yard_class.docstring.all.split(/@/)[0])
    docstring_parts = docstring_all.split(/h4. Data Model\n/)
    @description = docstring_parts[0]
    @model = docstring_parts.size > 1 ? docstring_parts[1] : nil
  end

  def categorize_members(yard_class)
    mhash = {
        :class_attributes => OrderedHash.new,
        :instance_attributes => OrderedHash.new,
        :class_methods => Array.new,
        :instance_methods => Array.new
    }
    yard_class.children.each do |member|
      attr_symbol = member.name.to_s.gsub(/=$/, '').to_sym
      if member.name == :initialize
        mhash[:constructor] = member
      elsif yard_class.class_attributes[attr_symbol]
        mhash[:class_attributes][attr_symbol] = yard_class.class_attributes[attr_symbol]
      elsif yard_class.instance_attributes[attr_symbol]
        mhash[:instance_attributes][attr_symbol] = yard_class.instance_attributes[attr_symbol]
      elsif member.scope == :class
        mhash[:class_methods] << member
      elsif member.scope == :instance
        mhash[:instance_methods] << member
      end
    end
    mhash
  end

  def title
    title = "\n{anchor:#{yard_class.name}}\n"
    title << "h3. Class #{yard_class.path}"
    title
  end

  def description
    description = "\nh4. Description\n\n"
    description << @description
    description
  end

  def model
    model = "\nh4. Data Model\n\n"
    model << @model
    model
  end

  def xml_example
    xml_example = String.new
    if yard_class.docstring.has_tag?('example')
      xml_example << "\nh4. XML Example\n"
      xml_example << "{code:lang=xml}\n"
      filename = yard_class.docstring.tag('example').name.split(/[:)}]/)[2]
      example = IO.read(File.join(@@rootpath, filename))
      xml_example << example
      xml_example << "{code}\n"
    end
    xml_example
  end

  def instance_attributes_table(mode=:all)
    table = String.new
    table <<  "\\\\\n||XML Element||Ruby Class||Inherits From||\n"
    table << "|#{xml_tag}|[##{class_name}]|#{yard_class.superclass}|\n"
    table << "\\\\\n||XML Child Node||Ruby Attribute||Data Type||Description||\n"
    xml_names = xml_name_hash
    @mhash[:instance_attributes].values.each do |attribute|
      read = attribute[:read]
      return_tag = read.docstring.tag(:return)
      ruby_name = read.name.to_s
      xml_name = xml_names[ruby_name] ? xml_names[ruby_name] : "-"
      data_type = return_tag.types[0]
      description = confluence_translate(return_tag.text.gsub(/\n/, ' '))
      table_row = "|#{xml_name}|#{ruby_name}|#{data_type}|#{description.gsub(/\|/, '\\|')}|\n"
      case mode
        when :xml
          if  xml_name != '-'
            table << table_row
          end
        when :ruby
          if  xml_name == '-'
            table << table_row
          end
        else
          table << table_row
      end
    end
    table
  end

  def xml_name_hash
    xml_name_hash = Hash.new
    if @ruby_class.respond_to?(:attributes)
      @ruby_class.attributes.each do |attribute|
        xml_name_hash[attribute.name.to_s] = "@#{attribute.tag}"
      end
    end
    if @ruby_class.respond_to?(:elements)
      @ruby_class.elements.each do |element|
        if element.options.size == 0 or element.options[:single]
          xml_name_hash[element.name.to_s] = "<#{element.tag}>"
        else
          xml_name_hash[element.name.to_s] = "<#{element.tag}> \\[1..\\*]"
        end
      end
    end
    xml_name_hash
  end

  def methods_documentation

    methods_documentation = String.new
    
    #methods_documentation ""
    #methods_documentation "h4. Constructor"
    #method = mhash[:constructor]
    #methods_documentation_method(method, yard_class) if method

    methods =mhash[:class_methods]
    if methods.size > 0
      methods_documentation << "\nh4. Class Methods\n"
      methods.each do |method|
        methods_documentation << method_documentation(method)
      end
    end

    methods =mhash[:instance_methods]
    if methods.size > 0
      public_methods = Array.new
      methods.each do |method|
        if method.docstring.has_tag?(:api) && method.docstring.tag(:api).text == 'external'
          public_methods << method
        end
      end
      if public_methods.size > 0
        methods_documentation << "\nh4. Instance Methods\n"
        public_methods.each do |method|
          methods_documentation << method_documentation(method)
        end
      end
    end
    methods_documentation
  end

  def method_documentation(method)

    method_documentation = String.new
    if method.nil?
      raise "method is nil"
    end
    method_documentation << "\nh5. #{method.path}\n"

    method_documentation << "||Method||Return Type||Description||\n"
    if method.name == :initialize
      return_type = @yard_class.name
      description = 'constructor'
    else
      return_tag = method.docstring.tag(:return)
      if return_tag.nil?
        raise "#{method.name} return tag is nil"
      end
      return_type = return_tag.types[0]
      description = confluence_translate(return_tag.text.gsub(/\n/, ' '))
    end
    method_documentation << "|#{method.name}|#{return_type}|#{description}|\n"

    if method.respond_to?(:docstring)
      params = method.docstring.tags(:param)
      if params && params.size > 0
        method_documentation << "\n||Parameter||Data Type||Description||\n"
        params.each do |p|
          description = confluence_translate(p.text.gsub(/\n/, ' '))
          method_documentation << "|#{p.name}|#{p.types.join(', ')}|#{description}|\n"
        end
      end
    end

    method_documentation << "{code:lang=none|title=Ruby Source Code}\n"
    method_documentation << method.source
    method_documentation << "{code}\n"

    if method.docstring.has_tag?('example')
      method_documentation << "\n{code:lang=none|title=Usage Example}\n"
      filename = method.docstring.tag('example').name.split(/[:)}]/)[2]
      example = IO.read(File.join(@@rootpath, filename))
      method_documentation << example
      method_documentation << "{code}\n"
    end
    method_documentation
  end

  def confluence_translate(input)
    map = OrderedHash.new
    map[/\|/] = "\\|"
    map[/====/] = "h4. "
    map[/\*/] = "\\*"
    map[/\n\s{6}\\\*\s/] = "\n****\s"
    map[/\n\s{4}\\\*\s/] = "\n***\s"
    map[/\n\s{2}\\\*\s/] = "\n**\s"
    map[/\n\\\*\s/] = "\n*\s"
    map[/<[\/]*b>/] = "*"
    map[/<[\/]*i>/] = "_"
    map[/\[/] = "\\["
    map[/\{#/] = "[#"
    map[/\{http/] = "[http"
    map[/\{/] = "[#"
    map[/\}/] = "]"
    output = input
    map.each do |regex, replacement|
      output.gsub!(regex, replacement)
    end
    output
  end

end


class ApiDoc < ApiClass
  attr_accessor :ios
  attr_accessor :classes

  def process_doc(ios)
    @ios = ios
    parse_model

    output component
    output model
    output description
    output xml_example
    output xml_nodes
    classes_detail
  end

  def component
    component = "h2. Component:  #{yard_class.name}\n"
    component
  end

  def xml_nodes
    nodes = "\nh4. XML Nodes\n"
    @classes.each do |cls|
      nodes << cls.instance_attributes_table(mode=:xml)
    end
    nodes
  end

  def classes_detail
    @classes.each do |cls|
      output cls.title
      output cls.description if cls != self
      output cls.methods_documentation
    end
  end

  def parse_model
    @classes = Array.new
    @classes << self
    if @model
      model.lines.each do |line|
        matches = line.scan(/\[#(.*)?\]/)
        if matches.size > 0
          match = matches[0][0].split(/\]/)[0]
          if match != class_name
            @classes << ApiClass.new(match)
          end
        end
      end
    end

  end

  def output(string)
    @ios.puts  string
  end


end


class DocGenerator

  def initialize(rootpath)
    @rootpath = rootpath
  end

  def generate_docs(apis)
    temp_pathname = Pathname(@rootpath).join('api', 'temp')
    ApiClass.class_hash = get_class_hash
    ApiClass.rootpath = @rootpath
    apis.each do |api_name|
      doc_pathname = temp_pathname.join(api_name + "_confluence.txt")
      doc_pathname.parent.mkpath
      #puts doc_pathname.to_s
      #unless doc_pathname.exist?
        begin
          @constructor_params = Array.new
          @indent = 0
          ios = doc_pathname.open("w")
          api_doc = ApiDoc.new(api_name)
          api_doc.process_doc(ios)
        ensure
          ios.close
        end
      #end
    end
  end

  def get_class_hash()
    class_hash = Hash.new
    yardoc = File.join(@rootpath, '.yardoc')
    Registry.load!(yardoc) # loads all objects into memory
    class_array = Registry.all(:class) # Array
    class_array.each do |cls|
      class_hash[cls.name.to_s] = cls
    end
    class_hash
  end

end

apis = Array.new
apis << 'FileInventory'
apis << 'SignatureCatalog'
apis << 'FileInventoryDifference'
apis << 'VersionMetadata'
apis << 'Serializable'
apis << 'StorageObject'
apis << 'DorMetadata'

sg = DocGenerator.new(File.expand_path(File.join(File.dirname(__FILE__), '..', '..')))
sg.generate_docs(apis)
