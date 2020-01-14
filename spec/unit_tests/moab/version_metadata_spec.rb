# frozen_string_literal: true

describe Moab::VersionMetadata do
  let(:version_metadata) { described_class.new({}) }

  describe '#initialize' do
    it 'empty options' do
      expect(version_metadata.versions).to eq []
    end

    it 'default options' do
      expect(described_class.new.versions).to eq []
    end

    it 'populated options hash' do
      opts = {
        digital_object_id: 'Test digital_object_id',
        versions: [double(Moab::VersionMetadataEntry.name)]
      }
      version_metadata = described_class.new(opts)
      expect(version_metadata.digital_object_id).to eq opts[:digital_object_id]
      expect(version_metadata.versions).to eq opts[:versions]
    end
  end

  describe '#versions' do
    it 'expected values when set' do
      value = [double(Moab::VersionMetadataEntry.name)]
      version_metadata.versions = value
      expect(version_metadata.versions).to eq value
    end
  end
end
