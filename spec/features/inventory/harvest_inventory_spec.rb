# frozen_string_literal: true

describe "Harvest file properties from a file directory" do
  # In order to: automate the generation of a file inventory
  # The application needs to: traverse a directory tree and capture file metadata and checksums

  it "Generate content and metadata inventory for all files in a version's workspace directory" do
    # given: path to workspace directory
    # action: traverse the directory and capture file metadata
    # outcome: generate inventory containing two file groups

    data_dir_1 = @fixtures.join('data/jq937jp0017/v0001/metadata')
    group_id = 'metadata'
    inventory_1 = Moab::FileInventory.new.inventory_from_directory(data_dir_1, group_id)
    expect(inventory_1.groups.size).to eq(1)
    expect(inventory_1.groups[0].group_id).to eq(group_id)
    expect(inventory_1.file_count).to eq(5)

    data_dir_2 = @fixtures.join('data/jq937jp0017/v0001')
    inventory_2 = Moab::FileInventory.new.inventory_from_directory(data_dir_2)
    expect(inventory_2.groups.size).to eq(2)
    expect(inventory_2.groups[0].group_id).to eq('content')
    expect(inventory_2.groups[1].group_id).to eq('metadata')
    expect(inventory_2.file_count).to eq(11)
  end
end
