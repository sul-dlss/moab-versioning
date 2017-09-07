require 'spec_helper'

describe 'Moab::VersionMetadataEvent' do

  specify '#initialize' do
    opts = {
      type: 'Test event',
      datetime: "Apr 12 19:36:07 UTC 2012"
    }
    version_metadata_event = Moab::VersionMetadataEvent.new(opts)
    expect(version_metadata_event.type).to eq opts[:type]
    expect(version_metadata_event.datetime).to eq "2012-04-12T19:36:07Z"
  end

  context '#datetime' do
    let(:version_metadata_event) { Moab::VersionMetadataEvent.new({}) }

    it 'String is converted to correct format' do
      version_metadata_event.datetime = "Apr 12 19:36:07 UTC 2012"
      expect(version_metadata_event.datetime).to eq "2012-04-12T19:36:07Z"
    end
    it 'Time.parse output is converted to correct format' do
      version_metadata_event.datetime = Time.parse("Apr 12 19:36:07 UTC 2012")
      expect(version_metadata_event.datetime).to eq "2012-04-12T19:36:07Z"
    end
    it 'nil value becomes empty string' do
      version_metadata_event.datetime = nil
      expect(version_metadata_event.datetime).to eq ""
    end
  end
end
