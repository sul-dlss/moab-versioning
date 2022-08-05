# frozen_string_literal: true

describe "Determine version's file additions" do
  #  In order to: know which files are new or modified in a new version
  #  The application needs to: compare file signatures against the signature catalog

  it "Generate versionAdditions report" do
    # given: previous version's signature catalog
    #      : and new version's file inventory
    # action: filter the new inventory against the catalog
    # outcome: version additions report

    v1_catalog_pathname = fixtures_dir.join('derivatives/ingests/jq937jp0017/v0001/manifests/signatureCatalog.xml')
    signature_catalog = Moab::SignatureCatalog.parse(v1_catalog_pathname.read)
    v2_inventory_pathname = fixtures_dir.join('derivatives/ingests/jq937jp0017/v0002/manifests/versionInventory.xml')
    v2_inventory = Moab::FileInventory.parse(v2_inventory_pathname.read)
    version_additions = signature_catalog.version_additions(v2_inventory)
    expect(version_additions.groups.count).to eq(2)
    expect(version_additions.file_count).to eq(4)
    expect(version_additions.byte_count).to eq(35181)
    expect(version_additions.block_count).to eq(37)
  end
end
