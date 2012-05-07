require 'spec_helper'

# Unit tests for class {Time}
describe 'Time' do
  
  describe '=========================== CLASS METHODS ===========================' do
    
    before(:all) do
      @time_string = "Apr 12 19:36:07 UTC 2012"
      @time_class_instance = Time.parse( @time_string)

    end

    # Unit test for method: {Time.input}
    # Which returns: [void] Store the input datetime as a Time object
    # For input parameters:
    # * datetime [Time, String, Nil] = The input datetime 
    specify 'Time.input' do
      Time.input(nil).should == nil
      Time.input(@time_string).should == @time_class_instance
      Time.input(@time_class_instance).should == @time_class_instance
      Time.input("jgkerf").should raise_exception(NoMethodError)
      lambda{Time.input(4)}.should raise_exception(RuntimeError,'unknown time format 4')

      # def self.input(datetime)
      #   case datetime
      #     when nil
      #       nil
      #     when String
      #       Time.parse(datetime)
      #     when Time
      #       datetime
      #     else
      #       raise "unknown time format #{datetime.inspect}"
      #   end
      # end
    end
    
    # Unit test for method: {Time.output}
    # Which returns: [String] Format the datetime into a ISO 8601 formatted string
    # For input parameters:
    # * datetime [Time, String, Nil] = The datetime value to output 
    specify 'Time.output' do
      Time.output(nil).should == nil
      Time.output(@time_string).should == "2012-04-12T19:36:07Z"
      Time.output(@time_class_instance).should == "2012-04-12T19:36:07Z"
      Time.output("jgkerf").should raise_exception(NoMethodError)
      lambda{Time.output(4)}.should raise_exception(RuntimeError,'unknown time format 4')

      # def self.output(datetime)
      #   case datetime
      #     when nil
      #       nil
      #     when String
      #       Time.parse(datetime).utc.iso8601
      #     when Time
      #       datetime.utc.iso8601
      #     else
      #       raise "unknown time format #{datetime.inspect}"
      #   end
      # end
    end
  
  end
  
  describe '=========================== CONSTRUCTOR ===========================' do
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do
    
    before(:each) do
      @time = Time.parse("Apr 12 19:36:07 UTC 2012")
      
    end
    
    # Unit test for method: {Time#to_s}
    # Which returns: [String] The datetime in ISO 8601 format
    # For input parameters: (None)
    specify 'Time#to_s' do
      @time.to_s().should == "2012-04-12T19:36:07Z"
       
      # def to_s
      #   self.utc.iso8601
      # end
    end
  
  end

end
