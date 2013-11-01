require 'spec_helper'

# Unit tests for class {Moab::FileInventory}
describe 'Moab::FileInventory' do
  
  describe '=========================== CLASS METHODS ===========================' do
    
    # Unit test for method: {Moab::FileInventory.xml_filename}
    # Which returns: [String] The standard name for the serialized inventory file of the given type
    # For input parameters:
    # * type [String] = Specifies the type of inventory, and thus the filename used for storage 
    specify 'Moab::FileInventory.xml_filename' do
      Moab::FileInventory.xml_filename('version').should == 'versionInventory.xml'
      Moab::FileInventory.xml_filename("additions").should == 'versionAdditions.xml'
      Moab::FileInventory.xml_filename("manifests").should == 'manifestInventory.xml'
      Moab::FileInventory.xml_filename("directory").should == 'directoryInventory.xml'
      lambda{Moab::FileInventory.xml_filename("other")}.should raise_exception
      # def self.xml_filename(type=nil)
      #   case type
      #     when "version"
      #       'versionInventory.xml'
      #     when "additions"
      #       'versionAdditions.xml'
      #     when "manifests"
      #       'manifestInventory.xml'
      #     when "directory"
      #       'directoryInventory.xml'
      #     else
      #       raise "unknown inventory type: #{filename.to_s}"
      #   end
      # end
    end
  
  end
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Moab::FileInventory#initialize}
    # Which returns an instance of: [Moab::FileInventory]
    # For input parameters:
    # * opts [Hash<Symbol,Object>] = a hash containing any number of symbol => value pairs. The symbols should correspond to attributes declared using HappyMapper syntax 
    specify 'Moab::FileInventory#initialize' do
       
      # test initialization with required parameters (if any)
      opts = {}
      file_inventory = FileInventory.new(opts)
      file_inventory.should be_instance_of(FileInventory)
       
      # test initialization of arrays and hashes
      file_inventory.groups.should be_kind_of(Array)
      file_inventory.groups.size.should == 0

      # test initialization with options hash
      opts = OrderedHash.new
      opts[:type] = 'Test type'
      opts[:digital_object_id] = 'Test digital_object_id'
      opts[:version_id] = 81
      opts[:inventory_datetime] = "Apr 12 19:36:07 UTC 2012"
      file_inventory = FileInventory.new(opts)
      file_inventory.type.should == opts[:type]
      file_inventory.digital_object_id.should == opts[:digital_object_id]
      file_inventory.version_id.should == opts[:version_id]
      file_inventory.inventory_datetime.should == "2012-04-12T19:36:07Z"

      # def initialize(opts={})
      #   @groups = Array.new
      #   @inventory_datetime = Time.now
      #   super(opts)
      # end
    end
  
  end
  
  describe '=========================== INSTANCE ATTRIBUTES ===========================' do
    
    before(:all) do
      @v1_version_inventory = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/manifests/versionInventory.xml')
      @file_inventory = FileInventory.parse(@v1_version_inventory.read)
      @file_inventory.inventory_datetime = "2012-04-13T13:16:54Z"
    end
    
    # Unit test for attribute: {Moab::FileInventory#type}
    # Which stores: [String] \@type = The type of inventory (version|additions|manifests|directory)
    specify 'Moab::FileInventory#type' do
      @file_inventory.type.should == 'version'
       
      # attribute :type, String
    end
    
    # Unit test for attribute: {Moab::FileInventory#digital_object_id}
    # Which stores: [String] \@objectId = The digital object identifier (druid)
    specify 'Moab::FileInventory#digital_object_id' do
       @file_inventory.digital_object_id.should == 'druid:jq937jp0017'
       
      # attribute :digital_object_id, String, :tag => 'objectId'
    end
    
    # Unit test for attribute: {Moab::FileInventory#version_id}
    # Which stores: [Integer] \@versionId = The ordinal version number
    specify 'Moab::FileInventory#version_id' do
      @file_inventory.version_id.should == 1
       
      # attribute :version_id, Integer, :tag => 'versionId', :key => true, :on_save => Proc.new {|n| n.to_s}
    end

    specify 'Moab::FileInventory#composite_key' do
      @file_inventory.composite_key.should == "druid:jq937jp0017-v0001"
    end

    # Unit test for attribute: {Moab::FileInventory#inventory_datetime}
    # Which stores: [Time] \@inventoryDatetime = The datetime at which the inventory was created
    specify 'Moab::FileInventory#inventory_datetime' do
      @file_inventory.inventory_datetime.should == "2012-04-13T13:16:54Z"
       
      # def inventory_datetime=(datetime)
      #   @inventory_datetime=Time.input(datetime)
      # end
       
      # def inventory_datetime
      #   Time.output(@inventory_datetime)
      # end
    end
    
    # Unit test for attribute: {Moab::FileInventory#file_count}
    # Which stores: [Integer] \@fileCount = The total number of data files in the inventory
    specify 'Moab::FileInventory#file_count' do
      @file_inventory.file_count.should == 11
       
      # attribute :file_count, Integer, :tag => 'fileCount', :on_save => Proc.new {|t| t.to_s}
       
      # def file_count
      #   groups.inject(0) { |sum, group| sum + group.file_count }
      # end
    end
    
    # Unit test for attribute: {Moab::FileInventory#byte_count}
    # Which stores: [Integer] \@byteCount = The total number of bytes in all files of all files in the inventory
    specify 'Moab::FileInventory#byte_count' do
      @file_inventory.byte_count.should == 217820
       
      # attribute :byte_count, Integer, :tag => 'byteCount', :on_save => Proc.new {|t| t.to_s}
       
      # def byte_count
      #   groups.inject(0) { |sum, group| sum + group.byte_count }
      # end
    end
    
    # Unit test for attribute: {Moab::FileInventory#block_count}
    # Which stores: [Integer] \@blockCount = The total disk usage (in 1 kB blocks) of all data files (estimating du -k result)
    specify 'Moab::FileInventory#block_count' do
      @file_inventory.block_count.should == 216
       
      # attribute :block_count, Integer, :tag => 'blockCount', :on_save => Proc.new {|t| t.to_s}
       
      # def block_count
      #   groups.inject(0) { |sum, group| sum + group.block_count }
      # end
    end
    
    # Unit test for attribute: {Moab::FileInventory#groups}
    # Which stores: [Array<FileGroup>] \[<fileGroup>] = The set of data groups comprising the version
    specify 'Moab::FileInventory#groups' do
      @file_inventory.groups.size.should == 2
       
      # has_many :groups, FileGroup
    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do
    
    before(:all) do
      @v1_version_inventory = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/manifests/versionInventory.xml')
      @file_inventory = FileInventory.parse(@v1_version_inventory.read)
    end
    
    specify 'Moab::FileInventory#non_empty_groups' do
      inventory = FileInventory.parse(@v1_version_inventory.read)
      inventory.groups.size.should == 2
      inventory.group_ids.should == ["content", "metadata"]
      inventory.groups << FileGroup.new(:group_id => 'empty')
      inventory.groups.size.should == 3
      inventory.group_ids.should == ["content", "metadata", "empty"]
      inventory.non_empty_groups.size.should == 2
      inventory.group_ids(non_empty=true).should == ["content", "metadata"]
    end

    # Unit test for method: {Moab::FileInventory#group}
    # Which returns: [FileGroup] The file group in this inventory for the specified group_id
    # For input parameters:
    # * group_id [String] = The identifer of the group to be selected
    specify 'Moab::FileInventory#group' do
      group_id = 'content'
      group = @file_inventory.group(group_id)
      group.group_id.should == group_id
      @file_inventory.group('dummy').should == nil
    end

    specify 'Moab::FileInventory#group_empty?' do
      @file_inventory.group_empty?('content').should == false
      @file_inventory.group_empty?('dummy').should == true
    end

    # Unit test for method: {Moab::FileInventory#file_signature}
    # Which returns: [FileSignature] The signature of the specified file
    # For input parameters:
    # * group_id [String] = The identifer of the group to be selected
    # * file_id [String] = The group-relative path of the file (relative to the appropriate home directory)
    specify 'Moab::FileInventory#file_signature' do
      group_id = 'content'
      file_id = 'title.jpg'
      signature = @file_inventory.file_signature(group_id, file_id)
      signature.fixity.should == {:size=>"40873", :md5=>"1a726cd7963bd6d3ceb10a8c353ec166", :sha1=>"583220e0572640abcd3ddd97393d224e8053a6ad", :sha256=>"8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5"}

      # def file_signature(group_id, file_id)
      #   file_group = group(group_id)
      #   file_signature = file_group.path_hash[file_id]
      #   raise "#{group_id} file #{file_id} not found for #{@digital_object_id} - #{@version_id}" if file_signature.nil?
      #   file_signature
      # end
    end

    # Unit test for method: {Moab::FileInventory#copy_ids}
    # Which returns: [void] Copy objectId and versionId values from another class instance into this instance
    # For input parameters:
    # * other [FileInventory] = another instance of this class from which to clone identity values 
    specify 'Moab::FileInventory#copy_ids' do
      new_file_inventory = FileInventory.new
      new_file_inventory.copy_ids(@file_inventory)
      new_file_inventory.digital_object_id.should == @file_inventory.digital_object_id
      new_file_inventory.version_id.should == @file_inventory.version_id
      new_file_inventory.inventory_datetime.should == @file_inventory.inventory_datetime

      # def copy_ids(other)
      #   @digital_object_id = other.digital_object_id
      #   @version_id = other.version_id
      #   @inventory_datetime = other.inventory_datetime

      # end
    end
    
    # Unit test for method: {Moab::FileInventory#package_id}
    # Which returns: [String] Concatenation of the objectId and versionId values
    # For input parameters: (None)
    specify 'Moab::FileInventory#package_id' do
      @file_inventory.package_id().should == "druid:jq937jp0017-v1"
       
      # def package_id
      #   "#{@digital_object_id}-v#{@version_id}"
      # end
    end

    # Unit test for method: {Moab::FileInventory#data_source}
    # Which returns: [String] Returns either the version ID (if inventory is a version manifest) or the name of the directory that was harvested to create the inventory
    # For input parameters: (None)
    specify 'Moab::FileInventory#data_source' do
      @file_inventory.data_source.should == "v1"
      directory = @fixtures.join('derivatives/manifests/all')
      directory_inventory = FileInventory.new(:type=>'directory').inventory_from_directory(directory,group_id="mygroup")
      directory_inventory.data_source.should include "derivatives/manifests/all"

      # def data_source
      #   if version_id
      #     "v#{version_id.to_s}"
      #   else
      #     (groups.collect { |g| g.data_source.to_s }).join('|')
      #   end
      # end
    end

    # Unit test for method: {Moab::FileInventory#inventory_from_directory}
    # Which returns: [FileInventory] Traverse a directory and return an inventory of the files it contains
    # For input parameters:
    # * data_dir [Pathname, String] = The location of files to be inventoried
    # * group_id [String] = if specified, is used to set the group ID of the FileGroup created from the directory if nil, then the directory is assumed to contain both content and metadata subdirectories 
    specify 'Moab::FileInventory#inventory_from_directory' do
      data_dir_1 = @fixtures.join('data/jq937jp0017/v0001/metadata')
      group_id = 'Test group_id'
      inventory_1 = FileInventory.new.inventory_from_directory(data_dir_1,group_id)
      inventory_1.groups.size.should == 1
      inventory_1.groups[0].group_id.should == group_id
      inventory_1.file_count.should == 5

      data_dir_2 = @fixtures.join('data/jq937jp0017/v0001')
      inventory_2 = FileInventory.new.inventory_from_directory(data_dir_2)
      inventory_2.groups.size.should == 2
      inventory_2.groups[0].group_id.should == 'content'
      inventory_2.groups[1].group_id.should == 'metadata'
      inventory_2.file_count.should == 11

      # def inventory_from_directory(data_dir,group_id=nil)
      #   if group_id
      #     @groups << FileGroup.new(:group_id=>group_id).group_from_directory(data_dir)
      #   else
      #     ['content','metadata'].each do |group_id|
      #       @groups << FileGroup.new(:group_id=>group_id).group_from_directory(Pathname(data_dir).join(group_id))
      #     end
      #   end
      #   self
      # end
    end

    # Unit test for method: {Moab::FileInventory#inventory_from_bagit_bag}
    # Which returns: [FileInventory] Traverse a BagIt bag and return an inventory of the files it contains
    # For input parameters:
    # * bag_dir [Pathname, String] = The location of files to be inventoried
    specify 'Moab::FileInventory#inventory_from_bagit_bag' do
      bag_dir = @packages.join('v0001')
      inventory = FileInventory.new.inventory_from_bagit_bag(bag_dir)
      inventory.groups.size.should == 2
      inventory.groups.collect{|group| group.group_id}.sort.should == ['content','metadata']
      inventory.file_count.should == 11

      #def inventory_from_bagit_bag(bag_dir)
      #  bag_pathname = Pathname(bag_dir)
      #  bag_digests = digests_from_bagit_bag(bag_pathname)
      #  bag_data_subdirs = bag_pathname.join('data').children
      #  bag_data_subdirs.each do |subdir|
      #    @groups << FileGroup.new(:group_id=>subdir.basename).group_from_directory_digests(subdir, bag_digests)
      #  end
      #  self
      #end
    end

    # Unit test for method: {Moab::FileInventory#signatures_from_bagit_manifests}
    # Which returns: [Hash<Pathname,FileSignature>] Parse BagIt manifests and return an hash of the fixity data it contains
    # For input parameters:
    # * bag_dir [Pathname, String] = The location of the BagIt bag
    specify 'Moab::FileInventory#signatures_from_bagit_manifests' do
      bag_pathname = @packages.join('v0001')
      signature_for_path = FileInventory.new.signatures_from_bagit_manifests(bag_pathname)
      signature_for_path.size.should == 11
      signature_for_path.keys[0].should == @packages.join('v0001/data/content/intro-1.jpg')
      signature_for_path[@packages.join('v0001/data/content/page-2.jpg')].md5.should == "82fc107c88446a3119a51a8663d1e955"
      end

    
    # Unit test for method: {Moab::FileInventory#human_size}
    # Which returns: [String] The total size of the inventory expressed in KB, MB, GB or TB, depending on the magnitutde of the value
    # For input parameters: (None)
    specify 'Moab::FileInventory#human_size' do
      @file_inventory.human_size().should == "212.71 KB"
       
      # def human_size
      #   count = 0
      #   size = byte_count
      #   while size >= 1024 and count < 4
      #     size /= 1024.0
      #     count += 1
      #   end
      #   if count == 0
      #     sprintf("%d B", size)
      #   else
      #     sprintf("%.2f %s", size, %w[B KB MB GB TB][count])
      #   end
      # end
    end
    
    # Unit test for method: {Moab::FileInventory#write_xml_file}
    # Which returns: [void] write the {FileInventory} instance to a file
    # For input parameters:
    # * parent_dir [Pathname, String] = The parent directory in which the xml file is to be stored 
    # * type [String] = The inventory type, which governs the filename used for serialization 
    specify 'Moab::FileInventory#write_xml_file' do
      parent_dir = @temp.join('parent_dir')
      type = 'Test type'
      FileInventory.should_receive(:write_xml_file).with(@file_inventory, parent_dir, type)
      @file_inventory.write_xml_file(parent_dir, type)
       
      # def write_xml_file(parent_dir, type=nil)
      #   type = @type if type.nil?
      #   self.class.write_xml_file(self, parent_dir, type)
      # end
    end

    # Unit test for method: {Moab::FileInventory#summary_fields hash/json}
    specify "Moab::FileInventory#summary_fields" do
      hash = @file_inventory.summary
      hash.should == {
          "type"=>"version",
          "digital_object_id"=>"druid:jq937jp0017",
          "version_id"=>1,
          "file_count"=>11,
          "byte_count"=>217820,
          "block_count"=>216,
          "inventory_datetime"=>"#{@file_inventory.inventory_datetime}",
          "groups" => {"metadata"=> {"group_id"=>"metadata", "file_count"=>5, "byte_count"=>11388, "block_count"=>13},
                      "content"=> {"group_id"=>"content", "file_count"=>6, "byte_count"=>206432, "block_count"=>203}}
      }
      hash["type"].should == "version"
      hash["groups"]["metadata"]["file_count"].should == 5

      json = @file_inventory.to_json(summary=true)
      "#{json}\n".should == <<-EOF
{
  "type": "version",
  "digital_object_id": "druid:jq937jp0017",
  "version_id": 1,
  "inventory_datetime": "#{@file_inventory.inventory_datetime}",
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
