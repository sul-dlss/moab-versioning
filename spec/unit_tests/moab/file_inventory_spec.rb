require 'spec_helper'

describe 'Moab::FileInventory' do

  describe '.xml_filename' do
    specify 'version' do
      expect(Moab::FileInventory.xml_filename('version')).to eq 'versionInventory.xml'
    end
    specify 'additions' do
      expect(Moab::FileInventory.xml_filename("additions")).to eq 'versionAdditions.xml'
    end
    specify 'manifests' do
      expect(Moab::FileInventory.xml_filename("manifests")).to eq 'manifestInventory.xml'
    end
    specify 'directory' do
      expect(Moab::FileInventory.xml_filename("directory")).to eq 'directoryInventory.xml'
    end
    specify '"other" raises exception' do
      expect { Moab::FileInventory.xml_filename("other") }.to raise_exception(/unknown inventory type/)
    end
  end

  describe '#initialize' do
    specify 'empty options hash' do
      file_inventory = Moab::FileInventory.new({})
      expect(file_inventory.groups).to be_kind_of Array
      expect(file_inventory.groups.size).to eq 0
    end
    specify 'options passed in' do
      opts = {
        type: 'Test type',
        digital_object_id: 'Test digital_object_id',
        version_id: 81,
        inventory_datetime: "Apr 12 19:36:07 UTC 2012"
      }
      file_inventory = Moab::FileInventory.new(opts)
      expect(file_inventory.type).to eq opts[:type]
      expect(file_inventory.digital_object_id).to eq opts[:digital_object_id]
      expect(file_inventory.version_id).to eq opts[:version_id]
      expect(file_inventory.inventory_datetime).to eq "2012-04-12T19:36:07Z"
    end
  end

  describe '.parse sets attributes' do
    let(:parsed_file_inventory) do
      v1_version_inventory = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/manifests/versionInventory.xml')
      fi = Moab::FileInventory.parse(v1_version_inventory.read)
      fi.inventory_datetime = "2012-04-13T13:16:54Z"
      fi
    end

    specify '#type' do
      expect(parsed_file_inventory.type).to eq 'version'
    end

    specify '#digital_object_id' do
      expect(parsed_file_inventory.digital_object_id).to eq 'druid:jq937jp0017'
    end

    specify '#version_id' do
      expect(parsed_file_inventory.version_id).to eq 1
    end

    specify '#composite_key' do
      expect(parsed_file_inventory.composite_key).to eq "druid:jq937jp0017-v0001"
    end

    specify '#inventory_datetime' do
      expect(parsed_file_inventory.inventory_datetime).to eq "2012-04-13T13:16:54Z"
    end

    specify '#file_count' do
      expect(parsed_file_inventory.file_count).to eq 11
    end

    specify '#byte_count' do
      expect(parsed_file_inventory.byte_count).to eq 217820
    end

    specify '#block_count' do
      expect(parsed_file_inventory.block_count).to eq 216
    end

    specify '#groups' do
      expect(parsed_file_inventory.groups.size).to eq 2
    end
  end

  let(:v1_version_inventory) { @fixtures.join('derivatives/ingests/jq937jp0017/v0001/manifests/versionInventory.xml') }
  let(:file_inventory) { Moab::FileInventory.parse(v1_version_inventory.read) }

  specify '#non_empty_groups' do
    expect(file_inventory.groups.size).to eq 2
    expect(file_inventory.group_ids).to eq ["content", "metadata"]
    file_inventory.groups << Moab::FileGroup.new(group_id: 'empty')
    expect(file_inventory.groups.size).to eq 3
    expect(file_inventory.group_ids).to eq ["content", "metadata", "empty"]
    expect(file_inventory.non_empty_groups.size).to eq 2
    expect(file_inventory.group_ids(non_empty=true)).to eq ["content", "metadata"]
  end

  specify '#group' do
    group_id = 'content'
    group = file_inventory.group(group_id)
    expect(group.group_id).to eq group_id
    expect(file_inventory.group('dummy')).to eq nil
  end

  specify '#group_empty?' do
    expect(file_inventory.group_empty?('content')).to eq false
    expect(file_inventory.group_empty?('dummy')).to eq true
  end

  specify '#file_signature' do
    group_id = 'content'
    file_id = 'title.jpg'
    signature = file_inventory.file_signature(group_id, file_id)
    expected_sig_fixity = {
      size: "40873",
      md5: "1a726cd7963bd6d3ceb10a8c353ec166",
      sha1: "583220e0572640abcd3ddd97393d224e8053a6ad",
      sha256: "8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5"
    }
    expect(signature.fixity).to eq expected_sig_fixity
  end

  specify '#copy_ids' do
    new_file_inventory = Moab::FileInventory.new
    new_file_inventory.copy_ids(file_inventory)
    expect(new_file_inventory.digital_object_id).to eq file_inventory.digital_object_id
    expect(new_file_inventory.version_id).to eq file_inventory.version_id
    expect(new_file_inventory.inventory_datetime).to eq file_inventory.inventory_datetime
  end

  specify '#package_id' do
    expect(file_inventory.package_id()).to eq "druid:jq937jp0017-v1"
  end

  specify '#data_source' do
    expect(file_inventory.data_source).to eq "v1"
    directory = @fixtures.join('derivatives/manifests/all')
    directory_inventory = Moab::FileInventory.new(type: 'directory').inventory_from_directory(directory, group_id="mygroup")
    expect(directory_inventory.data_source).to include "derivatives/manifests/all"
  end

  specify '#inventory_from_directory' do
    data_dir_1 = @fixtures.join('data/jq937jp0017/v0001/metadata')
    group_id = 'Test group_id'
    inventory_1 = Moab::FileInventory.new.inventory_from_directory(data_dir_1, group_id)
    expect(inventory_1.groups.size).to eq 1
    expect(inventory_1.groups[0].group_id).to eq group_id
    expect(inventory_1.file_count).to eq 5

    data_dir_2 = @fixtures.join('data/jq937jp0017/v0001')
    inventory_2 = Moab::FileInventory.new.inventory_from_directory(data_dir_2)
    expect(inventory_2.groups.size).to eq 2
    expect(inventory_2.groups[0].group_id).to eq 'content'
    expect(inventory_2.groups[1].group_id).to eq 'metadata'
    expect(inventory_2.file_count).to eq 11
  end

  specify '#inventory_from_bagit_bag' do
    bag_dir = @packages.join('v0001')
    inventory = Moab::FileInventory.new.inventory_from_bagit_bag(bag_dir)
    expect(inventory.groups.size).to eq 2
    expect(inventory.groups.collect { |group| group.group_id }.sort).to eq ['content', 'metadata']
    expect(inventory.file_count).to eq 11
  end

  specify '#signatures_from_bagit_manifests' do
    bag_pathname = @packages.join('v0001')
    signature_for_path = Moab::FileInventory.new.signatures_from_bagit_manifests(bag_pathname)
    expect(signature_for_path.size).to eq 11
    expect(signature_for_path.keys[0]).to eq @packages.join('v0001/data/content/intro-1.jpg')
    expect(signature_for_path[@packages.join('v0001/data/content/page-2.jpg')].md5).to eq "82fc107c88446a3119a51a8663d1e955"
  end

  specify '#human_size' do
    expect(file_inventory.human_size()).to eq "212.71 KB"
  end

  specify '#write_xml_file' do
    parent_dir = @temp.join('parent_dir')
    type = 'Test type'
    expect(Moab::FileInventory).to receive(:write_xml_file).with(file_inventory, parent_dir, type)
    file_inventory.write_xml_file(parent_dir, type)
  end

  describe "#summary_fields" do
    specify '#summary' do
      hash = file_inventory.summary
      expect(hash).to eq({
        "type" => "version",
        "digital_object_id" => "druid:jq937jp0017",
        "version_id" => 1,
        "file_count" => 11,
        "byte_count" => 217820,
        "block_count" => 216,
        "inventory_datetime" => file_inventory.inventory_datetime,
        "groups" =>
          {
            "metadata" =>
              {
                "group_id" => "metadata",
                "file_count" => 5,
                "byte_count" => 11388,
                "block_count" => 13
              },
            "content" =>
              {
                "group_id" => "content",
                "file_count" => 6,
                "byte_count" => 206432,
                "block_count"=>203
              }
          }
        })
    end
    specify '#to_json summary' do
      json = file_inventory.to_json(summary=true)
      expect("#{json}\n").to eq <<-EOF
{
  "type": "version",
  "digital_object_id": "druid:jq937jp0017",
  "version_id": 1,
  "inventory_datetime": "#{file_inventory.inventory_datetime}",
  "file_count": 11,
  "byte_count": 217820,
  "block_count": 216,
  "groups": {
    "content": {
      "group_id": "content",
      "file_count": 6,
      "byte_count": 206432,
      "block_count": 203
    },
    "metadata": {
      "group_id": "metadata",
      "file_count": 5,
      "byte_count": 11388,
      "block_count": 13
    }
  }
}
      EOF
    end
  end
end
