# frozen_string_literal: true

describe Serializer::Serializable do
  let(:v1_content) do
    v1_inventory_pathname = fixtures_dir.join('derivatives/ingests/jq937jp0017/v0001/manifests/versionInventory.xml')
    v1_inventory = Moab::FileInventory.parse(v1_inventory_pathname.read)
    v1_inventory.groups[0]
  end
  let(:v3_content) do
    v3_inventory_pathname = fixtures_dir.join('derivatives/ingests/jq937jp0017/v0003/manifests/versionInventory.xml')
    v3_inventory = Moab::FileInventory.parse(v3_inventory_pathname.read)
    v3_inventory.groups[0]
  end

  describe '.deep_diff' do
    let(:hash1) { v1_content.files[0].to_hash }
    let(:hash3) { v3_content.files[0].to_hash }

    context 'with names provided' do
      let(:expected_signature_deep_diff) do
        {
          'size' => {
            'v0001' => 41981,
            'v0003' => 32915
          },
          'md5' => {
            'v0001' => '915c0305bf50c55143f1506295dc122c',
            'v0003' => 'c1c34634e2f18a354cd3e3e1574c3194'
          },
          'sha1' => {
            'v0001' => '60448956fbe069979fce6a6e55dba4ce1f915178',
            'v0003' => '0616a0bd7927328c364b2ea0b4a79c507ce915ed'
          },
          'sha256' => {
            'v0001' => '4943c6ffdea7e33b74fd7918de900de60e9073148302b0ad1bf5df0e6cec032a',
            'v0003' => 'b78cc53b7b8d9ed86d5e3bab3b699c7ed0db958d4a111e56b6936c8397137de0'
          }
        }
      end

      it 'uses provided names as keys' do
        diff = described_class.deep_diff('v0001', hash1, 'v0003', hash3)
        expect(diff['signature']).to match(expected_signature_deep_diff)
        expect(diff['instances']['intro-1.jpg']['v0001']['path']).to eq('intro-1.jpg')
      end
    end

    context 'without names provided' do
      let(:expected_signature_deep_diff) do
        {
          'size' => {
            left: 41981,
            right: 32915
          },
          'md5' => {
            left: '915c0305bf50c55143f1506295dc122c',
            right: 'c1c34634e2f18a354cd3e3e1574c3194'
          },
          'sha1' => {
            left: '60448956fbe069979fce6a6e55dba4ce1f915178',
            right: '0616a0bd7927328c364b2ea0b4a79c507ce915ed'
          },
          'sha256' => {
            left: '4943c6ffdea7e33b74fd7918de900de60e9073148302b0ad1bf5df0e6cec032a',
            right: 'b78cc53b7b8d9ed86d5e3bab3b699c7ed0db958d4a111e56b6936c8397137de0'
          }
        }
      end

      it 'uses left and right as keys' do
        diff = described_class.deep_diff(hash1, hash3)
        expect(diff['signature']).to match(expected_signature_deep_diff)
      end
    end

    it 'single argument raises ArgumentError' do
      expect { described_class.deep_diff(hash1) }.to raise_exception ArgumentError
    end
  end

  describe '#initialize' do
    context 'with empty options hash' do
      it 'does not raise exception' do
        expect { described_class.new({}) }.not_to raise_exception
      end
    end

    context 'with options hash containing unknown key' do
      it 'raises exception' do
        opts = { dummy: 'dummy' }
        err_msg = 'dummy is not a variable name in Serializer::Serializable'
        expect { described_class.new(opts) }.to raise_exception(Moab::MoabRuntimeError, err_msg)
      end
    end
  end

  describe '#variables' do
    context 'when class has HappyMapper::Attributes or ::Elements' do
      it 'FileInstance has 2' do
        expect(Moab::FileInstance.new.variables.first).to be_instance_of(HappyMapper::Attribute)
        expect(Moab::FileInstance.new.variables.size).to eq(2)
      end

      it 'SignatureCatalog has 7' do
        expect(Moab::FileInstance.new.variables.first).to be_instance_of(HappyMapper::Attribute)
        expect(Moab::SignatureCatalog.new.variables.size).to eq(7)
      end

      it 'FileSignature has 4' do
        expect(Moab::FileInstance.new.variables.first).to be_instance_of(HappyMapper::Attribute)
        expect(Moab::FileSignature.new.variables.size).to eq(4)
      end
    end

    context 'when subclass has attribute and element' do
      it 'contains the attribute and the element' do
        expect(Moab::FileInstance.new.variables.first).to be_instance_of(HappyMapper::Attribute)
        expect(Moab::FileInstance.new.variables.last).to be_instance_of(HappyMapper::Attribute)
        expect(TestSubClass.new.variables.size).to eq(2) # class defined below
      end
    end
  end

  describe '#variable_names' do
    context 'when class has HappyMapper::Attributes or ::Elements' do
      it 'is correct for FileInstance' do
        expect(Moab::FileInstance.new.variable_names).to eq(%w[path datetime])
      end

      it 'is correct for SignatureCatalog' do
        expect(Moab::SignatureCatalog.new.variable_names).to eq(
          %w[digital_object_id version_id catalog_datetime file_count byte_count block_count entries]
        )
      end

      it 'is correct for FileSignature' do
        expect(Moab::FileSignature.new.variable_names).to eq(%w[size md5 sha1 sha256])
      end
    end
  end

  describe '#key_name' do
    context 'when class has HappyMapper::Attribute or ::Element declared with key=true' do
      it 'returns the name of the attribute' do
        expect(Moab::FileInstance.new.key_name).to eq('path')
        expect(Moab::SignatureCatalog.new.key_name).to eq('version_id')
      end
    end

    context 'when class has no HappyMapper::Attribute declared with key=true' do
      it 'is nil' do
        expect(Moab::FileSignature.new.key_name).to be_nil
      end
    end
  end

  describe '#key' do
    context 'when class has HappyMapper::Attribute declared with key=true' do
      it 'will return the value of the key attribute' do
        file_instance = Moab::FileInstance.new
        expect(file_instance).to receive(:path)
        file_instance.key

        signature_catalog = Moab::SignatureCatalog.new
        expect(signature_catalog).to receive(:version_id)
        signature_catalog.key
      end
    end

    context 'when class has no HappyMapper::Attribute declared with key=true' do
      it 'returns nil' do
        file_signature = Moab::FileSignature.new
        expect(file_signature.key).to be_nil
      end
    end
  end

  describe '#array_to_hash' do
    let(:array) { %w[this is an array of words] }
    let(:expected_hash) do
      {
        0 => 'this',
        1 => 'is',
        2 => 'an',
        3 => 'array',
        4 => 'of',
        5 => 'words'
      }
    end

    it 'creates hash with index as the key and the array values as the hash values' do
      expect(described_class.new.array_to_hash(array)).to match(expected_hash)
    end
  end

  describe '#to_hash' do
    let(:method_call_hash) do
      additions = Moab::FileInventory.read_xml_file(manifests_dir.join('v0002'), 'additions')
      additions.groups[0].to_hash
    end
    let(:expected_hash) do
      {
        'group_id' => 'content',
        'data_source' => '',
        'file_count' => 1,
        'byte_count' => 32915,
        'block_count' => 33,
        'files' => {
          0 => {
            'signature' => {
              'size' => 32915,
              'md5' => 'c1c34634e2f18a354cd3e3e1574c3194',
              'sha1' => '0616a0bd7927328c364b2ea0b4a79c507ce915ed',
              'sha256' => 'b78cc53b7b8d9ed86d5e3bab3b699c7ed0db958d4a111e56b6936c8397137de0'
            }
          }
        }
      }
    end

    it "recursively generates a Hash containing the object's properties" do
      method_call_hash['files'][0].delete('instances') # adjust for testability
      expect(method_call_hash).to match(expected_hash)
    end
  end

  describe '#diff' do
    context 'when comparing files on disk' do
      let(:method_call_diff) { v1_content.files[0].diff(v3_content.files[0]) }
      let(:expected_diff) do
        {
          'signature' => {
            'size' => {
              old: 32915,
              new: 41981
            },
            'md5' => {
              old: 'c1c34634e2f18a354cd3e3e1574c3194',
              new: '915c0305bf50c55143f1506295dc122c'
            },
            'sha1' => {
              old: '0616a0bd7927328c364b2ea0b4a79c507ce915ed',
              new: '60448956fbe069979fce6a6e55dba4ce1f915178'
            },
            'sha256' => {
              old: 'b78cc53b7b8d9ed86d5e3bab3b699c7ed0db958d4a111e56b6936c8397137de0',
              new: '4943c6ffdea7e33b74fd7918de900de60e9073148302b0ad1bf5df0e6cec032a'
            }
          }
        }
      end

      it 'returns hash containing differences between "old" and "new" files' do
        method_call_diff.delete('instances') # adjust for testability
        expect(method_call_diff).to match(expected_diff)
      end
    end

    context 'when comparing Moab::FileInstance objects' do
      let(:opts) { { path: temp_dir.join('path1').to_s, datetime: 'Apr 18 21:51:31 UTC 2012' } }
      let(:file_instance1) { Moab::FileInstance.new(opts) }
      let(:file_instance2) do
        opts[:path] = temp_dir.join('path2').to_s
        Moab::FileInstance.new(opts)
      end

      it 'returns hash containing differences between "old" and "new" files' do
        diff = file_instance1.diff(file_instance2)
        expect(diff.keys.size).to eq 1
        expect(diff.keys[0]).to eq('path')
        expect(diff['path']).to be_instance_of Hash
      end
    end
  end

  describe '#to_json' do
    let(:adjusted_v1_content) do
      v1_content.to_json.gsub(/"datetime": ".*?"/, '"datetime": ""')
                .gsub(/: ".*moab-versioning/, ': "moab-versioning')
                .gsub('/home/circleci/project', 'moab-versioning') + "\n"
    end
    let(:expected_json) do
      <<~JSON
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

    it 'creates the expected JSON' do
      expect(adjusted_v1_content).to eq expected_json
    end
  end
end

class TestSubClass < Serializer::Serializable
  include HappyMapper

  attribute :my_attr, String
  element :my_element, String
end
