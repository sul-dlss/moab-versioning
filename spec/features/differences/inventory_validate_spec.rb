require 'spec_helper'

describe "Validate inventory against directory" do
  #  In order to: determine if a file inventory correctly describes a directory
  #  The application needs to: generate a differences report and look for zero changes

  scenario "Generate differences report comparing inventory to directory" do
    # given: a directory path and an existing inventory
    # action: generate an inventory for the directory and compare inventories
    # outcome: true or false result, depending of whether there are no differences

    v1_data_directory = @fixtures.join('data/jq937jp0017/v0001')
    v1_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/manifests/versionInventory.xml')
    v1_inventory = FileInventory.parse(v1_inventory_pathname.read)
    opts = {}
    directory_inventory = FileInventory.new(:type=>'directory').inventory_from_directory(v1_data_directory)
    diff = FileInventoryDifference.new(opts)
    diff.compare(v1_inventory, directory_inventory)
    expect(diff.difference_count).to eq(0)
  end

end
