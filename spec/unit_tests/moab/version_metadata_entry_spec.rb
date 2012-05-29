require 'spec_helper'

# Unit tests for class {Moab::VersionMetadataEntry}
describe 'Moab::VersionMetadataEntry' do
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Moab::VersionMetadataEntry#initialize}
    # Which returns an instance of: [Moab::VersionMetadataEntry]
    # For input parameters:
    # * opts [Hash<Symbol,Object>] = a hash containing any number of symbol => value pairs. The symbols should correspond to attributes declared using HappyMapper syntax 
    specify 'Moab::VersionMetadataEntry#initialize' do
       
      # test initialization with required parameters (if any)
      opts = {}
      version_metadata_entry = VersionMetadataEntry.new(opts)
      version_metadata_entry.should be_instance_of(VersionMetadataEntry)
       
      # test initialization of arrays and hashes
      version_metadata_entry.events.should be_kind_of(Array)
       
      # test initialization with options hash
      opts = OrderedHash.new
      opts[:version_id] = 17
      opts[:significance] = 'Major'
      opts[:description] = 'Test reason'
      opts[:note] = 'Test note'
      opts[:content_changes] = mock(FileGroupDifference.name)
      opts[:metadata_changes] = mock(FileGroupDifference.name)
      opts[:events] = [mock(VersionMetadataEvent.name)]
      version_metadata_entry = VersionMetadataEntry.new(opts)
      version_metadata_entry.version_id.should == opts[:version_id]
      version_metadata_entry.significance.should == opts[:significance]
      version_metadata_entry.description.should == opts[:description]
      version_metadata_entry.note.should == opts[:note]
      version_metadata_entry.content_changes.should == opts[:content_changes]
      version_metadata_entry.metadata_changes.should == opts[:metadata_changes]
      version_metadata_entry.events.should == opts[:events]
       
      # def initialize(opts={})
      #   @events = Array.new
      #   super(opts)
      # end
    end
  
  end
  
  describe '=========================== INSTANCE ATTRIBUTES ===========================' do
    
    before(:all) do
      opts = {}
      @version_metadata_entry = VersionMetadataEntry.new(opts)
    end
    
    # Unit test for attribute: {Moab::VersionMetadataEntry#version_id}
    # Which stores: [Integer] \@versionId = The object version number (A sequential integer)
    specify 'Moab::VersionMetadataEntry#version_id' do
      value = 37
      @version_metadata_entry.version_id= value
      @version_metadata_entry.version_id.should == value
       
      # attribute :version_id, Integer, :tag => 'versionId', :key => true, :on_save => Proc.new {|n| n.to_s}
    end
    
    # Unit test for attribute: {Moab::VersionMetadataEntry#significance}
    # Which stores: [String] \@significance = "major|minor"
    specify 'Moab::VersionMetadataEntry#significance' do
      value = 'Major|Minor'
      @version_metadata_entry.significance= value
      @version_metadata_entry.significance.should == value
       
      # attribute :significance, String
    end
    
    # Unit test for attribute: {Moab::VersionMetadataEntry#reason}
    # Which stores: [String] \@reason = A free text description of why the version was submitted (optional)
    specify 'Moab::VersionMetadataEntry#reason' do
      value = 'Test reason'
      @version_metadata_entry.description= value
      @version_metadata_entry.description.should == value
       
      # element :reason, String
    end
    
    # Unit test for attribute: {Moab::VersionMetadataEntry#note}
    # Which stores: [String] \@note = A system generated annotation summarizing the changes (optional)
    specify 'Moab::VersionMetadataEntry#note' do
      value = 'Test note'
      @version_metadata_entry.note= value
      @version_metadata_entry.note.should == value
       
      # element :note, String
    end
    
    # Unit test for attribute: {Moab::VersionMetadataEntry#content_changes}
    # Which stores: [FileGroupDifference] \<fileGroupDifference> = Summary of content file differences since previous version
    specify 'Moab::VersionMetadataEntry#content_changes' do
      value = mock(FileGroupDifference.name)
      @version_metadata_entry.content_changes= value
      @version_metadata_entry.content_changes.should == value
       
      # element :content_changes, FileGroupDifference
    end
    
    # Unit test for attribute: {Moab::VersionMetadataEntry#metadata_changes}
    # Which stores: [FileGroupDifference] \<fileGroupDifference> = Summary of metadata file differences since previous version
    specify 'Moab::VersionMetadataEntry#metadata_changes' do
      value = mock(FileGroupDifference.name)
      @version_metadata_entry.metadata_changes= value
      @version_metadata_entry.metadata_changes.should == value
       
      # element :metadata_changes, FileGroupDifference
    end
    
    # Unit test for attribute: {Moab::VersionMetadataEntry#events}
    # Which stores: [Array<VersionMetadataEvent>] \[<event>] = Array of events with timestamps that track lifecycle stages
    specify 'Moab::VersionMetadataEntry#events' do
      value = [mock(VersionMetadataEvent.name)]
      @version_metadata_entry.events= value
      @version_metadata_entry.events.should == value
       
      # has_many :events, VersionMetadataEvent
    end
  
  end

end
