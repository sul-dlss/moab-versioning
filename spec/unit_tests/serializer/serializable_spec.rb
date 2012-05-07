require 'spec_helper'

class MyClass < Serializable
  include HappyMapper

  attribute :my_attr, String
  element :my_element, String

end

# Unit tests for class {Moab::Serializable}
describe 'Moab::Serializable' do

  before(:all) do
    @v1_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/versionInventory.xml')
    @v1_inventory = FileInventory.parse(@v1_inventory_pathname.read)
    @v1_content = @v1_inventory.groups[0]

    @v3_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0003/versionInventory.xml')
    @v3_inventory = FileInventory.parse(@v3_inventory_pathname.read)
    @v3_content = @v3_inventory.groups[0]
  end
  
  describe '=========================== CLASS METHODS ===========================' do
    
    # Unit test for method: {Moab::Serializable.deep_diff}
    # Which returns: [OrderedHash] Generate a hash containing the differences between two hashes (recursively descend parallel trees of hashes)
    # For input parameters:
    # * hashes [Array<Hash>] = The hashes to be compared, with optional name tags 
    specify 'Moab::Serializable.deep_diff' do

      hash1 = @v1_content.files[0].to_hash
      hash3 = @v3_content.files[0].to_hash
      Serializable.deep_diff('v1',hash1, 'v3', hash3).should hash_match({
          "signature" => {
              "size" => {
                  "v1" => 41981,
                  "v3" => 32915
              },
               "md5" => {
                  "v1" => "915c0305bf50c55143f1506295dc122c",
                  "v3" => "c1c34634e2f18a354cd3e3e1574c3194"
              },
              "sha1" => {
                  "v1" => "60448956fbe069979fce6a6e55dba4ce1f915178",
                  "v3" => "0616a0bd7927328c364b2ea0b4a79c507ce915ed"
              }
          },
          "instances" => {
              "intro-1.jpg" => {
                  "v1" => {
                          "path" => "intro-1.jpg",
                      "datetime" => "2012-03-26T14:20:35Z"
                  },
                  "v3" => nil
              },
               "page-1.jpg" => {
                  "v1" => nil,
                  "v3" => {
                          "path" => "page-1.jpg",
                      "datetime" => "2012-03-26T15:35:15Z"
                  }
              }
          }
      })

      Serializable.deep_diff(hash1, hash3).should hash_match({
        "signature" => {
            "size" => {
                 :left => 41981,
                :right => 32915
            },
             "md5" => {
                 :left => "915c0305bf50c55143f1506295dc122c",
                :right => "c1c34634e2f18a354cd3e3e1574c3194"
            },
            "sha1" => {
                 :left => "60448956fbe069979fce6a6e55dba4ce1f915178",
                :right => "0616a0bd7927328c364b2ea0b4a79c507ce915ed"
            }
        },
        "instances" => {
            "intro-1.jpg" => {
                 :left => {
                        "path" => "intro-1.jpg",
                    "datetime" => "2012-03-26T14:20:35Z"
                },
                :right => nil
            },
             "page-1.jpg" => {
                 :left => nil,
                :right => {
                        "path" => "page-1.jpg",
                    "datetime" => "2012-03-26T15:35:15Z"
                }
            }
        }
      })

      # def Serializable.deep_diff(*hashes)
      #   diff = OrderedHash.new
      #   case hashes.length
      #     when 4
      #       ltag, left, rtag, right = hashes
      #     when 2
      #       ltag, left, rtag, right = :left, hashes[0], :right, hashes[1]
      #     else
      #       raise "wrong number of arguments (expected 2 or 4)"
      #   end
      #   (left.keys | right.keys).each do |k|
      #     if left[k] != right[k]
      #       if left[k].is_a?(Hash) && right[k].is_a?(Hash)
      #         diff[k] = deep_diff(ltag, left[k], rtag, right[k])
      #       else
      #         diff[k] = OrderedHash.[](ltag, left[k], rtag, right[k])
      #       end
      #     end
      #   end
      #   diff
      # end
    end
  
  end
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Moab::Serializable#initialize}
    # Which returns an instance of: [Moab::Serializable]
    # For input parameters:
    # * opts [Hash<Symbol,Object>] = a hash containing any number of symbol => value pairs. The symbols should correspond to attributes declared using HappyMapper syntax 
    specify 'Moab::Serializable#initialize' do
       
      # test initialization with required parameters (if any)
      opts = {}
      serializable = Serializable.new(opts)
      serializable.should be_instance_of(Serializable)
       
      # test initialization with options hash
      opts = OrderedHash.new
      lambda{Serializable.new(opts)}.should_not raise_exception
       
     # test initialization with options hash containing a bad variable
      opts = OrderedHash.new
      opts[:dummy] = 'dummy'
      lambda{Serializable.new(opts)}.should raise_exception(RuntimeError, 'dummy is not a variable name in Serializer::Serializable')

      # def initialize(opts={})
      #   opts.each do |key, value|
      #     if variable_names.include?(key.to_s) || key = :test
      #       instance_variable_set("@#{key}", value)
      #     else
      #       raise "#{key} is not a variable name in #{self.class.name}"
      #     end
      #   end
      # end
    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do

    # Unit test for method: {Moab::Serializable#variables}
    # Which returns: [Array] A list of HappyMapper xml attribute, element and text nodes declared for the class
    # For input parameters: (None)
    specify 'Moab::Serializable#variables' do
      FileInstance.new.variables().size.should == 2
      SignatureCatalog.new.variables().size.should == 7
      FileSignature.new.variables().size.should == 3

      MyClass.new.variables.size.should == 2

      # def variables
      #   attributes = self.class.attributes
      #   elements   = self.class.elements
      #   text_node = []
      #   if self.class.instance_variable_defined?("@text_node")
      #     text_node << self.class.instance_variable_get("@text_node")
      #   end
      #   attributes + elements + text_node
      # end
    end
    
    # Unit test for method: {Moab::Serializable#variable_names}
    # Which returns: [Array] Extract the names of the variables
    # For input parameters: (None)
    specify 'Moab::Serializable#variable_names' do
      FileInstance.new.variable_names().should == ["path", "datetime"]
      SignatureCatalog.new.variable_names().should ==
          ["digital_object_id", "version_id", "catalog_datetime", "file_count", "byte_count", "block_count", "entries"]
      FileSignature.new.variable_names().should == ["size", "md5", "sha1"]

      # def variable_names
      #   variables.collect { |variable| variable.name}
      # end
    end
    
    # Unit test for method: {Moab::Serializable#key_name}
    # Which returns: [String] Determine which attribute was marked as an object instance key. Keys are indicated by option :key=true when declaring the object's variables. This follows the same convention as used by DataMapper
    # For input parameters: (None)
    specify 'Moab::Serializable#key_name' do
      FileInstance.new.key_name().should == "path"
      SignatureCatalog.new.key_name().should == "version_id"
      FileSignature.new.key_name().should == nil

      # def key_name
      #   if not defined?(@key_name)
      #     @key_name = nil
      #     self.class.attributes.each do |attribute|
      #       if attribute.options[:key]
      #         @key_name = attribute.name
      #         break
      #       end
      #     end
      #   end
      #   @key_name
      # end
    end
    
    # Unit test for method: {Moab::Serializable#key}
    # Which returns: [String] For the current object instance, return the string to use as a hash key
    # For input parameters: (None)
    specify 'Moab::Serializable#key' do
      file_instance = FileInstance.new
      file_instance.should_receive(:path)
      file_instance.key()
      signature_catalog = SignatureCatalog.new
      signature_catalog.should_receive(:version_id)
      signature_catalog.key()
      file_signature = FileSignature.new
      file_signature.key().should == nil

      # def key
      #   return self.send(key_name) if key_name
      #   nil
      # end
    end
    
    # Unit test for method: {Moab::Serializable#array_to_hash}
    # Which returns: [OrderedHash] Generate a hash from an array of objects. If the array member has a field tagged as a key, that field will be used as the hash.key. Otherwise the index position of the array member will be used as the key
    # For input parameters:
    # * array [Array] = The array to be converted to a hash 
    specify 'Moab::Serializable#array_to_hash' do
      array = %w{this is an array of words}
      Serializable.new.array_to_hash(array).should hash_match({
          0 => "this",
          1 => "is",
          2 => "an",
          3 => "array",
          4 => "of",
          5 => "words"
      })
       
      # def array_to_hash(array)
      #   item_hash = OrderedHash.new
      #   array.each_index do |index|
      #     item = array[index]
      #     ikey = item.key || index
      #     item_hash[ikey] =  item.to_hash
      #   end
      #   item_hash
      # end
    end
    
    # Unit test for method: {Moab::Serializable#to_hash}
    # Which returns: [OrderedHash] Recursively generate an OrderedHash containing the object's properties
    # For input parameters: (None)
    specify 'Moab::Serializable#to_hash' do
      additons = FileInventory.read_xml_file(@manifests.join("v2"),'additions')
      additons.groups[0].to_hash().should hash_match({
             "group_id" => "content",
          "data_source" => "",
           "file_count" => 1,
           "byte_count" => 32915,
          "block_count" => 33,
                "files" => {
              nil => {
                  "signature" => {
                      "size" => 32915,
                       "md5" => "c1c34634e2f18a354cd3e3e1574c3194",
                      "sha1" => "0616a0bd7927328c364b2ea0b4a79c507ce915ed"
                  },
                  "instances" => {
                      "page-1.jpg" => {
                              "path" => "page-1.jpg",
                          "datetime" => "2012-03-26T15:35:15Z"
                      }
                  }
              }
          }
      })
       
      # def to_hash
      #   oh = OrderedHash.new
      #   variables.each do |variable|
      #     key = variable.options[:tag] || variable.name.to_s
      #     value = self.send(variable.name)
      #     case value
      #       when Array
      #         oh[key] = array_to_hash(value)
      #       when Serializable
      #         oh[key] = value.to_hash
      #       else
      #         oh[key] = value
      #     end
      #   end
      #   oh
      # end
    end
    
    # Unit test for method: {Moab::Serializable#diff}
    # Which returns: [OrderedHash] Generate a hash containing the differences between two objects of the same type
    # For input parameters:
    # * other [Serializable] = The other object being compared 
    specify 'Moab::Serializable#diff' do
     @v1_content.files[0].diff(@v3_content.files[0]).should hash_match({
         "signature" => {
             "size" => {
                 :old => 32915,
                 :new => 41981
             },
              "md5" => {
                 :old => "c1c34634e2f18a354cd3e3e1574c3194",
                 :new => "915c0305bf50c55143f1506295dc122c"
             },
             "sha1" => {
                 :old => "0616a0bd7927328c364b2ea0b4a79c507ce915ed",
                 :new => "60448956fbe069979fce6a6e55dba4ce1f915178"
             }
         },
         "instances" => {
              "page-1.jpg" => {
                 :old => {
                         "path" => "page-1.jpg",
                     "datetime" => "2012-03-26T15:35:15Z"
                 },
                 :new => nil
             },
             "intro-1.jpg" => {
                 :old => nil,
                 :new => {
                         "path" => "intro-1.jpg",
                     "datetime" => "2012-03-26T14:20:35Z"
                 }
             }
         }
      })

      opts = OrderedHash.new
      opts[:path] = @temp.join('path1').to_s
      opts[:datetime] = "Apr 18 21:51:31 UTC 2012"
      file_instance1 = FileInstance.new(opts)
      opts[:path] = @temp.join('path2').to_s
      file_instance2 = FileInstance.new(opts)
      file_instance1.diff(file_instance2).should hash_match({
         "path" => {
             "/Users/rnanders/Code/Ruby/moab-versioning/spec/temp/path2" => "/Users/rnanders/Code/Ruby/moab-versioning/spec/temp/path2",
             "/Users/rnanders/Code/Ruby/moab-versioning/spec/temp/path1" => "/Users/rnanders/Code/Ruby/moab-versioning/spec/temp/path1"
         }
      })


       
      # def diff(other)
      #   raise "Cannot compare different classes" if self.class != other.class
      #   left = other.to_hash
      #   right = self.to_hash
      #   if self.key.nil? or other.key.nil?
      #     ltag = :old
      #     rtag = :new
      #   else
      #     ltag = other.key
      #     rtag = self.key
      #   end
      #   Serializable.deep_diff(ltag, left, rtag, right)
      # end
    end
    
    # Unit test for method: {Moab::Serializable#to_json}
    # Which returns: [String] Generate JSON output from a hash of the object's variables
    # For input parameters: (None)
    specify 'Moab::Serializable#to_json' do
     (@v1_content.to_json+"\n").should == <<EOF
{
  "group_id": "content",
  "data_source": "/Users/rnanders/Code/Ruby/moab-versioning/spec/fixtures/data/jq937jp0017/v1/content",
  "file_count": 6,
  "byte_count": 206432,
  "block_count": 203,
  "files": {
    "": {
      "signature": {
        "size": 40873,
        "md5": "1a726cd7963bd6d3ceb10a8c353ec166",
        "sha1": "583220e0572640abcd3ddd97393d224e8053a6ad"
      },
      "instances": {
        "title.jpg": {
          "path": "title.jpg",
          "datetime": "2012-03-26T14:15:11Z"
        }
      }
    }
  }
}
EOF

      #NOTE! the above does not list all the files, only the last file (files overwrite previous)

      # def to_json
      #   hash=self.to_hash
      #   JSON.pretty_generate(hash)
      # end
    end
    
    # Unit test for method: {Moab::Serializable#to_yaml}
    # Which returns: [String] Generate YAML output from a hash of the object's variables
    # For input parameters: (None)
    specify 'Moab::Serializable#to_yaml' do
      @v1_content.to_yaml().gsub(/!omap /,'!omap').should == <<EOF
--- !omap
- group_id: content
- data_source: /Users/rnanders/Code/Ruby/moab-versioning/spec/fixtures/data/jq937jp0017/v1/content
- file_count: 6
- byte_count: 206432
- block_count: 203
- files: !omap
    - ~: !omap
        - signature: !omap
            - size: 40873
            - md5: 1a726cd7963bd6d3ceb10a8c353ec166
            - sha1: 583220e0572640abcd3ddd97393d224e8053a6ad
        - instances: !omap
            - title.jpg: !omap
                - path: title.jpg
                - datetime: "2012-03-26T14:15:11Z"
EOF
      # def to_yaml
      #   self.to_hash.to_yaml
      # end
    end

  end

end
