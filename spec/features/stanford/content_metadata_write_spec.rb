# frozen_string_literal: true

describe "Write contentMetadata datastream" do
  #  In order to: generate a contentMetadata datastream
  #  The application needs to: transform data from a file inventory's 'content' file group

  it "Generate contentMetadata datastream from a Moab::FileGroup object" do
    # given: a Moab::FileGroup instance
    # action: extract the file-level metadata
    # outcome: a fully populated contentMetadata datastream

    directory = data_dir.join('v0002/content')
    recursive = true
    group = Moab::FileGroup.new.group_from_directory(directory, recursive)
    version_id = 2
    cm = Stanford::ContentInventory.new.generate_content_metadata(group, BARE_TEST_DRUID, version_id)
    xmlObj1 = Nokogiri::XML(cm)
    xmlObj1.xpath('//@datetime').remove

    cm_test = <<-XML
      <contentMetadata type="sample" objectId="jq937jp0017">
        <resource type="version" sequence="1" id="version-2">
          <file publish="yes"  preserve="yes" size="32915" shelve="yes" id="page-1.jpg">
            <checksum type="MD5">c1c34634e2f18a354cd3e3e1574c3194</checksum>
            <checksum type="SHA-1">0616a0bd7927328c364b2ea0b4a79c507ce915ed</checksum>
            <checksum type="SHA-256">b78cc53b7b8d9ed86d5e3bab3b699c7ed0db958d4a111e56b6936c8397137de0</checksum>
          </file>
          <file publish="yes"  preserve="yes" size="39450" shelve="yes" id="page-2.jpg">
            <checksum type="MD5">82fc107c88446a3119a51a8663d1e955</checksum>
            <checksum type="SHA-1">d0857baa307a2e9efff42467b5abd4e1cf40fcd5</checksum>
            <checksum type="SHA-256">235de16df4804858aefb7690baf593fb572d64bb6875ec522a4eea1f4189b5f0</checksum>
          </file>
          <file publish="yes"  preserve="yes" size="19125" shelve="yes" id="page-3.jpg">
            <checksum type="MD5">a5099878de7e2e064432d6df44ca8827</checksum>
            <checksum type="SHA-1">c0ccac433cf02a6cee89c14f9ba6072a184447a2</checksum>
            <checksum type="SHA-256">7bd120459eff0ecd21df94271e5c14771bfca5137d1dd74117b6a37123dfe271</checksum>
          </file>
          <file publish="yes"  preserve="yes" size="40873" shelve="yes" id="title.jpg">
            <checksum type="MD5">1a726cd7963bd6d3ceb10a8c353ec166</checksum>
            <checksum type="SHA-1">583220e0572640abcd3ddd97393d224e8053a6ad</checksum>
            <checksum type="SHA-256">8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5</checksum>
          </file>
        </resource>
      </contentMetadata>
    XML
    xmlObj2 = Nokogiri::XML(cm_test)
    opts = { element_order: false, normalize_whitespace: true }
    expect(EquivalentXml.equivalent?(xmlObj1, xmlObj2, opts)).to be true
  end
end
