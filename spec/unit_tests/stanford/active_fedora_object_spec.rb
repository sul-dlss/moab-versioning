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
      fedora_object = double('FedoraObject')
      active_fedora_object = Stanford::ActiveFedoraObject.new(fedora_object)
      expect(active_fedora_object).to be_instance_of(Stanford::ActiveFedoraObject)
      expect(active_fedora_object.fedora_object).to eq(fedora_object)
       
      # def initialize(fedora_object)
      #   @fedora_object = fedora_object
      # end
    end
  
  end
  
  describe '=========================== INSTANCE ATTRIBUTES ===========================' do
    
    before(:each) do
      fedora_object = double('FedoraObject')
      @active_fedora_object = Stanford::ActiveFedoraObject.new(fedora_object)
    end
    
    # Unit test for attribute: {Stanford::ActiveFedoraObject#fedora_object}
    # Which stores: [Object] The Active Fedora representation of the Fedora Object
    specify 'Stanford::ActiveFedoraObject#fedora_object' do
      value = double('NewFedoraObject')
      @active_fedora_object.fedora_object= value
      expect(@active_fedora_object.fedora_object).to eq(value)
       
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
      @fedora_object = double('FedoraObject')
      @active_fedora_object = Stanford::ActiveFedoraObject.new(@fedora_object)
    end
    
    # Unit test for method: {Stanford::ActiveFedoraObject#get_datastream_content}
    # Which returns: [String] The content of the specified datastream
    # For input parameters:
    # * ds_id [String] = The datastream identifier 
    specify 'Stanford::ActiveFedoraObject#get_datastream_content' do
      ds_id = 'Test ds_id'
      mock_datastream = double('datastream')
      mock_datastreams = double('datastreams')
      expect(@active_fedora_object.fedora_object).to receive(:datastreams).and_return(mock_datastreams)
      expect(mock_datastreams).to receive(:[]).with(ds_id).and_return(mock_datastream)
      expect(mock_datastream).to receive(:content)
      @active_fedora_object.get_datastream_content(ds_id)

      # def get_datastream_content(ds_id)
      #   @fedora_object.datastreams[ds_id].content
      # end
    end
  
  end

end
