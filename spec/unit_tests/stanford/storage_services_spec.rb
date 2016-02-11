require 'spec_helper'

# Unit tests for class {Stanford::StorageServices}
describe 'Stanford::StorageServices' do
  
  describe '=========================== CLASS METHODS ===========================' do

    before (:all) do
      @digital_object_id = @obj
      @version_id = 2
      @content_metadata = IO.read(@data.join('v0002/metadata/contentMetadata.xml'))
      @content_metadata_empty_subset = IO.read(@fixtures.join('bad_data/contentMetadata-empty-subsets.xml'))
    end

    specify 'Stanford::StorageServices.cm_remediate' do
      remediated_cm = Stanford::StorageServices.cm_remediate(@digital_object_id,1)
      xmlObj1 = Nokogiri::XML(remediated_cm)
      xmlTest = <<-EOF
      <contentMetadata type="sample" objectId="druid:jq937jp0017">
          <resource type="version" sequence="1" id="version-1">
              <file datetime="2012-03-26T08:15:11-06:00" size="40873" id="title.jpg" shelve="yes" publish="yes" preserve="yes">
                  <checksum type="MD5">1a726cd7963bd6d3ceb10a8c353ec166</checksum>
                  <checksum type="SHA-1">583220e0572640abcd3ddd97393d224e8053a6ad</checksum>
                  <checksum type="SHA-256">8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5</checksum>
              </file>
              <file datetime="2012-03-26T08:20:35-06:00" size="41981" id="intro-1.jpg" shelve="yes" publish="yes" preserve="yes">
                  <checksum type="MD5">915c0305bf50c55143f1506295dc122c</checksum>
                  <checksum type="SHA-1">60448956fbe069979fce6a6e55dba4ce1f915178</checksum>
                  <checksum type="SHA-256">4943c6ffdea7e33b74fd7918de900de60e9073148302b0ad1bf5df0e6cec032a</checksum>
              </file>
              <file datetime="2012-03-26T08:19:30-06:00" size="39850" id="intro-2.jpg" shelve="yes" publish="yes" preserve="yes">
                  <checksum type="MD5">77f1a4efdcea6a476505df9b9fba82a7</checksum>
                  <checksum type="SHA-1">a49ae3f3771d99ceea13ec825c9c2b73fc1a9915</checksum>
                  <checksum type="SHA-256">3a28718a8867e4329cd0363a84aee1c614d0f11229a82e87c6c5072a6e1b15e7</checksum>
              </file>
              <file datetime="2012-03-26T09:59:14-06:00" size="25153" id="page-1.jpg" shelve="yes" publish="yes" preserve="yes">
                  <checksum type="MD5">3dee12fb4f1c28351c7482b76ff76ae4</checksum>
                  <checksum type="SHA-1">906c1314f3ab344563acbbbe2c7930f08429e35b</checksum>
                  <checksum type="SHA-256">41aaf8598c9d8e3ee5d55efb9be11c542099d9f994b5935995d0abea231b8bad</checksum>
              </file>
              <file datetime="2012-03-26T09:23:36-06:00" size="39450" id="page-2.jpg" shelve="yes" publish="yes" preserve="yes">
                  <checksum type="MD5">82fc107c88446a3119a51a8663d1e955</checksum>
                  <checksum type="SHA-1">d0857baa307a2e9efff42467b5abd4e1cf40fcd5</checksum>
                  <checksum type="SHA-256">235de16df4804858aefb7690baf593fb572d64bb6875ec522a4eea1f4189b5f0</checksum>
              </file>
              <file datetime="2012-03-26T09:24:39-06:00" size="19125" id="page-3.jpg" shelve="yes" publish="yes" preserve="yes">
                  <checksum type="MD5">a5099878de7e2e064432d6df44ca8827</checksum>
                  <checksum type="SHA-1">c0ccac433cf02a6cee89c14f9ba6072a184447a2</checksum>
                  <checksum type="SHA-256">7bd120459eff0ecd21df94271e5c14771bfca5137d1dd74117b6a37123dfe271</checksum>
              </file>
          </resource>
      </contentMetadata>
      EOF
      xmlObj2 = Nokogiri::XML(xmlTest)
      same = EquivalentXml.equivalent?(xmlObj1, xmlObj2, opts = { :element_order => false, :normalize_whitespace => true })
      expect(same).to be true
    end


    # Unit test for method: {Stanford::StorageServices.compare_cm_to_version_inventory}
    # Which returns: [Moab::FileInventoryDifference] The report of differences between the content metadata and the specified version
    # For input parameters:
    # * content_metadata [String] = The content metadata to be compared 
    # * object_id [String] = The digital object identifier of the object whose version inventory is the basis of the comparison 
    # * version_id [Integer] = The ID of the version whose inventory is to be compared, if nil use latest version 
    specify 'Stanford::StorageServices.compare_cm_to_version_inventory' do
      diff = Stanford::StorageServices.compare_cm_to_version(@content_metadata, @druid, 'all', 1)
      expect(diff).to be_instance_of(Moab::FileInventoryDifference)
      xmlObj1 = Nokogiri::XML(diff.to_xml)
      xmlObj1.xpath('//@reportDatetime').remove
      xmlTest = <<-EOF
        <fileInventoryDifference objectId="druid:jq937jp0017" differenceCount="3" basis="v1-contentMetadata-all" other="new-contentMetadata-all" >
          <fileGroupDifference groupId="content" differenceCount="3" identical="3" copyadded="0" copydeleted="0" renamed="0" modified="1" deleted="2" added="0">
            <subset change="identical" count="3">
              <file change="identical" basisPath="title.jpg" otherPath="same">
                <fileSignature size="40873" md5="1a726cd7963bd6d3ceb10a8c353ec166" sha1="583220e0572640abcd3ddd97393d224e8053a6ad" sha256=""/>
              </file>
              <file change="identical" basisPath="page-2.jpg" otherPath="same">
                <fileSignature size="39450" md5="82fc107c88446a3119a51a8663d1e955" sha1="d0857baa307a2e9efff42467b5abd4e1cf40fcd5" sha256=""/>
              </file>
              <file change="identical" basisPath="page-3.jpg" otherPath="same">
                <fileSignature size="19125" md5="a5099878de7e2e064432d6df44ca8827" sha1="c0ccac433cf02a6cee89c14f9ba6072a184447a2" sha256=""/>
              </file>
            </subset>
            <subset change="copyadded" count="0"/>
            <subset change="copydeleted" count="0"/>
            <subset change="renamed" count="0"/>
            <subset change="modified" count="1">
              <file change="modified" basisPath="page-1.jpg" otherPath="same">
                <fileSignature size="25153" md5="3dee12fb4f1c28351c7482b76ff76ae4" sha1="906c1314f3ab344563acbbbe2c7930f08429e35b" sha256=""/>
                <fileSignature size="32915" md5="c1c34634e2f18a354cd3e3e1574c3194" sha1="0616a0bd7927328c364b2ea0b4a79c507ce915ed" sha256=""/>
              </file>
            </subset>
            <subset change="deleted" count="2">
              <file change="deleted" basisPath="intro-1.jpg" otherPath="">
                <fileSignature size="41981" md5="915c0305bf50c55143f1506295dc122c" sha1="60448956fbe069979fce6a6e55dba4ce1f915178" sha256=""/>
              </file>
              <file change="deleted" basisPath="intro-2.jpg" otherPath="">
                <fileSignature size="39850" md5="77f1a4efdcea6a476505df9b9fba82a7" sha1="a49ae3f3771d99ceea13ec825c9c2b73fc1a9915" sha256=""/>
              </file>
            </subset>
            <subset change="added" count="0"/>
          </fileGroupDifference>
        </fileInventoryDifference>
      EOF
      xmlObj2 = Nokogiri::XML(xmlTest)
      same = EquivalentXml.equivalent?(xmlObj1, xmlObj2, opts = { :element_order => false, :normalize_whitespace => true })
      expect(same).to be true

      druid = "druid:dd116zh0343"
      base_cm = @fixtures.join('data/dd116zh0343/v0001/metadata/contentMetadata.xml')
      new_cm = IO.read(@fixtures.join('data/dd116zh0343/v0002/metadata/contentMetadata.xml'))
      expect(StorageServices).to receive(:retrieve_file).with('metadata', 'contentMetadata.xml', druid, 1).and_return(base_cm)
      diff = Stanford::StorageServices.compare_cm_to_version(new_cm, druid, 'shelve', 1)
      xmlObj1 = Nokogiri::XML(diff.to_xml)
      xmlObj1.xpath('//@reportDatetime').remove
      xmlTest = <<-EOF
        <fileInventoryDifference objectId="druid:dd116zh0343" differenceCount="12" basis="v1-contentMetadata-shelve" other="new-contentMetadata-shelve" >
          <fileGroupDifference groupId="content" differenceCount="12" identical="1" copyadded="0" copydeleted="0" renamed="1" modified="1" deleted="5" added="5">
            <subset change="identical" count="1">
              <file change="identical" basisPath="folder1PuSu/story1u.txt" otherPath="same">
                <fileSignature size="7888" md5="e2837b9f02e0b0b76f526eeb81c7aa7b" sha1="61dfac472b7904e1413e0cbf4de432bda2a97627" sha256=""/>
              </file>
            </subset>
            <subset change="copyadded" count="0"/>
            <subset change="copydeleted" count="0"/>
            <subset change="renamed" count="1">
              <file change="renamed" basisPath="folder1PuSu/story2r.txt" otherPath="folder1PuSu/story2rr.txt">
                <fileSignature size="5983" md5="dc2be64ae43f1c1db4a068603465955d" sha1="b8a672c1848fc3d13b5f380e15835690e24600e0" sha256=""/>
              </file>
            </subset>
            <subset change="modified" count="1">
              <file change="modified" basisPath="folder1PuSu/story3m.txt" otherPath="same">
                <fileSignature size="5951" md5="3d67f52e032e36b641d0cad40816f048" sha1="548f349c79928b6d0996b7ff45990bdce5ee9753" sha256=""/>
                <fileSignature size="5941" md5="1e5579b16888678f24a1b7008ba15f75" sha1="045245ae45508f92ef82f03eb54290dce92fca64" sha256=""/>
              </file>
            </subset>
            <subset change="deleted" count="5">
              <file change="deleted" basisPath="folder1PuSu/story4d.txt" otherPath="">
                <fileSignature size="6307" md5="34f3f646523b0a8504f216483a57bce4" sha1="d498b513add5bb138ed4f6205453a063a2434dc4" sha256=""/>
              </file>
              <file change="deleted" basisPath="folder3PaSd/storyBu.txt" otherPath="">
                <fileSignature size="14964" md5="8f0a828f3e63cd18232c191ab0c5805c" sha1="b6cb7aa60dd07b4dcc6ab709437e574912f25f30" sha256=""/>
              </file>
              <file change="deleted" basisPath="folder3PaSd/storyCr.txt" otherPath="">
                <fileSignature size="23485" md5="3486492e40b4c342b25ae4f9c64f06ee" sha1="a1654e9d3cf80242cc3669f89fb41b2ec5e62cb7" sha256=""/>
              </file>
              <file change="deleted" basisPath="folder3PaSd/storyDm.txt" otherPath="">
                <fileSignature size="25336" md5="233228c7e1f473dad1d2c673157dd809" sha1="83c57f595aa6a72f80d47900cc0d10e589f31ea5" sha256=""/>
              </file>
              <file change="deleted" basisPath="folder3PaSd/storyEd.txt" otherPath="">
                <fileSignature size="41765" md5="0e57176032451fd6d0509b6172790b8f" sha1="b191e11dc1768c47852e6d2a235094843be358ff" sha256=""/>
              </file>
            </subset>
            <subset change="added" count="5">
              <file change="added" basisPath="" otherPath="folder1PuSu/story5a.txt">
                <fileSignature size="3614" md5="c7535886a1d0e6d226da322b6ef0bc99" sha1="524deed114c5090af42eae42d0adacb4f212a270" sha256=""/>
              </file>
              <file change="added" basisPath="" otherPath="folder2PdSa/story6u.txt">
                <fileSignature size="2534" md5="1f15cc786bfe832b2fa1e6f047c500ba" sha1="bf3af01de2afa15719d8c42a4141e3b43d06fef6" sha256=""/>
              </file>
              <file change="added" basisPath="" otherPath="folder2PdSa/story7rr.txt">
                <fileSignature size="17074" md5="205271287477c2309512eb664eff9130" sha1="b23aa592ab673030ace6178e29fad3cf6a45bd32" sha256=""/>
              </file>
              <file change="added" basisPath="" otherPath="folder2PdSa/story8m.txt">
                <fileSignature size="5645" md5="f773d6e161000c5b9f90a96cd071688a" sha1="ed5a5a84d51f94bbd04924bc4c982634ee197a62" sha256=""/>
              </file>
              <file change="added" basisPath="" otherPath="folder2PdSa/storyAa.txt">
                <fileSignature size="10717" md5="aeb1721bbf64aebb3ff58cb05d34bd18" sha1="e29f5847ef5645d60e8c0caf99b3fce5e9f645c9" sha256=""/>
              </file>
            </subset>
          </fileGroupDifference>
        </fileInventoryDifference>
      EOF
      xmlObj2 = Nokogiri::XML(xmlTest)
      same = EquivalentXml.equivalent?(xmlObj1, xmlObj2, opts = { :element_order => false, :normalize_whitespace => true })
      expect(same).to be true

      druid = "druid:no000non0000"
      new_cm = IO.read(@fixtures.join('data/dd116zh0343/v0002/metadata/contentMetadata.xml'))
      diff = Stanford::StorageServices.compare_cm_to_version(new_cm, druid, 'shelve', nil)
      xmlObj1 = Nokogiri::XML(diff.to_xml)
      xmlObj1.xpath('//@reportDatetime').remove
      xmlTest = <<-EOF
        <fileInventoryDifference objectId="druid:no000non0000" differenceCount="8" basis="v0" other="new-contentMetadata-shelve" >
          <fileGroupDifference groupId="content" differenceCount="8" identical="0" copyadded="0" copydeleted="0" renamed="0" modified="0" deleted="0" added="8">
            <subset change="identical" count="0"/>
            <subset change="copyadded" count="0"/>
            <subset change="copydeleted" count="0"/>
            <subset change="renamed" count="0"/>
            <subset change="modified" count="0"/>
            <subset change="deleted" count="0"/>
            <subset change="added" count="8">
              <file change="added" basisPath="" otherPath="folder1PuSu/story1u.txt">
                <fileSignature size="7888" md5="e2837b9f02e0b0b76f526eeb81c7aa7b" sha1="61dfac472b7904e1413e0cbf4de432bda2a97627" sha256=""/>
              </file>
              <file change="added" basisPath="" otherPath="folder1PuSu/story2rr.txt">
                <fileSignature size="5983" md5="dc2be64ae43f1c1db4a068603465955d" sha1="b8a672c1848fc3d13b5f380e15835690e24600e0" sha256=""/>
              </file>
              <file change="added" basisPath="" otherPath="folder1PuSu/story3m.txt">
                <fileSignature size="5941" md5="1e5579b16888678f24a1b7008ba15f75" sha1="045245ae45508f92ef82f03eb54290dce92fca64" sha256=""/>
              </file>
              <file change="added" basisPath="" otherPath="folder1PuSu/story5a.txt">
                <fileSignature size="3614" md5="c7535886a1d0e6d226da322b6ef0bc99" sha1="524deed114c5090af42eae42d0adacb4f212a270" sha256=""/>
              </file>
              <file change="added" basisPath="" otherPath="folder2PdSa/story6u.txt">
                <fileSignature size="2534" md5="1f15cc786bfe832b2fa1e6f047c500ba" sha1="bf3af01de2afa15719d8c42a4141e3b43d06fef6" sha256=""/>
              </file>
              <file change="added" basisPath="" otherPath="folder2PdSa/story7rr.txt">
                <fileSignature size="17074" md5="205271287477c2309512eb664eff9130" sha1="b23aa592ab673030ace6178e29fad3cf6a45bd32" sha256=""/>
              </file>
              <file change="added" basisPath="" otherPath="folder2PdSa/story8m.txt">
                <fileSignature size="5645" md5="f773d6e161000c5b9f90a96cd071688a" sha1="ed5a5a84d51f94bbd04924bc4c982634ee197a62" sha256=""/>
              </file>
              <file change="added" basisPath="" otherPath="folder2PdSa/storyAa.txt">
                <fileSignature size="10717" md5="aeb1721bbf64aebb3ff58cb05d34bd18" sha1="e29f5847ef5645d60e8c0caf99b3fce5e9f645c9" sha256=""/>
              </file>
            </subset>
          </fileGroupDifference>
        </fileInventoryDifference>
      EOF
      xmlObj2 = Nokogiri::XML(xmlTest)
      same = EquivalentXml.equivalent?(xmlObj1, xmlObj2, opts = { :element_order => false, :normalize_whitespace => true })
      expect(same).to be true

    end

    # Unit test for method: {Stanford::StorageServices.compare_cm_to_version_inventory}
    # testing boundary case where all subset attributes ar no (e.g. shelve='no')
    specify 'Stanford::StorageServices.compare_cm_to_version_inventory with emtpy subset' do
      inventory_diff = <<-EOF
        <fileInventoryDifference objectId="druid:ms205ty4764" differenceCount="0" basis="v0" other="new-contentMetadata-xyz" >
          <fileGroupDifference groupId="content" differenceCount="0" identical="0" copyadded="0" copydeleted="0" renamed="0" modified="0" deleted="0" added="0">
            <subset change="identical" count="0"/>
            <subset change="renamed" count="0"/>
            <subset change="copyadded" count="0"/>
            <subset change="copydeleted" count="0"/>
            <subset change="modified" count="0"/>
            <subset change="deleted" count="0"/>
            <subset change="added" count="0"/>
          </fileGroupDifference>
        </fileInventoryDifference>
      EOF
      druid = 'druid:ms205ty4764'
      version_id = 1
      subsets = %w(shelve publish preserve)
      subsets.each do |subset|
        diff = Stanford::StorageServices.compare_cm_to_version(@content_metadata_empty_subset, druid, subset, version_id)
        expect(diff).to be_instance_of(Moab::FileInventoryDifference)
        xmlObj1 = Nokogiri::XML(diff.to_xml)
        xmlObj1.xpath('//@reportDatetime').remove
        xmlObj2 = Nokogiri::XML(inventory_diff)
        xmlObj2.xpath('//@other').each {|o| o.value = o.value.gsub(/xyz/, subset) }
        same = EquivalentXml.equivalent?(xmlObj1, xmlObj2, opts = { :element_order => false, :normalize_whitespace => true })
        expect(same).to be true
      end
    end

    # Unit test for method: {Stanford::StorageServices.cm_version_additions}
    # Which returns: [Moab::FileInventory] The versionAddtions report showing which files are new or modified in the content metadata
    # For input parameters:
    # * content_metadata [String] = The content metadata to be evaluated 
    # * object_id [String] = The digital object identifier of the object whose signature catalog is to be used 
    # * version_id [Integer] = The ID of the version whose signature catalog is to be used, if nil use latest version 
    specify 'Stanford::StorageServices.cm_version_additions' do
      content_metadata = 'Test content_metadata' 
      object_id = 'Test object_id' 
      version_id = 78 
      adds = Stanford::StorageServices.cm_version_additions(@content_metadata, @druid, 1)
      expect(adds).to be_instance_of(Moab::FileInventory)
      xmlObj1 = Nokogiri::XML(adds.to_xml)
      xmlObj1.xpath('//@inventoryDatetime').remove
      xmlTest = <<-EOF
        <fileInventory type="additions" objectId="druid:jq937jp0017" versionId=""  fileCount="1" byteCount="32915" blockCount="33">
          <fileGroup groupId="content" dataSource="" fileCount="1" byteCount="32915" blockCount="33">
            <file>
              <fileSignature size="32915" md5="c1c34634e2f18a354cd3e3e1574c3194" sha1="0616a0bd7927328c364b2ea0b4a79c507ce915ed" sha256=""/>
              <fileInstance path="page-1.jpg" datetime="2012-03-26T15:35:15Z"/>
            </file>
          </fileGroup>
        </fileInventory>
      EOF
      xmlObj2 = Nokogiri::XML(xmlTest)
      same = EquivalentXml.equivalent?(xmlObj1, xmlObj2, opts = { :element_order => false, :normalize_whitespace => true })
      expect(same).to be true

      adds = Stanford::StorageServices.cm_version_additions(@content_metadata, "druid:no000non0000", nil)
      expect(adds).to be_instance_of(Moab::FileInventory)
      xmlObj1 = Nokogiri::XML(adds.to_xml)
      xmlObj1.xpath('//@inventoryDatetime').remove
      xmlTest = <<-EOF
        <fileInventory type="additions" objectId="druid:no000non0000" versionId=""  fileCount="4" byteCount="132363" blockCount="131">
          <fileGroup groupId="content" dataSource="" fileCount="4" byteCount="132363" blockCount="131">
            <file>
              <fileSignature size="40873" md5="1a726cd7963bd6d3ceb10a8c353ec166" sha1="583220e0572640abcd3ddd97393d224e8053a6ad" sha256=""/>
              <fileInstance path="title.jpg" datetime="2012-03-26T14:15:11Z"/>
            </file>
            <file>
              <fileSignature size="32915" md5="c1c34634e2f18a354cd3e3e1574c3194" sha1="0616a0bd7927328c364b2ea0b4a79c507ce915ed" sha256=""/>
              <fileInstance path="page-1.jpg" datetime="2012-03-26T15:35:15Z"/>
            </file>
            <file>
              <fileSignature size="39450" md5="82fc107c88446a3119a51a8663d1e955" sha1="d0857baa307a2e9efff42467b5abd4e1cf40fcd5" sha256=""/>
              <fileInstance path="page-2.jpg" datetime="2012-03-26T15:23:36Z"/>
            </file>
            <file>
              <fileSignature size="19125" md5="a5099878de7e2e064432d6df44ca8827" sha1="c0ccac433cf02a6cee89c14f9ba6072a184447a2" sha256=""/>
              <fileInstance path="page-3.jpg" datetime="2012-03-26T15:24:39Z"/>
            </file>
          </fileGroup>
        </fileInventory>
      EOF
      xmlObj2 = Nokogiri::XML(xmlTest)
      same = EquivalentXml.equivalent?(xmlObj1, xmlObj2, opts = { :element_order => false, :normalize_whitespace => true })
      expect(same).to be true
    end

  end

end
