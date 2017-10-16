require 'spec_helper'

describe 'Serializer::Serializable' do

  before(:all) do
    v1_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/manifests/versionInventory.xml')
    v1_inventory = Moab::FileInventory.parse(v1_inventory_pathname.read)
    @v1_content = v1_inventory.groups[0]

    v3_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0003/manifests/versionInventory.xml')
    v3_inventory = Moab::FileInventory.parse(v3_inventory_pathname.read)
    @v3_content = v3_inventory.groups[0]
  end

  context '.deep_diff' do
    let(:hash1) { @v1_content.files[0].to_hash }
    let(:hash3) { @v3_content.files[0].to_hash }

    it 'specified versions' do
      diff = Serializer::Serializable.deep_diff('v0001',hash1, 'v0003', hash3)
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
    end

    it 'no versions specified' do
      diff = Serializer::Serializable.deep_diff(hash1, hash3)
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
    end

    it 'single argument raises ArgumentError' do
      expect{Serializer::Serializable.deep_diff(hash1)}.to raise_exception ArgumentError
    end
  end

  context '#initialize' do
    it 'empty options Hash does not raise exception' do
      expect{Serializer::Serializable.new(Hash.new)}.not_to raise_exception
    end

    it 'options hash with bad variable raises exception' do
      opts = { dummy: 'dummy' }
      err_msg = 'dummy is not a variable name in Serializer::Serializable'
      expect{Serializer::Serializable.new(opts)}.to raise_exception(RuntimeError, err_msg)
    end
  end

  context '#variables' do
    it 'FileInstance has 2' do
      expect(Moab::FileInstance.new.variables().size).to eq(2)
    end
    it 'SignatureCatalog has 7' do
      expect(Moab::SignatureCatalog.new.variables().size).to eq(7)
    end
    it 'FileSignature has 4' do
      expect(Moab::FileSignature.new.variables().size).to eq(4)
    end
    it 'subclass has attributes and elements' do
      class MyClass < Serializer::Serializable
        include HappyMapper

        attribute :my_attr, String
        element :my_element, String
      end
      expect(MyClass.new.variables.size).to eq(2)
    end
  end

  context '#variable_names' do
    it 'FileInstance' do
      expect(Moab::FileInstance.new.variable_names()).to eq(["path", "datetime"])
    end
    it 'SignatureCatalog' do
      expect(Moab::SignatureCatalog.new.variable_names()).to eq(
          ["digital_object_id", "version_id", "catalog_datetime", "file_count", "byte_count", "block_count", "entries"]
      )
    end
    it 'FileSignature' do
      expect(Moab::FileSignature.new.variable_names()).to eq(["size", "md5", "sha1", "sha256"])
    end
  end

  context '#key_name' do
    it 'path for FileInstance' do
      expect(Moab::FileInstance.new.key_name()).to eq("path")
    end
    it 'version_id for SignatureCatalog' do
      expect(Moab::SignatureCatalog.new.key_name()).to eq("version_id")
    end
    it 'nil for FileSignature' do
      expect(Moab::FileSignature.new.key_name()).to eq(nil)
    end
  end

  context '#key' do
    it 'FileInstance' do
      file_instance = Moab::FileInstance.new
      expect(file_instance).to receive(:path)
      file_instance.key()
    end
    it 'SignatureCatalog' do
      signature_catalog = Moab::SignatureCatalog.new
      expect(signature_catalog).to receive(:version_id)
      signature_catalog.key()
    end
    it 'FileSignature key is nil' do
      file_signature = Moab::FileSignature.new
      expect(file_signature.key()).to eq(nil)
    end
  end

  specify '#array_to_hash' do
    array = %w{this is an array of words}
    expect(Serializer::Serializable.new.array_to_hash(array)).to hash_match({
        0 => "this",
        1 => "is",
        2 => "an",
        3 => "array",
        4 => "of",
        5 => "words"
    })
  end

  specify '#to_hash' do
    additions = Moab::FileInventory.read_xml_file(@manifests.join("v0002"),'additions')
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
  end

  context '#diff' do
    it 'file read from disk' do
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
    end
    it 'FileInstance diff' do
      opts = { path: @temp.join('path1').to_s, datetime: "Apr 18 21:51:31 UTC 2012" }
      file_instance1 = Moab::FileInstance.new(opts)
      opts[:path] = @temp.join('path2').to_s
      file_instance2 = Moab::FileInstance.new(opts)
      diff = file_instance1.diff(file_instance2)
      expect(diff.keys[0]).to eq('path')
      expect(diff['path']).to be_instance_of Hash
    end
  end

  specify '#to_json' do
    adj_v1_content = @v1_content.to_json
                      .gsub(/"datetime": ".*?"/, '"datetime": ""')
                      .gsub(/: ".*moab-versioning/, ': "moab-versioning') + "\n"
    expect(adj_v1_content).to eq <<JSON
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
JSON
  end
end
