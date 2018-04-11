describe Serializer::Manifest do
  context '.xml_filename' do
    it 'unspecified name returns class name' do
      expect(Moab::SignatureCatalog.xml_filename).to eq("signatureCatalog.xml")
    end
    it 'specified name is returned' do
      expect(Moab::SignatureCatalog.xml_filename("dummy")).to eq("dummy")
    end
  end

  context '.xml_pathname' do
    let(:parent_dir) { Pathname.new("/test/parent_dir") }

    it 'parent_dir specified but no filename' do
      expect(Moab::SignatureCatalog.xml_pathname(parent_dir)).to eq(Pathname("#{parent_dir}/signatureCatalog.xml"))
    end
    it 'both parent_dir and filename specified' do
      expect(Moab::SignatureCatalog.xml_pathname(parent_dir, "dummy")).to eq(Pathname("#{parent_dir}/dummy"))
    end
  end

  specify '.xml_pathname_exist?' do
    expect(described_class.xml_pathname_exist?("/test/parent_dir", "dummy")).to eq(false)
    expect(Moab::SignatureCatalog.xml_pathname_exist?(@manifests.join("v0001"))).to eq(true)
  end

  specify '.read_xml_file' do
    parent_dir = @manifests.join("v1")
    mock_pathname = double(Pathname.name)
    mock_xml = double("xml")
    expect(Moab::SignatureCatalog).to receive(:xml_pathname).with(parent_dir, nil).and_return(mock_pathname)
    expect(mock_pathname).to receive(:read).and_return(mock_xml)
    expect(Moab::SignatureCatalog).to receive(:parse).with(mock_xml)
    Moab::SignatureCatalog.read_xml_file(parent_dir)
  end

  specify '.write_xml_file' do
    xml_object = Moab::SignatureCatalog.read_xml_file(@manifests.join("v0001"))
    #xml_object.should_receive(:to_xml)
    output_dir = @temp
    mock_pathname = double(Pathname.name)
    expect(Moab::SignatureCatalog).to receive(:xml_pathname).with(output_dir, nil).and_return(mock_pathname)
    expect(mock_pathname).to receive(:open).with('w').and_return(an_instance_of(IO))
    Moab::SignatureCatalog.write_xml_file(xml_object, output_dir)
  end

  context '#write_xml_file' do
    let(:output_dir) { "/my/temp" }

    it 'FileInventory.write_xml_file' do
      pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/manifests/versionInventory.xml')
      file_inventory = Moab::FileInventory.parse(pathname.read)
      expect(Moab::FileInventory).to receive(:write_xml_file).with(file_inventory, output_dir, "version")
      file_inventory.write_xml_file(output_dir)
    end

    it 'SignatureCatalog.write_xml_file' do
      signatures = Moab::SignatureCatalog.new
      expect(Moab::SignatureCatalog).to receive(:write_xml_file).with(signatures, output_dir, nil)
      signatures.write_xml_file(output_dir)
    end
  end
end
