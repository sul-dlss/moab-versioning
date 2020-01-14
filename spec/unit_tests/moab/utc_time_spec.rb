# frozen_string_literal: true

describe Moab::UtcTime do
  let(:time_string) { "Apr 12 19:36:07 UTC 2012" }
  let(:time_class_parsed_string) { Time.parse(time_string) }

  describe '.input' do
    it 'nil returns nil' do
      expect(described_class.input(nil)).to eq nil
    end

    it 'returns Time.parse() of string value' do
      expect(described_class.input(time_string)).to eq time_class_parsed_string
      expect(described_class.input(time_class_parsed_string)).to eq time_class_parsed_string
    end

    it 'bad string data raises ArgumentError' do
      expect { described_class.input("jgkerf") }.to raise_exception ArgumentError
    end

    it 'bad non-string data raises MoabRuntimeError of "unknown time format"' do
      expect { described_class.input(4) }.to raise_exception(Moab::MoabRuntimeError, 'unknown time format 4')
    end
  end

  describe '.output' do
    it 'nil becomes empty string' do
      expect(described_class.output(nil)).to eq ""
    end

    it 'outputs ISO 8601 format' do
      time_string_iso8601 = "2012-04-12T19:36:07Z"
      expect(described_class.output(time_string)).to eq time_string_iso8601
      expect(described_class.output(time_class_parsed_string)).to eq time_string_iso8601
    end

    it 'bad string data raises ArgumentError' do
      expect { described_class.output("jgkerf") }.to raise_exception ArgumentError
    end

    it 'bad non-string data raises MoabRuntimeError of "unknown time format"' do
      expect { described_class.output(4) }.to raise_exception(Moab::MoabRuntimeError, 'unknown time format 4')
    end
  end
end
