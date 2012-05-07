require 'spec_helper'

# Unit tests for class {Stanford::ActiveFedoraObject}
describe 'Stanford::ActiveFedoraObject' do
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Stanford::ActiveFedoraObject#initialize}
    # Which returns an instance of: [Stanford::ActiveFedoraObject]
    # For input parameters:
    # * fedora_object [Object] = The Active Fedora representation of the Fedora Object 
    specify 'Stanford::ActiveFedoraObject#initialize' do
       
      # test initialization with required parameters (if any)
      fedora_object = mock('FedoraObject')
      active_fedora_object = ActiveFedoraObject.new(fedora_object)
      active_fedora_object.should be_instance_of(ActiveFedoraObject)
      active_fedora_object.fedora_object.should == fedora_object
       
      # def initialize(fedora_object)
      #   @fedora_object = fedora_object
      # end
    end
  
  end
  
  describe '=========================== INSTANCE ATTRIBUTES ===========================' do
    
    before(:all) do
      fedora_object = mock('FedoraObject')
      @active_fedora_object = ActiveFedoraObject.new(fedora_object)
    end
    
    # Unit test for attribute: {Stanford::ActiveFedoraObject#fedora_object}
    # Which stores: [Object] The Active Fedora representation of the Fedora Object
    specify 'Stanford::ActiveFedoraObject#fedora_object' do
      value = mock('NewFedoraObject')
      @active_fedora_object.fedora_object= value
      @active_fedora_object.fedora_object.should == value
       
      # def fedora_object=(value)
      #   @fedora_object = value
      # end
       
      # def fedora_object
      #   @fedora_object
      # end
    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do
    
    before(:each) do
      @fedora_object = mock('FedoraObject')
      @active_fedora_object = ActiveFedoraObject.new(@fedora_object)
    end
    
    # Unit test for method: {Stanford::ActiveFedoraObject#get_datastream_content}
    # Which returns: [String] The content of the specified datastream
    # For input parameters:
    # * ds_id [String] = The datastream identifier 
    specify 'Stanford::ActiveFedoraObject#get_datastream_content' do
      ds_id = 'Test ds_id'
      mock_datastream = mock('datastream')
      mock_datastreams = mock('datastreams')
      @active_fedora_object.fedora_object.should_receive(:datastreams).and_return(mock_datastreams)
      mock_datastreams.should_receive(:[]).with(ds_id).and_return(mock_datastream)
      mock_datastream.should_receive(:content)
      @active_fedora_object.get_datastream_content(ds_id)

      # def get_datastream_content(ds_id)
      #   @fedora_object.datastreams[ds_id].content
      # end
    end
  
  end

end
