require 'spec_helper'

describe 'Moab::VersionMetadata' do

  let(:version_metadata) { Moab::VersionMetadata.new({}) }

  context '#initialize' do
    it 'empty options' do
      expect(version_metadata.versions).to be_kind_of(Array)
      expect(version_metadata.versions.size).to eq 0
    end

    it 'default options' do
      vm = Moab::VersionMetadata.new()
      expect(vm.versions).to be_kind_of(Array)
      expect(vm.versions.size).to eq 0
    end

    it 'populated options hash' do
      opts = {
        digital_object_id: 'Test digital_object_id',
        versions: [double(Moab::VersionMetadataEntry.name)]
      }
      version_metadata = Moab::VersionMetadata.new(opts)
      expect(version_metadata.digital_object_id).to eq opts[:digital_object_id]
      expect(version_metadata.versions).to eq opts[:versions]
    end
  end

  context '#versions' do
    it 'expected values when set' do
      value = [double(Moab::VersionMetadataEntry.name)]
      version_metadata.versions = value
      expect(version_metadata.versions).to eq value
    end
  end
end
