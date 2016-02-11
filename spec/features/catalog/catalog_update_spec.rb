require 'spec_helper'

describe "Update the signature catalog" do
  #  In order to: add the files that are new or modified in a new version
  #  The application needs to: compare a new version's' file signatures against the signature catalog

  scenario "Add a new version to the signature catalog" do
    # given: previous version's signature catalog
    #      : and new version's file inventory
    # action: filter the new inventory against the catalog
    # outcome: updated signature catalog

    v1_catalog_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/manifests/signatureCatalog.xml')
    signature_catalog = Moab::SignatureCatalog.parse(v1_catalog_pathname.read)
    v2_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0002/manifests/versionInventory.xml')
    v2_inventory = Moab::FileInventory.parse(v2_inventory_pathname.read)
    original_entry_count = signature_catalog.entries.count
    signature_catalog.update(v2_inventory,v1_catalog_pathname.parent.parent.join('data'))
    expect(signature_catalog.entries.count).to eq(original_entry_count + 4)
  end

end
