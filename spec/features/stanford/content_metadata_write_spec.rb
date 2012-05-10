require 'spec_helper'

feature "Write contentMetadata datastream" do
  #  In order to: generate a contentMetadata datastream
  #  The application needs to: transform data from a file inventory's 'content' file group

  scenario "Generate contentMetadata datastream from a FileGroup object" do
    # given: a FileGroup instance
    # action: extract the file-level metadata
    # outcome: a fully populated contentMetadata datastream

    directory = @data.join('v2/content')
    recursive = true
    group= FileGroup.new.group_from_directory(directory, recursive)
    digital_object_id = @obj
    version_id = 2
    cm = ContentInventory.new.generate_content_metadata(group,digital_object_id, version_id)
    cm.should be_equivalent_to(<<EOF
<?xml version="1.0"?>
<contentMetadata objectId="jq937jp0017" type="sample">
<resource type="version" sequence="1" id="version-2">
  <file size="32915" id="page-1.jpg" datetime="2012-03-26T15:35:15Z">
    <checksum type="MD5">c1c34634e2f18a354cd3e3e1574c3194</checksum>
    <checksum type="SHA-1">0616a0bd7927328c364b2ea0b4a79c507ce915ed</checksum>
  </file>
  <file size="39450" id="page-2.jpg" datetime="2012-03-26T15:23:36Z">
    <checksum type="MD5">82fc107c88446a3119a51a8663d1e955</checksum>
    <checksum type="SHA-1">d0857baa307a2e9efff42467b5abd4e1cf40fcd5</checksum>
  </file>
  <file size="19125" id="page-3.jpg" datetime="2012-03-26T15:24:39Z">
    <checksum type="MD5">a5099878de7e2e064432d6df44ca8827</checksum>
    <checksum type="SHA-1">c0ccac433cf02a6cee89c14f9ba6072a184447a2</checksum>
  </file>
  <file size="40873" id="title.jpg" datetime="2012-03-26T14:15:11Z">
    <checksum type="MD5">1a726cd7963bd6d3ceb10a8c353ec166</checksum>
    <checksum type="SHA-1">583220e0572640abcd3ddd97393d224e8053a6ad</checksum>
  </file>
</resource>
</contentMetadata>
EOF
  )
  end



end