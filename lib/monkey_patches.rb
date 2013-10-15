require 'time'

# monkey-patch to fix JSON_pure
# @see http://prettystatemachine.blogspot.com/2010/09/typeerrors-in-tojson-make-me-briefly.html
#noinspection RubyUnusedLocalVariable
class Fixnum
  # @return [String] The string value of the number
  def to_json(options = nil)
    to_s
  end
end

# Make the default output from a Time variable be formatted in ISO 8601 format
class Time
  # @return [String] The datetime in ISO 8601 format
  def to_s
    self.utc.iso8601
  end

  # @param datetime [Time,String,Nil] The input datetime
  # @return [void] Store the input datetime as a Time object
  def self.input(datetime)
    case datetime
      when nil
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
  # @return [String] Format the datetime into a ISO 8601 formatted string
  def self.output(datetime)
    case datetime
      when nil
        nil
      when String
        Time.parse(datetime).utc.iso8601
      when Time
        datetime.utc.iso8601
      else
        raise "unknown time format #{datetime.inspect}"
    end
  end

end

# Add methods to Array so that one attribute of a class can be treated as a unique key
class Array
  # @return [Array<Object>] An array containing the key fields from a collection of objects
  def keys
    self.collect { |e| e.key }
  end

  # @param key [Object] The key value to search for
  # @return [Object] The object from the array that has the specified key value
  def keyfind(key)
    self.each { |e| return e if key == e.key }
    nil
  end
end