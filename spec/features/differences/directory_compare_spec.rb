# frozen_string_literal: true

describe 'Compare inventory against directory' do
  #  In order to: determine the difference between a file inventory and a directory
  #  The application needs to: generate a differences report

  it 'Generate differences report comparing inventory to directory' do
    # given: a directory path and an existing inventory
    # action: generate an inventory for the directory and compare inventories
    # outcome: differences report

    v1_data_directory = fixtures_dir.join('data/jq937jp0017/v0001')
    v1_inventory_pathname = fixtures_dir.join('derivatives/ingests/jq937jp0017/v0001/manifests/versionInventory.xml')
    v1_inventory = Moab::FileInventory.parse(v1_inventory_pathname.read)
    opts = {}
    directory_inventory = Moab::FileInventory.new(type: 'directory').inventory_from_directory(v1_data_directory)
    diff = Moab::FileInventoryDifference.new(opts)
    diff.compare(v1_inventory, directory_inventory)
    expect(diff.group_differences.size).to eq(2)
    expect(diff.basis).to eq('v1')
    expect(diff.other).to include('data/jq937jp0017/v0001/content')
    expect(diff.difference_count).to eq(0)
    expect(diff.digital_object_id).to eq('druid:jq937jp0017|')
  end
end
