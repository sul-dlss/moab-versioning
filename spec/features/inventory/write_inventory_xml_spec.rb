require 'spec_helper'

feature "Feature: File Inventory Serialization" do
  # In order to: preserve the file inventory data held by an in-memory object
  # The application needs to: generate a xml file rendition of the metadata for disk storage

  scenario "should serialize file inventory data to XML" do
    # action: a call the object's write_xml_file method
    # outcome: produces a XML document containing all the inventory metadata

    inventory_object = FileInventory.read_xml_file(@manifests.join("v1"),'version')
    output_dir = @temp.join('inventory')
    output_dir.mkpath
    inventory_object.write_xml_file(output_dir,'version')
    inventory_pathname = output_dir.join('versionInventory.xml')
    inventory_pathname.read.should be_equivalent_to(<<EOF
    <?xml version="1.0" encoding="UTF-8"?>
    <fileInventory type="version" objectId="druid:jq937jp0017" versionId="1" inventoryDatetime="2012-04-19T12:12:47Z" fileCount="11" byteCount="229690" blockCount="228">
      <fileGroup groupId="content" dataSource="/Users/rnanders/Code/Ruby/moab-versioning/spec/fixtures/data/jq937jp0017/v1/content" fileCount="6" byteCount="206432" blockCount="203">
        <file>
          <fileSignature size="41981" md5="915c0305bf50c55143f1506295dc122c" sha1="60448956fbe069979fce6a6e55dba4ce1f915178"/>
          <fileInstance path="intro-1.jpg" datetime="2012-03-26T14:20:35Z"/>
        </file>
        <file>
          <fileSignature size="39850" md5="77f1a4efdcea6a476505df9b9fba82a7" sha1="a49ae3f3771d99ceea13ec825c9c2b73fc1a9915"/>
          <fileInstance path="intro-2.jpg" datetime="2012-03-26T14:19:30Z"/>
        </file>
        <file>
          <fileSignature size="25153" md5="3dee12fb4f1c28351c7482b76ff76ae4" sha1="906c1314f3ab344563acbbbe2c7930f08429e35b"/>
          <fileInstance path="page-1.jpg" datetime="2012-03-26T15:59:14Z"/>
        </file>
        <file>
          <fileSignature size="39450" md5="82fc107c88446a3119a51a8663d1e955" sha1="d0857baa307a2e9efff42467b5abd4e1cf40fcd5"/>
          <fileInstance path="page-2.jpg" datetime="2012-03-26T15:23:36Z"/>
        </file>
        <file>
          <fileSignature size="19125" md5="a5099878de7e2e064432d6df44ca8827" sha1="c0ccac433cf02a6cee89c14f9ba6072a184447a2"/>
          <fileInstance path="page-3.jpg" datetime="2012-03-26T15:24:39Z"/>
        </file>
        <file>
          <fileSignature size="40873" md5="1a726cd7963bd6d3ceb10a8c353ec166" sha1="583220e0572640abcd3ddd97393d224e8053a6ad"/>
          <fileInstance path="title.jpg" datetime="2012-03-26T14:15:11Z"/>
        </file>
      </fileGroup>
      <fileGroup groupId="metadata" dataSource="/Users/rnanders/Code/Ruby/moab-versioning/spec/fixtures/data/jq937jp0017/v1/metadata" fileCount="5" byteCount="23258" blockCount="25">
        <file>
          <fileSignature size="1619" md5="b886db0d14508884150a916089da840f" sha1="b2328faaf25caf037cfc0263896ad707fc3a47a7"/>
          <fileInstance path="contentMetadata.xml" datetime="2012-03-28T14:04:24Z"/>
        </file>
        <file>
          <fileSignature size="3046" md5="a60bb487db6a1ceb5e0b5bb3cae2dfa2" sha1="edefc0e1d7cffd5bd3c7db6a393ab7632b70dc2d"/>
          <fileInstance path="descMetadata.xml" datetime="2012-03-26T17:43:49Z"/>
        </file>
        <file>
          <fileSignature size="12903" md5="ccb5bf2ae0c2c6ad0b89692fa1e10145" sha1="3badb0d06aef40f14e4664d2594c6060b9e9716b"/>
          <fileInstance path="identityMetadata.xml" datetime="2012-03-26T17:44:48Z"/>
        </file>
        <file>
          <fileSignature size="5306" md5="17193dbf595571d728ba59aa31638db9" sha1="c8b91eacf9ad7532a42dc52b3c9cf03b4ad2c7f6"/>
          <fileInstance path="provenanceMetadata.xml" datetime="2012-03-26T17:46:44Z"/>
        </file>
        <file>
          <fileSignature size="384" md5="f16a2564fae2706a8c82cda6dccdb4d9" sha1="7aaf84f63a1db803d272352f03935d303f066560"/>
          <fileInstance path="versionMetadata.xml" datetime="2012-04-11T16:10:00Z"/>
        </file>
      </fileGroup>
    </fileInventory>

EOF
    )
    output_dir.rmtree
  end

end