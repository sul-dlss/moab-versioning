require 'spec_helper'

describe "Manifest file parsing" do
  # In order to: re-create an in-memory object representation of serialized version metadata
  # The application needs to: read in and parse a XML instance containing version metadata

  before(:all) do
    @fixtures = File.join(File.dirname(__FILE__), '..', 'fixtures')
  end

  it "Parse an existing XML file" do
    # given: an signatureCatalog.xml file containing a serialized catalog
    # action: parse the file and transfer data to ruby objects
    # outcome: an in-memory representation of the manifest

    parent_dir = @manifests.join("v0001")
    expect(Moab::SignatureCatalog.xml_pathname(parent_dir)).to eq(parent_dir.join('signatureCatalog.xml'))
    catalog = Moab::SignatureCatalog.read_xml_file(parent_dir)
    expect(catalog).to be_instance_of(Moab::SignatureCatalog)
    expect(catalog.entries.size).to eq(11)
  end

end
