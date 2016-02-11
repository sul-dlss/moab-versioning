require 'spec_helper'

# Unit tests for class {Stanford::DorMetadata}
describe 'Stanford::DorMetadata' do
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Stanford::DorMetadata#initialize}
    # Which returns an instance of: [Stanford::DorMetadata]
    # For input parameters:
    # * digital_object_id [String] = The digital object identifier 
    # * version_id [Integer] = The ordinal version number 
    specify 'Stanford::DorMetadata#initialize' do
       
      # test initialization with required parameters (if any)
      digital_object_id = 'Test digital_object_id' 
      version_id = 68 
      dor_metadata = Stanford::DorMetadata.new(digital_object_id, version_id)
      expect(dor_metadata).to be_instance_of(Stanford::DorMetadata)
      expect(dor_metadata.digital_object_id).to eq(digital_object_id)
      expect(dor_metadata.version_id).to eq(version_id)
       
      # def initialize(digital_object_id, version_id=nil)
      #   @digital_object_id = digital_object_id
      #   @version_id = version_id
      # end
    end
  
  end
  
  describe '=========================== INSTANCE ATTRIBUTES ===========================' do
    
    before(:all) do
      digital_object_id = 'Test digital_object_id' 
      version_id = 27 
      @dor_metadata = Stanford::DorMetadata.new(digital_object_id, version_id)
    end
    
    # Unit test for attribute: {Stanford::DorMetadata#digital_object_id}
    # Which stores: [String] The digital object identifier (druid)
    specify 'Stanford::DorMetadata#digital_object_id' do
      value = 'Test digital_object_id'
      @dor_metadata.digital_object_id= value
      expect(@dor_metadata.digital_object_id).to eq(value)
       
      # def digital_object_id=(value)
      #   @digital_object_id = value
      # end
       
      # def digital_object_id
      #   @digital_object_id
      # end
    end
    
    # Unit test for attribute: {Stanford::DorMetadata#version_id}
    # Which stores: [Integer] \@versionId = The ordinal version number
    specify 'Stanford::DorMetadata#version_id' do
      value = 10
      @dor_metadata.version_id= value
      expect(@dor_metadata.version_id).to eq(value)
       
      # def version_id=(value)
      #   @version_id = value
      # end
       
      # def version_id
      #   @version_id
      # end
    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do

    before (:all) do
      @digital_object_id = @obj
      @version_id = 2
      @content_metadata = @data.join('v0002/metadata/contentMetadata.xml')
      @node = Nokogiri::XML(IO.read(@content_metadata)).xpath('//file').first
    end

    before(:each) do
      @dor_metadata = Stanford::DorMetadata.new(@digital_object_id, @version_id)
    end
    
    # Unit test for method: {Stanford::DorMetadata#inventory_from_directory}
    # Which returns: [Moab::FileInventory] Inventory of the files under the specified directory
    # For input parameters:
    # * directory [String] = The location of the directory to be inventoried 
    # * version_id [Integer] = The ordinal version number 
    specify 'Stanford::DorMetadata#inventory_from_directory' do
      directory = @data.join('v0002/metadata')
      version_id = 2
      inventory = @dor_metadata.inventory_from_directory(directory, version_id)
      expect(inventory.type).to eq("version")
      expect(inventory.digital_object_id).to eq("jq937jp0017")
      expect(inventory.version_id).to eq(2)
      expect(inventory.groups.size).to eq(2)
      expect(inventory.file_count).to eq(9)

      # def inventory_from_directory(directory, version_id=nil)
      #   version_id ||= @version_id
      #   version_inventory = Moab::FileInventory.new(:type=>'version',:digital_object_id=>@digital_object_id, :version_id=>version_id)
      #   content_metadata = IO.read(File.join(directory,'contentMetadata.xml'))
      #   content_group = Stanford::ContentInventory.new.group_from_cm(content_metadata )
      #   version_inventory.groups << content_group
      #   metadata_group = Moab::FileGroup.new(:group_id=>'metadata').group_from_directory(directory)
      #   version_inventory.groups << metadata_group
      #   version_inventory
      # end
    end
  
  end

end
