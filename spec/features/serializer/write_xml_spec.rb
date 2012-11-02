require 'spec_helper'

feature "Feature: Manifest Serialization" do
  # In order to: preserve the manifest metadata held by an in-memory object
  # The application needs to: generate a xml file rendition of the metadata for disk storage

  scenario "should serialize signature catalog metadata to XML" do
    # action: a call the object's write_xml_file method
    # outcome: produces a XML document containing all the catalog metadata

    output_dir = @temp.join('catalog')
    output_dir.mkpath
    catalog_object = SignatureCatalog.read_xml_file(@manifests.join("v1"))
    catalog_object.write_xml_file(output_dir)
    catalog_pathname = output_dir.join('signatureCatalog.xml')
    catalog_pathname.read.gsub(/catalogDatetime=".*?"/,'').should be_equivalent_to( <<-EOF
      <signatureCatalog objectId="druid:jq937jp0017" versionId="1"  fileCount="11" byteCount="217811" blockCount="216">
        <entry originalVersion="1" groupId="content" storagePath="intro-1.jpg">
          <fileSignature size="41981" md5="915c0305bf50c55143f1506295dc122c" sha1="60448956fbe069979fce6a6e55dba4ce1f915178" sha256=""/>
        </entry>
        <entry originalVersion="1" groupId="content" storagePath="intro-2.jpg">
          <fileSignature size="39850" md5="77f1a4efdcea6a476505df9b9fba82a7" sha1="a49ae3f3771d99ceea13ec825c9c2b73fc1a9915" sha256=""/>
        </entry>
        <entry originalVersion="1" groupId="content" storagePath="page-1.jpg">
          <fileSignature size="25153" md5="3dee12fb4f1c28351c7482b76ff76ae4" sha1="906c1314f3ab344563acbbbe2c7930f08429e35b" sha256=""/>
        </entry>
        <entry originalVersion="1" groupId="content" storagePath="page-2.jpg">
          <fileSignature size="39450" md5="82fc107c88446a3119a51a8663d1e955" sha1="d0857baa307a2e9efff42467b5abd4e1cf40fcd5" sha256=""/>
        </entry>
        <entry originalVersion="1" groupId="content" storagePath="page-3.jpg">
          <fileSignature size="19125" md5="a5099878de7e2e064432d6df44ca8827" sha1="c0ccac433cf02a6cee89c14f9ba6072a184447a2" sha256=""/>
        </entry>
        <entry originalVersion="1" groupId="content" storagePath="title.jpg">
          <fileSignature size="40873" md5="1a726cd7963bd6d3ceb10a8c353ec166" sha1="583220e0572640abcd3ddd97393d224e8053a6ad" sha256=""/>
        </entry>
        <entry originalVersion="1" groupId="metadata" storagePath="contentMetadata.xml">
          <fileSignature size="1871" md5="8cdee9c3470552d258a4351bf4c117e2" sha1="321737e42cc4a3134164539f768514d4f7f6d184" sha256=""/>
        </entry>
        <entry originalVersion="1" groupId="metadata" storagePath="descMetadata.xml">
          <fileSignature size="3046" md5="a60bb487db6a1ceb5e0b5bb3cae2dfa2" sha1="edefc0e1d7cffd5bd3c7db6a393ab7632b70dc2d" sha256=""/>
        </entry>
        <entry originalVersion="1" groupId="metadata" storagePath="identityMetadata.xml">
          <fileSignature size="932" md5="f0815d7b45530491931d5897ccbe2dd1" sha1="4065ff5523e227c1914098372a3dc587f739030e" sha256=""/>
        </entry>
        <entry originalVersion="1" groupId="metadata" storagePath="provenanceMetadata.xml">
          <fileSignature size="5306" md5="17193dbf595571d728ba59aa31638db9" sha1="c8b91eacf9ad7532a42dc52b3c9cf03b4ad2c7f6" sha256=""/>
        </entry>
        <entry originalVersion="1" groupId="metadata" storagePath="versionMetadata.xml">
          <fileSignature size="224" md5="36e3c1dadad827cb49e521f5d6559127" sha1="af96327b72bf37e3e60cf51c6de4dba1f6dea620" sha256=""/>
        </entry>
      </signatureCatalog>
    EOF
    )
    output_dir.rmtree
  end

end