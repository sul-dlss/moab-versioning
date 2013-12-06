require 'spec_helper'

# Unit tests for class {UtcTime}
describe 'UtcTime' do
  
  describe '=========================== CLASS METHODS ===========================' do
    
    before(:all) do
      @time_string = "Apr 12 19:36:07 UTC 2012"
      @time_class_instance = Time.parse( @time_string)

    end

    # Unit test for method: {Time.input}
    # Which returns: [void] Store the input datetime as a Time object
    # For input parameters:
    # * datetime [Time, String, Nil] = The input datetime 
    specify 'UtcTime.input' do
      UtcTime.input(nil).should == nil
      UtcTime.input(@time_string).should == @time_class_instance
      UtcTime.input(@time_class_instance).should == @time_class_instance
      expect { UtcTime.input("jgkerf") }.to raise_exception(ArgumentError) unless RUBY_VERSION < "1.9"
      lambda{UtcTime.input(4)}.should raise_exception(RuntimeError,'unknown time format 4')

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
    specify 'UtcTime.output' do
      UtcTime.output(nil).should == nil
      UtcTime.output(@time_string).should == "2012-04-12T19:36:07Z"
      UtcTime.output(@time_class_instance).should == "2012-04-12T19:36:07Z"
      expect { UtcTime.input("jgkerf") }.to raise_exception(ArgumentError) unless RUBY_VERSION < "1.9"
      lambda{UtcTime.output(4)}.should raise_exception(RuntimeError,'unknown time format 4')

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

end
