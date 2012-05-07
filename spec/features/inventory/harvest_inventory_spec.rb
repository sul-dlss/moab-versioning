require 'spec_helper'

feature "Harvest file properties from a file directory" do
  # In order to: automate the generation of a file inventory
  # The application needs to: traverse a directory tree and capture file metadata and checksums

  scenario "Generate content and metadata inventory for all files in a version's workspace directory" do
    # given: path to workspace directory
    # action: traverse the directory and capture file metadata
    # outcome: gnerate inventory containing two file groups

    data_dir_1 = @fixtures.join('data/jq937jp0017/v1/metadata')
    group_id = 'metadata'
    inventory_1 = FileInventory.new.inventory_from_directory(data_dir_1,group_id)
    inventory_1.groups.size.should == 1
    inventory_1.groups[0].group_id.should == group_id
    inventory_1.file_count.should == 5

    data_dir_2 = @fixtures.join('data/jq937jp0017/v1')
    inventory_2 = FileInventory.new.inventory_from_directory(data_dir_2)
    inventory_2.groups.size.should == 2
    inventory_2.groups[0].group_id.should == 'content'
    inventory_2.groups[1].group_id.should == 'metadata'
    inventory_2.file_count.should == 11
  end

end

