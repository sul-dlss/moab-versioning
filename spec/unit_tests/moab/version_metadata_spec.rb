require 'spec_helper'

# Unit tests for class {Moab::VersionMetadata}
describe 'Moab::VersionMetadata' do
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Moab::VersionMetadata#initialize}
    # Which returns an instance of: [Moab::VersionMetadata]
    # For input parameters:
    # * opts [Hash<Symbol,Object>] = a hash containing any number of symbol => value pairs. The symbols should correspond to attributes declared using HappyMapper syntax 
    specify 'Moab::VersionMetadata#initialize' do
       
      # test initialization with required parameters (if any)
      opts = {}
      version_metadata = VersionMetadata.new(opts)
      version_metadata.should be_instance_of(VersionMetadata)
       
      # test initialization of arrays and hashes
      version_metadata.versions.should be_kind_of(Array)
       
      # test initialization with options hash
      opts = OrderedHash.new
      opts[:digital_object_id] = 'Test digital_object_id'
      opts[:versions] = [double(VersionMetadataEntry.name)]
      version_metadata = VersionMetadata.new(opts)
      version_metadata.digital_object_id.should == opts[:digital_object_id]
      version_metadata.versions.should == opts[:versions]
       
      # def initialize(opts={})
      #   @versions = Array.new
      #   super(opts)
      # end
    end
  
  end
  
  describe '=========================== INSTANCE ATTRIBUTES ===========================' do
    
    before(:all) do
      opts = {}
      @version_metadata = VersionMetadata.new(opts)
    end
    
    # Unit test for attribute: {Moab::VersionMetadata#digital_object_id}
    # Which stores: [String] \@objectId = The digital object identifier
    specify 'Moab::VersionMetadata#digital_object_id' do
      value = 'Test digital_object_id'
      @version_metadata.digital_object_id= value
      @version_metadata.digital_object_id.should == value
       
      # attribute :digital_object_id, String, :tag => 'objectId'
    end
    
    # Unit test for attribute: {Moab::VersionMetadata#versions}
    # Which stores: [Array<VersionMetadataEntry>] \[<version>] = An array of version metadata entries, one per version
    specify 'Moab::VersionMetadata#versions' do
      value = [double(VersionMetadataEntry.name)]
      @version_metadata.versions= value
      @version_metadata.versions.should == value
       
      # has_many :versions, VersionMetadataEntry
    end
  
  end

end
