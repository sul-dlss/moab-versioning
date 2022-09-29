# frozen_string_literal: true

describe Serializer::Manifest do
  describe '.xml_filename' do
    it 'unspecified name returns class name' do
      expect(Moab::SignatureCatalog.xml_filename).to eq('signatureCatalog.xml')
    end

    it 'specified name is returned' do
      expect(Moab::SignatureCatalog.xml_filename('dummy')).to eq('dummy')
    end
  end

  describe '.xml_pathname' do
    let(:parent_dir) { Pathname.new('/test/parent_dir') }

    it 'parent_dir specified but no filename' do
      expect(Moab::SignatureCatalog.xml_pathname(parent_dir)).to eq(Pathname("#{parent_dir}/signatureCatalog.xml"))
    end

    it 'both parent_dir and filename specified' do
      expect(Moab::SignatureCatalog.xml_pathname(parent_dir, 'dummy')).to eq(Pathname("#{parent_dir}/dummy"))
    end
  end

  it '.xml_pathname_exist?' do
    expect(described_class.xml_pathname_exist?('/test/parent_dir', 'dummy')).to be(false)
    expect(Moab::SignatureCatalog.xml_pathname_exist?(manifests_dir.join('v0001'))).to be(true)
  end

  describe '.read_xml_file' do
    let(:parent_dir) { manifests_dir.join('v1') }
    let(:mock_pathname) { instance_double(Pathname.name) }
    let(:mock_xml) { 'xml' }

    before do
      allow(Moab::SignatureCatalog).to receive(:xml_pathname).with(parent_dir, nil).and_return(mock_pathname)
      allow(Moab::SignatureCatalog).to receive(:parse).with(mock_xml)
      allow(mock_pathname).to receive(:read).and_return(mock_xml)
    end

    it 'calls the expected methods' do
      Moab::SignatureCatalog.read_xml_file(parent_dir)
      expect(Moab::SignatureCatalog).to have_received(:parse).with(mock_xml)
      expect(Moab::SignatureCatalog).to have_received(:xml_pathname).with(parent_dir, nil)
      expect(mock_pathname).to have_received(:read)
    end
  end

  describe '.write_xml_file' do
    let(:xml_object) { Moab::SignatureCatalog.read_xml_file(manifests_dir.join('v0001')) }
    let(:output_dir) { temp_dir }
    let(:mock_pathname) { instance_double(Pathname.name) }

    before do
      allow(Moab::SignatureCatalog).to receive(:xml_pathname).and_return(mock_pathname)
      allow(mock_pathname).to receive(:open).with('w').and_return(an_instance_of(IO))
      allow(mock_pathname).to receive(:read).and_return('<foo />')
    end

    it 'calls the expected methods' do
      Moab::SignatureCatalog.write_xml_file(xml_object, output_dir)
      expect(Moab::SignatureCatalog).to have_received(:xml_pathname).with(output_dir, nil)
      expect(mock_pathname).to have_received(:read)
      expect(mock_pathname).to have_received(:open).with('w')
    end
  end

  describe '#write_xml_file' do
    let(:output_dir) { '/my/temp' }

    context 'with FileInventory' do
      let(:pathname) { fixtures_dir.join('derivatives/ingests/jq937jp0017/v0001/manifests/versionInventory.xml') }
      let(:file_inventory) { Moab::FileInventory.parse(pathname.read) }

      before do
        allow(Moab::FileInventory).to receive(:write_xml_file).with(file_inventory, output_dir, 'version')
      end

      it 'calls with expected arguments' do
        file_inventory.write_xml_file(output_dir)
        expect(Moab::FileInventory).to have_received(:write_xml_file).with(file_inventory, output_dir, 'version')
      end
    end

    context 'with SignatureCatalog' do
      let(:signatures) { Moab::SignatureCatalog.new }

      before do
        allow(Moab::SignatureCatalog).to receive(:write_xml_file).with(signatures, output_dir, nil)
      end

      it 'calls with expected arguments' do
        signatures.write_xml_file(output_dir)
        expect(Moab::SignatureCatalog).to have_received(:write_xml_file).with(signatures, output_dir, nil)
      end
    end
  end
end
