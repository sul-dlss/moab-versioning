require 'spec_helper'

feature "Determine version's file additions" do
  #  In order to: know which files are new or modified in a new version
  #  The application needs to: compare file signatures against the signature catalog

  scenario "Generate versionAdditions report" do
    # given: previous version's signature catalog
    #      : and new version's file inventory
    # action: filter the new inventory against the catalog
    # outcome: version addtions report

    v1_catalog_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/signatureCatalog.xml')
    signature_catalog = SignatureCatalog.parse(v1_catalog_pathname.read)
    v2_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0002/versionInventory.xml')
    v2_inventory = FileInventory.parse(v2_inventory_pathname.read)
    version_additions = signature_catalog.version_additions(v2_inventory)
    version_additions.groups.count.should == 2
    version_additions.file_count.should == 4
    version_additions.byte_count.should == 35584
    version_additions.block_count.should == 37
  end

end