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
      version_metadata_entry = Moab::VersionMetadataEntry.new(opts)
      expect(version_metadata_entry).to be_instance_of(Moab::VersionMetadataEntry)
       
      # test initialization of arrays and hashes
      expect(version_metadata_entry.events).to be_kind_of(Array)
       
      # test initialization with options hash
      opts = Hash.new
      opts[:version_id] = 17
      opts[:significance] = 'Major'
      opts[:description] = 'Test reason'
      opts[:note] = 'Test note'
      opts[:content_changes] = double(Moab::FileGroupDifference.name)
      opts[:metadata_changes] = double(Moab::FileGroupDifference.name)
      opts[:events] = [double(Moab::VersionMetadataEvent.name)]
      version_metadata_entry = Moab::VersionMetadataEntry.new(opts)
      expect(version_metadata_entry.version_id).to eq(opts[:version_id])
      expect(version_metadata_entry.significance).to eq(opts[:significance])
      expect(version_metadata_entry.description).to eq(opts[:description])
      expect(version_metadata_entry.note).to eq(opts[:note])
      expect(version_metadata_entry.content_changes).to eq(opts[:content_changes])
      expect(version_metadata_entry.metadata_changes).to eq(opts[:metadata_changes])
      expect(version_metadata_entry.events).to eq(opts[:events])
       
      # def initialize(opts={})
      #   @events = Array.new
      #   super(opts)
      # end
    end
  
  end
  
  describe '=========================== INSTANCE ATTRIBUTES ===========================' do
    
    before(:all) do
      opts = {}
      @version_metadata_entry = Moab::VersionMetadataEntry.new(opts)
    end
    
    # Unit test for attribute: {Moab::VersionMetadataEntry#version_id}
    # Which stores: [Integer] \@versionId = The object version number (A sequential integer)
    specify 'Moab::VersionMetadataEntry#version_id' do
      value = 37
      @version_metadata_entry.version_id= value
      expect(@version_metadata_entry.version_id).to eq(value)
       
      # attribute :version_id, Integer, :tag => 'versionId', :key => true, :on_save => Proc.new {|n| n.to_s}
    end
    
    # Unit test for attribute: {Moab::VersionMetadataEntry#significance}
    # Which stores: [String] \@significance = "major|minor"
    specify 'Moab::VersionMetadataEntry#significance' do
      value = 'Major|Minor'
      @version_metadata_entry.significance= value
      expect(@version_metadata_entry.significance).to eq(value)
       
      # attribute :significance, String
    end
    
    # Unit test for attribute: {Moab::VersionMetadataEntry#reason}
    # Which stores: [String] \@reason = A free text description of why the version was submitted (optional)
    specify 'Moab::VersionMetadataEntry#reason' do
      value = 'Test reason'
      @version_metadata_entry.description= value
      expect(@version_metadata_entry.description).to eq(value)
       
      # element :reason, String
    end
    
    # Unit test for attribute: {Moab::VersionMetadataEntry#note}
    # Which stores: [String] \@note = A system generated annotation summarizing the changes (optional)
    specify 'Moab::VersionMetadataEntry#note' do
      value = 'Test note'
      @version_metadata_entry.note= value
      expect(@version_metadata_entry.note).to eq(value)
       
      # element :note, String
    end
    
    # Unit test for attribute: {Moab::VersionMetadataEntry#content_changes}
    # Which stores: [Moab::FileGroupDifference] \<fileGroupDifference> = Summary of content file differences since previous version
    specify 'Moab::VersionMetadataEntry#content_changes' do
      value = double(Moab::FileGroupDifference.name)
      @version_metadata_entry.content_changes= value
      expect(@version_metadata_entry.content_changes).to eq(value)
       
      # element :content_changes, Moab::FileGroupDifference
    end
    
    # Unit test for attribute: {Moab::VersionMetadataEntry#metadata_changes}
    # Which stores: [Moab::FileGroupDifference] \<fileGroupDifference> = Summary of metadata file differences since previous version
    specify 'Moab::VersionMetadataEntry#metadata_changes' do
      value = double(Moab::FileGroupDifference.name)
      @version_metadata_entry.metadata_changes= value
      expect(@version_metadata_entry.metadata_changes).to eq(value)
       
      # element :metadata_changes, Moab::FileGroupDifference
    end
    
    # Unit test for attribute: {Moab::VersionMetadataEntry#events}
    # Which stores: [Array<Moab::VersionMetadataEvent>] \[<event>] = Array of events with timestamps that track lifecycle stages
    specify 'Moab::VersionMetadataEntry#events' do
      value = [double(Moab::VersionMetadataEvent.name)]
      @version_metadata_entry.events= value
      expect(@version_metadata_entry.events).to eq(value)
       
      # has_many :events, Moab::VersionMetadataEvent
    end
  
  end

end
