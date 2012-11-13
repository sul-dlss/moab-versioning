require 'spec_helper'

# Unit tests for class {Serializer::Manifest}
describe 'Serializer::Manifest' do


  describe '=========================== CLASS METHODS ===========================' do

    # Unit test for method: {Serializer::Manifest.xml_filename}
    # Which returns: [String] Returns the standard filename (derived from the class name) to be used for serializing an object
    # For input parameters:
    # * filename [String] = Optional filename if one wishes to override the default filename
    specify 'Serializer::Manifest.xml_filename' do

      SignatureCatalog.xml_filename().should == "signatureCatalog.xml"
      SignatureCatalog.xml_filename("dummy").should == "dummy"

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
      SignatureCatalog.xml_pathname(parent_dir).should == Pathname("/test/parent_dir/signatureCatalog.xml")
      SignatureCatalog.xml_pathname(parent_dir, "dummy").should == Pathname("/test/parent_dir/dummy")

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
      Manifest.xml_pathname_exist?("/test/parent_dir", "dummy").should == false
      SignatureCatalog.xml_pathname_exist?(@manifests.join("v0001")).should == true

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
      mock_pathname = mock(Pathname.name)
      mock_xml = mock("xml")
      SignatureCatalog.should_receive(:xml_pathname).with(parent_dir, nil).and_return(mock_pathname)
      mock_pathname.should_receive(:read).and_return(mock_xml)
      SignatureCatalog.should_receive(:parse).with(mock_xml)
      SignatureCatalog.read_xml_file(parent_dir)

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
      xml_object = SignatureCatalog.read_xml_file(@manifests.join("v0001"))
      #xml_object.should_receive(:to_xml)
      output_dir = @temp
      mock_pathname = mock(Pathname.name)
      SignatureCatalog.should_receive(:xml_pathname).with(output_dir, nil).and_return(mock_pathname)
      mock_pathname.should_receive(:open).with('w').and_return(an_instance_of(IO))
      SignatureCatalog.write_xml_file(xml_object, output_dir)

      # def self.write_xml_file(xml_object, parent_dir, filename=nil)
      #   self.xml_pathname(parent_dir, filename).open('w') { |f| f << xml_object.to_xml }
      #   nil
      # end
    end

  end

  describe '=========================== CLASS METHODS ===========================' do

    before(:all) do
      @v1_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/manifests/versionInventory.xml')
      @v1_inventory = FileInventory.parse(@v1_inventory_pathname.read)
      @v1_content = @v1_inventory.groups[0]

      @v3_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0003/manifests/versionInventory.xml')
      @v3_inventory = FileInventory.parse(@v3_inventory_pathname.read)
      @v3_content = @v3_inventory.groups[0]
    end

    # Unit test for method: {Serializer::Manifest#write_xml_file}
    # Which returns: [void] Serializize the in-memory object to a xml file instance
    # For input parameters:
    # * parent_dir [Pathname, String] = The location of the directory in which the xml file is located
    # * filename [String] = Optional filename if one wishes to override the default filename
    specify 'Serializer::Manifest#write_xml_file' do
      output_dir = "/my/temp"
      FileInventory.should_receive(:write_xml_file).with(@v1_inventory, output_dir, "version")
      @v1_inventory.write_xml_file(output_dir)

      signatures = SignatureCatalog.new
      SignatureCatalog.should_receive(:write_xml_file).with(signatures, output_dir, nil)
      signatures.write_xml_file(output_dir)

      # def write_xml_file(parent_dir, filename=nil)
      #   self.class.write_xml_file(self, parent_dir, filename)
      # end
    end

  end

end
