require 'spec_helper'

# Unit tests for class {Fixnum}
describe 'Fixnum' do
  
  describe '=========================== INSTANCE METHODS ===========================' do
    
    before(:each) do
      @fixnum = 13579
      
    end
    
    # Unit test for method: {Fixnum#to_json}
    # Which returns: [String] The string value of the number
    # For input parameters: (None)
    specify 'Fixnum#to_json' do
      expect(@fixnum.to_json()).to eq("13579")
       
      # def to_json(options = nil)
      #   to_s
      # end
    end
  
  end

end
