describe Moab::UtcTime do

  let(:time_string) { "Apr 12 19:36:07 UTC 2012" }
  let(:time_class_parsed_string) { Time.parse( time_string) }

  context '.input' do
    it 'nil returns nil' do
      expect(Moab::UtcTime.input(nil)).to eq nil
    end
    it 'returns Time.parse() of string value' do
      expect(Moab::UtcTime.input(time_string)).to eq time_class_parsed_string
      expect(Moab::UtcTime.input(time_class_parsed_string)).to eq time_class_parsed_string
    end
    it 'bad string data raises ArgumentError' do
      expect { Moab::UtcTime.input("jgkerf") }.to raise_exception ArgumentError
    end
    it 'bad non-string data raises RuntimeError of "unknown time format"' do
      expect{Moab::UtcTime.input(4)}.to raise_exception(RuntimeError, 'unknown time format 4')
    end
  end

  context '.output' do
    it 'nil becomes empty string' do
      expect(Moab::UtcTime.output(nil)).to eq ""
    end
    it 'outputs ISO 8601 format' do
      time_string_iso8601 = "2012-04-12T19:36:07Z"
      expect(Moab::UtcTime.output(time_string)).to eq time_string_iso8601
      expect(Moab::UtcTime.output(time_class_parsed_string)).to eq time_string_iso8601
    end
    it 'bad string data raises ArgumentError' do
      expect { Moab::UtcTime.output("jgkerf") }.to raise_exception ArgumentError
    end
    it 'bad non-string data raises RuntimeError of "unknown time format"' do
      expect { Moab::UtcTime.output(4) }.to raise_exception(RuntimeError, 'unknown time format 4')
    end
  end
end
