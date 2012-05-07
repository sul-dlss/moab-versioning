require 'spec_helper'

feature "Process contentMetadata datastream" do
  #  In order to: utilize the DOR contentMetadata
  #  The application needs to: extract file inventory data from a contentMetadata datastream

  scenario "Generate content file group from contentMetadata datastream" do
    # given: a contentMetadata datastream instance
    # action: extract the file-level metadata
    # outcome: a fully populated 'content' file group

    digital_object_id = @obj
    version_id = 2
    content_metadata = @data.join('v2/metadata/contentMetadata.xml')
    dor_metadata = DorMetadata.new(digital_object_id, version_id)
    group = dor_metadata.group_from_file(content_metadata)
    group.should be_instance_of(FileGroup)
    group.data_source.should == "contentMetadata"
  end

end