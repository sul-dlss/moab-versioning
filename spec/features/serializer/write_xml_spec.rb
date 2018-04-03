describe "Feature: Manifest Serialization" do
  # In order to: preserve the manifest metadata held by an in-memory object
  # The application needs to: generate a xml file rendition of the metadata for disk storage

  it "serializes signature catalog metadata to XML" do
    # action: a call the object's write_xml_file method
    # outcome: produces a XML document containing all the catalog metadata

    output_dir = @temp.join('catalog')
    output_dir.mkpath
    catalog_object = Moab::SignatureCatalog.read_xml_file(@manifests.join("v0001"))
    catalog_object.write_xml_file(output_dir)
    catalog_pathname = output_dir.join('signatureCatalog.xml')
    xmlObj1 = Nokogiri::XML(catalog_pathname.read)
    xmlObj1.xpath('//@catalogDatetime').remove
    output_dir.rmtree

    catalog_test = <<-XML
      <signatureCatalog objectId="druid:jq937jp0017" versionId="1"  fileCount="11" byteCount="217820" blockCount="216">
        <entry originalVersion="1" groupId="content" storagePath="intro-1.jpg">
          <fileSignature size="41981" md5="915c0305bf50c55143f1506295dc122c" sha1="60448956fbe069979fce6a6e55dba4ce1f915178" sha256="4943c6ffdea7e33b74fd7918de900de60e9073148302b0ad1bf5df0e6cec032a"/>
        </entry>
        <entry originalVersion="1" groupId="content" storagePath="intro-2.jpg">
          <fileSignature size="39850" md5="77f1a4efdcea6a476505df9b9fba82a7" sha1="a49ae3f3771d99ceea13ec825c9c2b73fc1a9915" sha256="3a28718a8867e4329cd0363a84aee1c614d0f11229a82e87c6c5072a6e1b15e7"/>
        </entry>
        <entry originalVersion="1" groupId="content" storagePath="page-1.jpg">
          <fileSignature size="25153" md5="3dee12fb4f1c28351c7482b76ff76ae4" sha1="906c1314f3ab344563acbbbe2c7930f08429e35b" sha256="41aaf8598c9d8e3ee5d55efb9be11c542099d9f994b5935995d0abea231b8bad"/>
        </entry>
        <entry originalVersion="1" groupId="content" storagePath="page-2.jpg">
          <fileSignature size="39450" md5="82fc107c88446a3119a51a8663d1e955" sha1="d0857baa307a2e9efff42467b5abd4e1cf40fcd5" sha256="235de16df4804858aefb7690baf593fb572d64bb6875ec522a4eea1f4189b5f0"/>
        </entry>
        <entry originalVersion="1" groupId="content" storagePath="page-3.jpg">
          <fileSignature size="19125" md5="a5099878de7e2e064432d6df44ca8827" sha1="c0ccac433cf02a6cee89c14f9ba6072a184447a2" sha256="7bd120459eff0ecd21df94271e5c14771bfca5137d1dd74117b6a37123dfe271"/>
        </entry>
        <entry originalVersion="1" groupId="content" storagePath="title.jpg">
          <fileSignature size="40873" md5="1a726cd7963bd6d3ceb10a8c353ec166" sha1="583220e0572640abcd3ddd97393d224e8053a6ad" sha256="8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5"/>
        </entry>
        <entry originalVersion="1" groupId="metadata" storagePath="contentMetadata.xml">
          <fileSignature size="1871" md5="8cdee9c3470552d258a4351bf4c117e2" sha1="321737e42cc4a3134164539f768514d4f7f6d184" sha256="af38d344d9aee248b01b0af9c85dffbfbd1aeb0f2c6dadf3620797ca73ab24c3"/>
        </entry>
        <entry originalVersion="1" groupId="metadata" storagePath="descMetadata.xml">
          <fileSignature size="3055" md5="19c96e98dd25dd68c493faa6a0fde4d0" sha1="541d5845cc866d7676fa43c337b3f7a59f597487" sha256="a575d9058a56d77a4e65e2b1bedb619686a03d5f717374bd0df98d422432e1fe"/>
        </entry>
        <entry originalVersion="1" groupId="metadata" storagePath="identityMetadata.xml">
          <fileSignature size="932" md5="f0815d7b45530491931d5897ccbe2dd1" sha1="4065ff5523e227c1914098372a3dc587f739030e" sha256="f48727374e73776d00517dcdc8af62ec8b18a24cff46c66a5c5f85515144628e"/>
        </entry>
        <entry originalVersion="1" groupId="metadata" storagePath="provenanceMetadata.xml">
          <fileSignature size="5306" md5="17193dbf595571d728ba59aa31638db9" sha1="c8b91eacf9ad7532a42dc52b3c9cf03b4ad2c7f6" sha256="d38899a57d4cfca2b1ac73356c8a89cd3c902d35b853ae52f468004887b73dbe"/>
        </entry>
        <entry originalVersion="1" groupId="metadata" storagePath="versionMetadata.xml">
          <fileSignature size="224" md5="36e3c1dadad827cb49e521f5d6559127" sha1="af96327b72bf37e3e60cf51c6de4dba1f6dea620" sha256="65426a7389e13dfa73d37c0ab1417c3e31de74289bf77cc74b3dcc3ffa6f4c8e"/>
        </entry>
      </signatureCatalog>
    XML
    xmlObj2 = Nokogiri::XML(catalog_test)
    opts = { :element_order => false, :normalize_whitespace => true }
    expect(EquivalentXml.equivalent?(xmlObj1, xmlObj2, opts)).to be true
  end
end
