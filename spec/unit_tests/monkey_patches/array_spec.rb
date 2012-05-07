require 'spec_helper'

class Kstring < String
  def key
    to_s[0..0]
  end
end

# Unit tests for class {Array}
describe 'Array' do

  describe '=========================== INSTANCE METHODS ===========================' do
    
    before(:each) do
      @array = [Kstring.new("Andy"),Kstring.new("Billy"),Kstring.new("Cathy")]
    end
    
    # Unit test for method: {Array#keys}
    # Which returns: [Array<Object>] An array containing the key fields from a collection of objects
    # For input parameters: (None)
    specify 'Array#keys' do
      @array.keys().should == ["A","B","C"]
       
      # def keys
      #   self.collect { |e| e.key }
      # end
    end
    
    # Unit test for method: {Array#keyfind}
    # Which returns: [Object] The object from the array that has the specified key value
    # For input parameters:
    # * key [Object] = The key value to search for 
    specify 'Array#keyfind' do
       @array.keyfind("B").should == "Billy"
       @array.keyfind("J").should == nil

      # def keyfind(key)
      #   self.each { |e| return e if key == e.key}
      #   nil
      # end
    end
  
  end

end
