# frozen_string_literal: true

describe Moab::VersionMetadataEntry do
  describe '#initialize' do
    it 'empty hash for options' do
      expect(described_class.new({}).events).to eq []
    end

    it 'default options' do
      expect(described_class.new.events).to eq []
    end

    it 'opts with all keys defined' do
      opts = {
        version_id: 17,
        significance: 'Major',
        description: 'Test reason',
        note: 'Test note',
        content_changes: double(Moab::FileGroupDifference.name),
        metadata_changes: double(Moab::FileGroupDifference.name),
        events: [double(Moab::VersionMetadataEvent.name)]
      }
      vme = described_class.new(opts)
      expect(vme.version_id).to eq opts[:version_id]
      expect(vme.significance).to eq opts[:significance]
      expect(vme.description).to eq opts[:description]
      expect(vme.note).to eq opts[:note]
      expect(vme.content_changes).to eq opts[:content_changes]
      expect(vme.metadata_changes).to eq opts[:metadata_changes]
      expect(vme.events).to eq opts[:events]
    end
  end
end
