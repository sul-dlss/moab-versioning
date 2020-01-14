# frozen_string_literal: true

describe "Process contentMetadata datastream" do
  #  In order to: utilize the DOR contentMetadata
  #  The application needs to: extract file inventory data from a contentMetadata datastream

  it "Generate content file group from contentMetadata datastream" do
    # given: a contentMetadata datastream instance
    # action: extract the file-level metadata
    # outcome: a fully populated 'content' file group

    digital_object_id = @obj
    version_id = 2
    content_metadata = @data.join('v0002/metadata/contentMetadata.xml')
    group = Stanford::ContentInventory.new.group_from_cm(content_metadata, 'preserve')
    expect(group).to be_instance_of(Moab::FileGroup)
    expect(group.data_source).to eq("contentMetadata-preserve")
  end
end
