require 'spec_helper'

# Unit tests for class {Serializer::Manifest}
describe 'Serializer::Manifest' do


  describe '=========================== CLASS METHODS ===========================' do

    # Unit test for method: {Serializer::Manifest.xml_filename}
    # Which returns: [String] Returns the standard filename (derived from the class name) to be used for serializing an object
    # For input parameters:
    # * filename [String] = Optional filename if one wishes to override the default filename
    specify 'Serializer::Manifest.xml_filename' do

      expect(Moab::SignatureCatalog.xml_filename()).to eq("signatureCatalog.xml")
      expect(Moab::SignatureCatalog.xml_filename("dummy")).to eq("dummy")

      # def self.xml_filename(filename=nil)
      #   if filename
      #     filename
      #   else
      #     cname = self.name.split(/::/).last
      #     cname[0, 1].downcase + cname[1..-1] + '.xml'
      #   end
      # end
    end

    # Unit test for method: {Serializer::Manifest.xml_pathname}
    # Which returns: [Pathname] The location of the xml file
    # For input parameters:
    # * parent_dir [Pathname, String] = The location of the directory in which the xml file is located
    # * filename [String] = Optional filename if one wishes to override the default filename
    specify 'Serializer::Manifest.xml_pathname' do
      parent_dir = Pathname.new("/test/parent_dir")
      expect(Moab::SignatureCatalog.xml_pathname(parent_dir)).to eq(Pathname("/test/parent_dir/signatureCatalog.xml"))
      expect(Moab::SignatureCatalog.xml_pathname(parent_dir, "dummy")).to eq(Pathname("/test/parent_dir/dummy"))

      # def self.xml_pathname(parent_dir, filename=nil)
      #   Pathname.new(parent_dir).join(self.xml_filename(filename))
      # end
    end

    # Unit test for method: {Serializer::Manifest.xml_pathname_exist?}
    # Which returns: [Boolean] Returns true if the xml file exists
    # For input parameters:
    # * parent_dir [Pathname, String] = The location of the directory in which the xml file is located
    # * filename [String] = Optional filename if one wishes to override the default filename
    specify 'Serializer::Manifest.xml_pathname_exist?' do
      expect(Manifest.xml_pathname_exist?("/test/parent_dir", "dummy")).to eq(false)
      expect(Moab::SignatureCatalog.xml_pathname_exist?(@manifests.join("v0001"))).to eq(true)

      # def self.xml_pathname_exist?(parent_dir, filename=nil)
      #   self.xml_pathname(parent_dir, filename).exist?
      # end
    end

    # Unit test for method: {Serializer::Manifest.read_xml_file}
    # Which returns: [Serializable] Read the xml file and return the parsed XML
    # For input parameters:
    # * parent_dir [Pathname, String] = The location of the directory in which the xml file is located
    # * filename [String] = Optional filename if one wishes to override the default filename
    specify 'Serializer::Manifest.read_xml_file' do
      parent_dir = @manifests.join("v1")
      mock_pathname = double(Pathname.name)
      mock_xml = double("xml")
      expect(Moab::SignatureCatalog).to receive(:xml_pathname).with(parent_dir, nil).and_return(mock_pathname)
      expect(mock_pathname).to receive(:read).and_return(mock_xml)
      expect(Moab::SignatureCatalog).to receive(:parse).with(mock_xml)
      Moab::SignatureCatalog.read_xml_file(parent_dir)

      # def self.read_xml_file(parent_dir, filename=nil)
      #   self.parse(self.xml_pathname(parent_dir, filename).read)
      # end
    end

    # Unit test for method: {Serializer::Manifest.write_xml_file}
    # Which returns: [void] Serializize the in-memory object to a xml file instance
    # For input parameters:
    # * xml_object [Serializable] =
    # * parent_dir [Pathname, String] = The location of the directory in which the xml file is located
    # * filename [String] = Optional filename if one wishes to override the default filename
    specify 'Serializer::Manifest.write_xml_file' do
      xml_object = Moab::SignatureCatalog.read_xml_file(@manifests.join("v0001"))
      #xml_object.should_receive(:to_xml)
      output_dir = @temp
      mock_pathname = double(Pathname.name)
      expect(Moab::SignatureCatalog).to receive(:xml_pathname).with(output_dir, nil).and_return(mock_pathname)
      expect(mock_pathname).to receive(:open).with('w').and_return(an_instance_of(IO))
      Moab::SignatureCatalog.write_xml_file(xml_object, output_dir)

      # def self.write_xml_file(xml_object, parent_dir, filename=nil)
      #   self.xml_pathname(parent_dir, filename).open('w') { |f| f << xml_object.to_xml }
      #   nil
      # end
    end

  end

  describe '=========================== CLASS METHODS ===========================' do

    before(:all) do
      @v1_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/manifests/versionInventory.xml')
      @v1_inventory = Moab::FileInventory.parse(@v1_inventory_pathname.read)
      @v1_content = @v1_inventory.groups[0]

      @v3_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0003/manifests/versionInventory.xml')
      @v3_inventory = Moab::FileInventory.parse(@v3_inventory_pathname.read)
      @v3_content = @v3_inventory.groups[0]
    end

    # Unit test for method: {Serializer::Manifest#write_xml_file}
    # Which returns: [void] Serializize the in-memory object to a xml file instance
    # For input parameters:
    # * parent_dir [Pathname, String] = The location of the directory in which the xml file is located
    # * filename [String] = Optional filename if one wishes to override the default filename
    specify 'Serializer::Manifest#write_xml_file' do
      output_dir = "/my/temp"
      expect(Moab::FileInventory).to receive(:write_xml_file).with(@v1_inventory, output_dir, "version")
      @v1_inventory.write_xml_file(output_dir)

      signatures = Moab::SignatureCatalog.new
      expect(Moab::SignatureCatalog).to receive(:write_xml_file).with(signatures, output_dir, nil)
      signatures.write_xml_file(output_dir)

      # def write_xml_file(parent_dir, filename=nil)
      #   self.class.write_xml_file(self, parent_dir, filename)
      # end
    end

  end

end
