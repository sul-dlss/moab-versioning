require 'spec_helper'

feature "Compare inventory against directory" do
  #  In order to: determine the difference between a file inventory and a directory
  #  The application needs to: generate a differences report

  scenario "Generate differences report comparing inventory to directory" do
    # given: a directory path and an existing inventory
    # action: generate an inventory for the directory and compare inventories
    # outcome: differences report

    v1_data_directory = @fixtures.join('data/jq937jp0017/v1')
    v1_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/versionInventory.xml')
    v1_inventory = FileInventory.parse(v1_inventory_pathname.read)
    opts = {}
    file_inventory_difference = FileInventoryDifference.new(opts)
    diff = file_inventory_difference.compare_with_directory(v1_inventory,v1_data_directory)
    diff.group_differences.size.should == 2
    diff.basis.should == "v1"
    diff.other.should include("data/jq937jp0017/v1/content")
    diff.difference_count.should == 0
    diff.digital_object_id.should == "druid:jq937jp0017|"

  end

end