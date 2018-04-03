require 'time'

module Moab
  # Timestamp conversion methods.
  class UtcTime
    # @param datetime [Time,String,Nil] The input datetime
    # @return [void] Convert input datetime to a Time object, or nil if input is empty.
    def self.input(datetime)
      case datetime
      when nil
        nil
      when ""
        nil
      when String
        Time.parse(datetime)
      when Time
        datetime
      else
        raise "unknown time format #{datetime.inspect}"
      end
    end

    # @param datetime [Time,String,Nil] The datetime value to output
    # @return [String] Convert the datetime into a ISO 8601 formatted string
    def self.output(datetime)
      case datetime
      when nil, ""
        ""
      when String
        Time.parse(datetime).utc.iso8601
      when Time
        datetime.utc.iso8601
      else
        raise "unknown time format #{datetime.inspect}"
      end
    end
  end
end
