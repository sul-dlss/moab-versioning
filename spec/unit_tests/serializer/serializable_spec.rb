require 'spec_helper'

class MyClass < Serializable
  include HappyMapper

  attribute :my_attr, String
  element :my_element, String

end

# Unit tests for class {Serializer::Serializable}
describe 'Serializer::Serializable' do

  before(:all) do
    @v1_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/manifests/versionInventory.xml')
    @v1_inventory = FileInventory.parse(@v1_inventory_pathname.read)
    @v1_content = @v1_inventory.groups[0]

    @v3_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0003/manifests/versionInventory.xml')
    @v3_inventory = FileInventory.parse(@v3_inventory_pathname.read)
    @v3_content = @v3_inventory.groups[0]
  end
  
  describe '=========================== CLASS METHODS ===========================' do
    
    # Unit test for method: {Serializer::Serializable.deep_diff}
    # Which returns: [OrderedHash] Generate a hash containing the differences between two hashes (recursively descend parallel trees of hashes)
    # For input parameters:
    # * hashes [Array<Hash>] = The hashes to be compared, with optional name tags 
    specify 'Serializer::Serializable.deep_diff' do

      hash1 = @v1_content.files[0].to_hash
      hash3 = @v3_content.files[0].to_hash
      diff = Serializable.deep_diff('v0001',hash1, 'v0003', hash3)
      expect(diff["signature"]).to hash_match({
              "size" => {
                  "v0001" => 41981,
                  "v0003" => 32915
              },
               "md5" => {
                  "v0001" => "915c0305bf50c55143f1506295dc122c",
                  "v0003" => "c1c34634e2f18a354cd3e3e1574c3194"
              },
              "sha1" => {
                  "v0001" => "60448956fbe069979fce6a6e55dba4ce1f915178",
                  "v0003" => "0616a0bd7927328c364b2ea0b4a79c507ce915ed"
              },
              "sha256" => {
                  "v0001" => "4943c6ffdea7e33b74fd7918de900de60e9073148302b0ad1bf5df0e6cec032a",
                  "v0003" => "b78cc53b7b8d9ed86d5e3bab3b699c7ed0db958d4a111e56b6936c8397137de0"
              }
          })
      expect(diff["instances"]["intro-1.jpg"]["v0001"]["path"]).to eq("intro-1.jpg")

      diff = Serializable.deep_diff(hash1, hash3)
      expect(diff["signature"]).to hash_match({
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
            },
            "sha256" => {
                 :left => "4943c6ffdea7e33b74fd7918de900de60e9073148302b0ad1bf5df0e6cec032a",
                :right => "b78cc53b7b8d9ed86d5e3bab3b699c7ed0db958d4a111e56b6936c8397137de0"
            }
        })

      expect{Serializable.deep_diff(hash1)}.to raise_exception


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
    
    # Unit test for constructor: {Serializer::Serializable#initialize}
    # Which returns an instance of: [Serializer::Serializable]
    # For input parameters:
    # * opts [Hash<Symbol,Object>] = a hash containing any number of symbol => value pairs. The symbols should correspond to attributes declared using HappyMapper syntax 
    specify 'Serializer::Serializable#initialize' do
       
      # test initialization with required parameters (if any)
      opts = {}
      serializable = Serializable.new(opts)
      expect(serializable).to be_instance_of(Serializable)
       
      # test initialization with options hash
      opts = OrderedHash.new
      expect{Serializable.new(opts)}.not_to raise_exception
       
     # test initialization with options hash containing a bad variable
      opts = OrderedHash.new
      opts[:dummy] = 'dummy'
      expect{Serializable.new(opts)}.to raise_exception(RuntimeError, 'dummy is not a variable name in Serializer::Serializable')

      # def initialize(opts={})
      #   opts.each do |key, value|
      #     if variable_names.include?(key.to_s) || key == :test
      #       instance_variable_set("@#{key}", value)
      #     else
      #       raise "#{key} is not a variable name in #{self.class.name}"
      #     end
      #   end
      # end
    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do

    # Unit test for method: {Serializer::Serializable#variables}
    # Which returns: [Array] A list of HappyMapper xml attribute, element and text nodes declared for the class
    # For input parameters: (None)
    specify 'Serializer::Serializable#variables' do
      expect(FileInstance.new.variables().size).to eq(2)
      expect(SignatureCatalog.new.variables().size).to eq(7)
      expect(FileSignature.new.variables().size).to eq(4)

      expect(MyClass.new.variables.size).to eq(2)

      # def variables
      #   attributes = self.class.attributes
      #   elements   = self.class.elements
      #   attributes + elements
      #   # text_node enhancement added by unhappymapper, which is not being used
      #   # It enables elements having both attributes and a text value
      #   #text_node = []
      #   #if self.class.instance_variable_defined?("@text_node")
      #   #  text_node << self.class.instance_variable_get("@text_node")
      #   #end
      #   #attributes + elements + text_node
      #   end
      #   attributes + elements + text_node
      # end
    end
    
    # Unit test for method: {Serializer::Serializable#variable_names}
    # Which returns: [Array] Extract the names of the variables
    # For input parameters: (None)
    specify 'Serializer::Serializable#variable_names' do
      expect(FileInstance.new.variable_names()).to eq(["path", "datetime"])
      expect(SignatureCatalog.new.variable_names()).to eq(
          ["digital_object_id", "version_id", "catalog_datetime", "file_count", "byte_count", "block_count", "entries"]
      )
      expect(FileSignature.new.variable_names()).to eq(["size", "md5", "sha1", "sha256"])

      # def variable_names
      #   variables.collect { |variable| variable.name}
      # end
    end
    
    # Unit test for method: {Serializer::Serializable#key_name}
    # Which returns: [String] Determine which attribute was marked as an object instance key. Keys are indicated by option :key=true when declaring the object's variables. This follows the same convention as used by DataMapper
    # For input parameters: (None)
    specify 'Serializer::Serializable#key_name' do
      expect(FileInstance.new.key_name()).to eq("path")
      expect(SignatureCatalog.new.key_name()).to eq("version_id")
      expect(FileSignature.new.key_name()).to eq(nil)

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
    
    # Unit test for method: {Serializer::Serializable#key}
    # Which returns: [String] For the current object instance, return the string to use as a hash key
    # For input parameters: (None)
    specify 'Serializer::Serializable#key' do
      file_instance = FileInstance.new
      expect(file_instance).to receive(:path)
      file_instance.key()
      signature_catalog = SignatureCatalog.new
      expect(signature_catalog).to receive(:version_id)
      signature_catalog.key()
      file_signature = FileSignature.new
      expect(file_signature.key()).to eq(nil)

      # def key
      #   return self.send(key_name) if key_name
      #   nil
      # end
    end
    
    # Unit test for method: {Serializer::Serializable#array_to_hash}
    # Which returns: [OrderedHash] Generate a hash from an array of objects. If the array member has a field tagged as a key, that field will be used as the hash.key. Otherwise the index position of the array member will be used as the key
    # For input parameters:
    # * array [Array] = The array to be converted to a hash 
    specify 'Serializer::Serializable#array_to_hash' do
      array = %w{this is an array of words}
      expect(Serializable.new.array_to_hash(array)).to hash_match({
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
      #     ikey = item.respond_to?(:key) ?  item.key : index
      #     item_hash[ikey] =  item.respond_to?(:to_hash) ? item.to_hash : item
      #   end
      #   item_hash
      # end
    end
    
    # Unit test for method: {Serializer::Serializable#to_hash}
    # Which returns: [OrderedHash] Recursively generate an OrderedHash containing the object's properties
    # For input parameters: (None)
    specify 'Serializer::Serializable#to_hash' do
      additions = FileInventory.read_xml_file(@manifests.join("v0002"),'additions')
      hash = additions.groups[0].to_hash()
      hash['files'][0].delete('instances')
      expect(hash).to hash_match({
             "group_id" => "content",
          "data_source" => "",
           "file_count" => 1,
           "byte_count" => 32915,
          "block_count" => 33,
                "files" => {
              0 => {
                  "signature" => {
                      "size" => 32915,
                       "md5" => "c1c34634e2f18a354cd3e3e1574c3194",
                      "sha1" => "0616a0bd7927328c364b2ea0b4a79c507ce915ed",
                      "sha256" => "b78cc53b7b8d9ed86d5e3bab3b699c7ed0db958d4a111e56b6936c8397137de0"
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
    
    # Unit test for method: {Serializer::Serializable#diff}
    # Which returns: [OrderedHash] Generate a hash containing the differences between two objects of the same type
    # For input parameters:
    # * other [Serializable] = The other object being compared 
    specify 'Serializer::Serializable#diff' do
      diff = @v1_content.files[0].diff(@v3_content.files[0])
      diff.delete('instances')
      expect(diff).to hash_match({
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
             },
             "sha256" => {
                 :old => "b78cc53b7b8d9ed86d5e3bab3b699c7ed0db958d4a111e56b6936c8397137de0",
                 :new => "4943c6ffdea7e33b74fd7918de900de60e9073148302b0ad1bf5df0e6cec032a"
             }
          }
      })

      opts = OrderedHash.new
      opts[:path] = @temp.join('path1').to_s
      opts[:datetime] = "Apr 18 21:51:31 UTC 2012"
      file_instance1 = FileInstance.new(opts)
      opts[:path] = @temp.join('path2').to_s
      file_instance2 = FileInstance.new(opts)
      diff = file_instance1.diff(file_instance2)
      expect(diff.keys[0]).to eq('path')
      expect(diff['path']).to be_instance_of OrderedHash
       
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
    
    # Unit test for method: {Serializer::Serializable#to_json}
    # Which returns: [String] Generate JSON output from a hash of the object's variables
    # For input parameters: (None)
    specify 'Serializer::Serializable#to_json' do
      #puts JSON.pretty_generate(@v1_content.to_hash)
     expect((@v1_content.to_json+"\n").gsub(/"datetime": ".*?"/, '"datetime": ""').gsub(/: ".*moab-versioning/,': "moab-versioning')).to eq <<EOF
{
  "group_id": "content",
  "data_source": "moab-versioning/spec/fixtures/data/jq937jp0017/v0001/content",
  "file_count": 6,
  "byte_count": 206432,
  "block_count": 203,
  "files": {
    "0": {
      "signature": {
        "size": 41981,
        "md5": "915c0305bf50c55143f1506295dc122c",
        "sha1": "60448956fbe069979fce6a6e55dba4ce1f915178",
        "sha256": "4943c6ffdea7e33b74fd7918de900de60e9073148302b0ad1bf5df0e6cec032a"
      },
      "instances": {
        "intro-1.jpg": {
          "path": "intro-1.jpg",
          "datetime": ""
        }
      }
    },
    "1": {
      "signature": {
        "size": 39850,
        "md5": "77f1a4efdcea6a476505df9b9fba82a7",
        "sha1": "a49ae3f3771d99ceea13ec825c9c2b73fc1a9915",
        "sha256": "3a28718a8867e4329cd0363a84aee1c614d0f11229a82e87c6c5072a6e1b15e7"
      },
      "instances": {
        "intro-2.jpg": {
          "path": "intro-2.jpg",
          "datetime": ""
        }
      }
    },
    "2": {
      "signature": {
        "size": 25153,
        "md5": "3dee12fb4f1c28351c7482b76ff76ae4",
        "sha1": "906c1314f3ab344563acbbbe2c7930f08429e35b",
        "sha256": "41aaf8598c9d8e3ee5d55efb9be11c542099d9f994b5935995d0abea231b8bad"
      },
      "instances": {
        "page-1.jpg": {
          "path": "page-1.jpg",
          "datetime": ""
        }
      }
    },
    "3": {
      "signature": {
        "size": 39450,
        "md5": "82fc107c88446a3119a51a8663d1e955",
        "sha1": "d0857baa307a2e9efff42467b5abd4e1cf40fcd5",
        "sha256": "235de16df4804858aefb7690baf593fb572d64bb6875ec522a4eea1f4189b5f0"
      },
      "instances": {
        "page-2.jpg": {
          "path": "page-2.jpg",
          "datetime": ""
        }
      }
    },
    "4": {
      "signature": {
        "size": 19125,
        "md5": "a5099878de7e2e064432d6df44ca8827",
        "sha1": "c0ccac433cf02a6cee89c14f9ba6072a184447a2",
        "sha256": "7bd120459eff0ecd21df94271e5c14771bfca5137d1dd74117b6a37123dfe271"
      },
      "instances": {
        "page-3.jpg": {
          "path": "page-3.jpg",
          "datetime": ""
        }
      }
    },
    "5": {
      "signature": {
        "size": 40873,
        "md5": "1a726cd7963bd6d3ceb10a8c353ec166",
        "sha1": "583220e0572640abcd3ddd97393d224e8053a6ad",
        "sha256": "8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5"
      },
      "instances": {
        "title.jpg": {
          "path": "title.jpg",
          "datetime": ""
        }
      }
    }
  }
}
EOF
    end

  end

end
