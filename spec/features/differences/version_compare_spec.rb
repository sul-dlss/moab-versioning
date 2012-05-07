require 'spec_helper'

feature "Compare versions" do
  #  In order to: determine what changes are present in a new version
  #  The application needs to: compare file inventories

  scenario "Compare fileInventory objects of 2 versions" do
    # given: two fileInventory instances
    # action: parse the XML to create in-memory objects
    #       : compare the inventories
    # outcome: a report of which files have changed

   # @v1_data_directory = @fixtures.join('data/jq937jp0017/v1')
    v1_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/versionInventory.xml')
    v1_inventory = FileInventory.parse(v1_inventory_pathname.read)
    v2_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0002/versionInventory.xml')
    v2_inventory = FileInventory.parse(v2_inventory_pathname.read)
    opts = {}
    file_inventory_difference = FileInventoryDifference.new(opts)
    basis_inventory = v1_inventory
    other_inventory = v2_inventory
    diff = file_inventory_difference.compare(basis_inventory, other_inventory)
    diff.should be_instance_of(FileInventoryDifference)
    diff.group_differences.size.should == 2
    diff.basis.should == "v1"
    diff.other.should == "v2"
    diff.difference_count.should == 6
    diff.digital_object_id.should == "druid:jq937jp0017"
  end

end