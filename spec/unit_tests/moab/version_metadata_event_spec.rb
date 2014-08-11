require 'spec_helper'

# Unit tests for class {Moab::VersionMetadataEvent}
describe 'Moab::VersionMetadataEvent' do
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Moab::VersionMetadataEvent#initialize}
    # Which returns an instance of: [Moab::VersionMetadataEvent]
    # For input parameters:
    # * opts [Hash<Symbol,Object>] = a hash containing any number of symbol => value pairs. The symbols should correspond to attributes declared using HappyMapper syntax 
    specify 'Moab::VersionMetadataEvent#initialize' do
       
      # test initialization with required parameters (if any)
      opts = {}
      version_metadata_event = VersionMetadataEvent.new(opts)
      expect(version_metadata_event).to be_instance_of(VersionMetadataEvent)
       
      # test initialization with options hash
      opts = Hash.new
      opts[:type] = 'Test event'
      opts[:datetime] = "Apr 12 19:36:07 UTC 2012"
      version_metadata_event = VersionMetadataEvent.new(opts)
      expect(version_metadata_event.type).to eq(opts[:type])
      expect(version_metadata_event.datetime).to eq("2012-04-12T19:36:07Z")
       
      # def initialize(opts={})
      #   super(opts)
      # end
    end
  
  end
  
  describe '=========================== INSTANCE ATTRIBUTES ===========================' do
    
    before(:all) do
      opts = {}
      @version_metadata_event = VersionMetadataEvent.new(opts)
    end
    
    # Unit test for attribute: {Moab::VersionMetadataEvent#type}
    # Which stores: [String] \@type = The type of event
    specify 'Moab::VersionMetadataEvent#type' do
      value = 'Test event'
      @version_metadata_event.type= value
      expect(@version_metadata_event.type).to eq(value)
       
      # attribute :type, String
    end
    
    # Unit test for attribute: {Moab::VersionMetadataEvent#datetime}
    # Which stores: [Time] \@datetime = The date and time of an event
    specify 'Moab::VersionMetadataEvent#datetime' do
      @version_metadata_event.datetime= "Apr 12 19:36:07 UTC 2012"
      expect(@version_metadata_event.datetime).to eq("2012-04-12T19:36:07Z")
      @version_metadata_event.datetime= Time.parse("Apr 12 19:36:07 UTC 2012")
      expect(@version_metadata_event.datetime).to eq("2012-04-12T19:36:07Z")
      @version_metadata_event.datetime= nil
      expect(@version_metadata_event.datetime).to eq("")
       
      # def datetime=(event_datetime)
      #   @datetime=Time.input(event_datetime)
      # end
      #
      # def datetime
      #   Time.output(@datetime)
      # end
    end
  
  end

end
