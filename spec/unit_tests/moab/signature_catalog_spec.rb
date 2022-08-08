# frozen_string_literal: true

describe Moab::SignatureCatalog do
  let(:v1_catalog_pathname) { fixtures_dir.join('derivatives/ingests/jq937jp0017/v0001/manifests/signatureCatalog.xml') }
  let(:v2_inventory_pathname) { fixtures_dir.join('derivatives/ingests/jq937jp0017/v0002/manifests/versionInventory.xml') }
  let(:v2_inventory) { Moab::FileInventory.parse(v2_inventory_pathname.read) }
  let(:signature_catalog) { described_class.parse(v1_catalog_pathname.read) }
  let!(:original_entry_count) { signature_catalog.entries.count }

  describe '#initialize' do
    context 'with empty options hash' do
      let(:sig_catalog) { described_class.new({}) }

      it 'entries and signature_hash are right type' do
        expect(signature_catalog.entries).to be_kind_of(Array)
        expect(signature_catalog.signature_hash).to be_kind_of(Hash)
      end
    end

    context 'with options passed in' do
      let(:opts) do
        {
          digital_object_id: 'Test digital_object_id',
          version_id: 9,
          catalog_datetime: 'Apr 12 19:36:07 UTC 2012'
        }
      end

      it 'appropriate attributes are initialized' do
        sig_catalog = described_class.new(opts)
        expect(sig_catalog.digital_object_id).to eq(opts[:digital_object_id])
        expect(sig_catalog.version_id).to eq(opts[:version_id])
        expect(sig_catalog.catalog_datetime).to eq('2012-04-12T19:36:07Z')
        expect(sig_catalog.file_count).to eq(0)
      end
    end
  end

  describe '.parse (from HappyMapper XML to object mapping library)' do
    it 'digital_object_id assigned' do
      expect(signature_catalog.digital_object_id).to eq('druid:jq937jp0017')
    end

    it 'version_id assigned' do
      expect(signature_catalog.version_id).to eq(1)
    end

    it 'catalog_datetime assigned' do
      expect(Time.parse(signature_catalog.catalog_datetime)).to be_instance_of(Time)
    end

    it 'file_count assigned' do
      expect(signature_catalog.file_count).to eq(11)
    end

    it 'byte_count assigned' do
      expect(signature_catalog.byte_count).to eq(217820)
    end

    it 'block_count assigned' do
      expect(signature_catalog.block_count).to eq(216)
    end

    it 'entries assigned' do
      expect(signature_catalog.entries.size).to eq(11)
    end

    it 'signature_hash assigned' do
      expect(signature_catalog.signature_hash.size).to eq(11)
    end

    it 'composite_key assigned' do
      expect(signature_catalog.composite_key).to eq('druid:jq937jp0017-v0001')
    end
  end

  describe '#catalog_datetime' do
    let(:sig_catalog) do
      sig_catalog = described_class.new
      sig_catalog.catalog_datetime = 'Apr 12 19:36:07 UTC 2012'
      sig_catalog
    end

    it 'reformats date as ISO8601 (UTC Z format)' do
      expect(sig_catalog.catalog_datetime).to eq('2012-04-12T19:36:07Z')
    end
  end

  describe '#add_entry' do
    let(:entry) { double(Moab::SignatureCatalogEntry.name) }

    it 'adds 1 to the entries count' do
      expect(entry).to receive(:signature).and_return(double(Moab::FileSignature.name))
      signature_catalog.add_entry(entry)
      expect(signature_catalog.entries.count).to eq(original_entry_count + 1)
    end
  end

  describe '#catalog_filepath' do
    let(:file_signature) { signature_catalog.entries[0].signature }

    it 'returns file path for signature_catalog entries signature' do
      expect(signature_catalog.catalog_filepath(file_signature)).to eq('v0001/data/content/intro-1.jpg')
    end

    it 'raises Moab::FileNotFoundException when file_signature size is 0' do
      file_signature.size = 0
      expect { signature_catalog.catalog_filepath(file_signature) }.to raise_exception Moab::FileNotFoundException
    end
  end

  describe '#normalize_group_signatures' do
    before do
      v2_inventory.groups.each do |group|
        group.data_source = v2_inventory_pathname.parent.parent.join('data', group.group_id).to_s
        if group.group_id == 'content'
          group.files.each do |file|
            file.signature.sha256 = nil
          end
        end
      end
    end

    it 'assigns (sha256) content signatures' do
      content_signatures = v2_inventory.group('content').files.collect(&:signature)
      expect(content_signatures.collect(&:sha256)).to eq([nil, nil, nil, nil])

      v2_inventory.groups.each do |group|
        signature_catalog.normalize_group_signatures(group, group.data_source)
      end

      content_signatures = v2_inventory.group('content').files.collect(&:signature)
      expect(content_signatures.collect(&:sha256)).to eq(
        %w[b78cc53b7b8d9ed86d5e3bab3b699c7ed0db958d4a111e56b6936c8397137de0
           235de16df4804858aefb7690baf593fb572d64bb6875ec522a4eea1f4189b5f0
           7bd120459eff0ecd21df94271e5c14771bfca5137d1dd74117b6a37123dfe271
           8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5]
      )
    end
  end

  describe '#update' do
    before do
      v2_inventory.groups.each do |group|
        if group.group_id == 'metadata'
          group.files.each do |file|
            file.signature.sha256 = nil if [1303, 399].include?(file.signature.size.to_i)
          end
        end
      end
    end

    it 'updates (sha256) content signatures' do
      signature_catalog.update(v2_inventory, v2_inventory_pathname.parent.parent.join('data'))

      expect(signature_catalog.entries.count).to eq(original_entry_count + 4)
      v2_entries = signature_catalog.entries.select { |entry| entry.version_id.to_i == 2 }
      expect(v2_entries.collect { |entry| entry.signature.sha256 }).to eq(
        %w[b78cc53b7b8d9ed86d5e3bab3b699c7ed0db958d4a111e56b6936c8397137de0
           02b3bb1d059a705cb693bb2fe2550a8090b47cd3c32e823891b2071156485b73
           ee62fdef9736ff12e394c3510f3d0a6ccd18bd5b1fb7e42fe46800d5934c9001
           291208b41c557a5fb15cc836ab7235dadbd0881096385cc830bb446b00d2eb6b]
      )
    end
  end

  describe '#version_additions' do
    let(:version_additions) { signature_catalog.version_additions(v2_inventory) }

    it 'sets groups' do
      expect(version_additions.groups.count).to eq(2)
    end

    it 'sets file_count' do
      expect(version_additions.file_count).to eq(4)
    end

    it 'sets byte_count' do
      expect(version_additions.byte_count).to eq(35181)
    end

    it 'sets block_count' do
      expect(version_additions.block_count).to eq(37)
    end
  end

  describe '#summary' do
    it 'returns hash of summary fields with values' do
      expect(signature_catalog.summary).to eq('digital_object_id' => 'druid:jq937jp0017',
                                              'version_id' => 1,
                                              'catalog_datetime' => signature_catalog.catalog_datetime.to_s,
                                              'file_count' => 11,
                                              'byte_count' => 217820,
                                              'block_count' => 216)
    end
  end

  describe 'Serialization to string using HappyMapper to_xml' do
    it 'has signatureCatalog and entry tags' do
      expect(signature_catalog.to_xml).to match(/^.*<signatureCatalog.*<\/entry>.*<\/signatureCatalog>$/m)
    end
  end
end
