require 'spec_helper'

feature "Manifest file parsing" do
  # In order to: re-create an in-memory object representation of serialized version metadata
  # The application needs to: read in and parse a XML instance containing version metadata

  background(:all) do
    @fixtures = File.join(File.dirname(__FILE__), '..', 'fixtures')
  end

  scenario "Parse an existing XML file" do
    # given: an signatureCatalog.xml file containing a serialized catalog
    # action: parse the file and transfer data to ruby objects
    # outcome: an in-memory representation of the manifest

    parent_dir = @manifests.join("v0001")
    SignatureCatalog.xml_pathname(parent_dir).should == parent_dir.join('signatureCatalog.xml')
    catalog = SignatureCatalog.read_xml_file(parent_dir)
    catalog.should be_instance_of(SignatureCatalog)
    catalog.entries.size.should == 11
  end

end