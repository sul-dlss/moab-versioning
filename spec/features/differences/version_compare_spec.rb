# frozen_string_literal: true

describe 'Compare versions' do
  #  In order to: determine what changes are present in a new version
  #  The application needs to: compare file inventories

  it 'Compare fileInventory objects of 2 versions' do
    # given: two fileInventory instances
    # action: parse the XML to create in-memory objects
    #       : compare the inventories
    # outcome: a report of which files have changed

   # @v1_data_directory = fixtures_dir.join('data/jq937jp0017/v0001')
    v1_inventory_pathname = fixtures_dir.join('derivatives/ingests/jq937jp0017/v0001/manifests/versionInventory.xml')
    v1_inventory = Moab::FileInventory.parse(v1_inventory_pathname.read)
    v2_inventory_pathname = fixtures_dir.join('derivatives/ingests/jq937jp0017/v0002/manifests/versionInventory.xml')
    v2_inventory = Moab::FileInventory.parse(v2_inventory_pathname.read)
    opts = {}
    file_inventory_difference = Moab::FileInventoryDifference.new(opts)
    basis_inventory = v1_inventory
    other_inventory = v2_inventory
    diff = file_inventory_difference.compare(basis_inventory, other_inventory)
    expect(diff).to be_instance_of(Moab::FileInventoryDifference)
    expect(diff.group_differences.size).to eq(2)
    expect(diff.basis).to eq('v1')
    expect(diff.other).to eq('v2')
    expect(diff.difference_count).to eq(6)
    expect(diff.digital_object_id).to eq('druid:jq937jp0017')
  end
end
