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

  it '.read_xml_file' do
    parent_dir = manifests_dir.join('v1')
    mock_pathname = double(Pathname.name)
    mock_xml = double('xml')
    expect(Moab::SignatureCatalog).to receive(:xml_pathname).with(parent_dir, nil).and_return(mock_pathname)
    expect(mock_pathname).to receive(:read).and_return(mock_xml)
    expect(Moab::SignatureCatalog).to receive(:parse).with(mock_xml)
    Moab::SignatureCatalog.read_xml_file(parent_dir)
  end

  it '.write_xml_file' do
    xml_object = Moab::SignatureCatalog.read_xml_file(manifests_dir.join('v0001'))
    output_dir = temp_dir
    mock_pathname = double(Pathname.name)
    expect(Moab::SignatureCatalog).to receive(:xml_pathname).with(output_dir, nil).and_return(mock_pathname)
    expect(mock_pathname).to receive(:open).with('w').and_return(an_instance_of(IO))
    Moab::SignatureCatalog.write_xml_file(xml_object, output_dir)
  end

  describe '#write_xml_file' do
    let(:output_dir) { '/my/temp' }

    it 'FileInventory.write_xml_file' do
      pathname = fixtures_dir.join('derivatives/ingests/jq937jp0017/v0001/manifests/versionInventory.xml')
      file_inventory = Moab::FileInventory.parse(pathname.read)
      expect(Moab::FileInventory).to receive(:write_xml_file).with(file_inventory, output_dir, 'version')
      file_inventory.write_xml_file(output_dir)
    end

    it 'SignatureCatalog.write_xml_file' do
      signatures = Moab::SignatureCatalog.new
      expect(Moab::SignatureCatalog).to receive(:write_xml_file).with(signatures, output_dir, nil)
      signatures.write_xml_file(output_dir)
    end
  end
end
