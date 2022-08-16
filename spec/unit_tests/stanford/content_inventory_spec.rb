# frozen_string_literal: true

describe Stanford::ContentInventory do
  let(:content_metadata) { File.read(test_object_data_dir.join('v0002/metadata/contentMetadata.xml')) }
  let(:node) { Nokogiri::XML(content_metadata).xpath('//file').first }
  let(:content_inventory) { described_class.new }

  describe '#inventory_from_cm' do
    context 'when subset = preserve and version = 1' do
      let(:inventory_ng_xml) do
        cm_with_subsets = File.read(fixtures_dir.join('data/dd116zh0343/v0001/metadata/contentMetadata.xml'))
        inventory = described_class.new.inventory_from_cm(cm_with_subsets, 'druid:dd116zh0343', 'preserve', 1)
        inventory_ng_xml = Nokogiri::XML(inventory.to_xml)
        inventory_ng_xml.xpath('//@inventoryDatetime').remove
        inventory_ng_xml
      end
      let(:exp_xml) do
        <<-XML
          <fileInventory type="version" objectId="druid:dd116zh0343" versionId="1"  fileCount="8" byteCount="70979" blockCount="73">
            <fileGroup groupId="content" dataSource="contentMetadata-preserve" fileCount="8" byteCount="70979" blockCount="73">
              <file>
                <fileSignature size="7888" md5="e2837b9f02e0b0b76f526eeb81c7aa7b" sha1="61dfac472b7904e1413e0cbf4de432bda2a97627" sha256=""/>
                <fileInstance path="folder1PuSu/story1u.txt" datetime="2012-06-15T22:57:43Z"/>
              </file>
              <file>
                <fileSignature size="5983" md5="dc2be64ae43f1c1db4a068603465955d" sha1="b8a672c1848fc3d13b5f380e15835690e24600e0" sha256=""/>
                <fileInstance path="folder1PuSu/story2r.txt" datetime="2012-06-15T22:58:56Z"/>
              </file>
              <file>
                <fileSignature size="5951" md5="3d67f52e032e36b641d0cad40816f048" sha1="548f349c79928b6d0996b7ff45990bdce5ee9753" sha256=""/>
                <fileInstance path="folder1PuSu/story3m.txt" datetime="2012-06-15T23:00:43Z"/>
              </file>
              <file>
                <fileSignature size="6307" md5="34f3f646523b0a8504f216483a57bce4" sha1="d498b513add5bb138ed4f6205453a063a2434dc4" sha256=""/>
                <fileInstance path="folder1PuSu/story4d.txt" datetime="2012-06-15T23:02:22Z"/>
              </file>
              <file>
                <fileSignature size="2534" md5="1f15cc786bfe832b2fa1e6f047c500ba" sha1="bf3af01de2afa15719d8c42a4141e3b43d06fef6" sha256=""/>
                <fileInstance path="folder2PdSa/story6u.txt" datetime="2012-06-15T23:05:03Z"/>
              </file>
              <file>
                <fileSignature size="17074" md5="205271287477c2309512eb664eff9130" sha1="b23aa592ab673030ace6178e29fad3cf6a45bd32" sha256=""/>
                <fileInstance path="folder2PdSa/story7r.txt" datetime="2012-06-15T23:08:35Z"/>
              </file>
              <file>
                <fileSignature size="5643" md5="ce474f4c512953f20a8c4c5b92405cf7" sha1="af9cbf5ab4f020a8bb17b180fbd5c41598d89b37" sha256=""/>
                <fileInstance path="folder2PdSa/story8m.txt" datetime="2012-06-15T23:09:26Z"/>
              </file>
              <file>
                <fileSignature size="19599" md5="135cb2db6a35afac590687f452053baf" sha1="e74274d7bc06ef44a408a008f5160b3756cb2ab0" sha256=""/>
                <fileInstance path="folder2PdSa/story9d.txt" datetime="2012-06-15T23:14:32Z"/>
              </file>
            </fileGroup>
          </fileInventory>
        XML
      end

      it 'gets expected result' do
        expect(inventory_ng_xml).to be_equivalent_to(Nokogiri::XML(exp_xml))
      end
    end

    context 'when subset = all and version is not 1' do
      let(:inventory_ng_xml) do
        inventory = content_inventory.inventory_from_cm(content_metadata, FULL_TEST_DRUID, 'all', 2)
        inventory_ng_xml = Nokogiri::XML(inventory.to_xml)
        inventory_ng_xml.xpath('//@inventoryDatetime').remove
        inventory_ng_xml
      end
      let(:exp_xml) do
        <<-XML
          <fileInventory type="version" objectId="#{FULL_TEST_DRUID}" versionId="2"  fileCount="4" byteCount="132363" blockCount="131">
            <fileGroup groupId="content" dataSource="contentMetadata-all" fileCount="4" byteCount="132363" blockCount="131">
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
        XML
      end

      it 'gets expected result' do
        expect(inventory_ng_xml).to be_equivalent_to(Nokogiri::XML(exp_xml))
      end
    end

    context 'when all subset attributes (preserve, shelve, publish) are no' do
      let(:content_metadata_empty_subset) { File.read(fixtures_dir.join('bad_data/contentMetadata-empty-subsets.xml')) }
      let(:empty_inventory) do
        <<-XML
          <fileInventory type="version" objectId="druid:ms205ty4764" versionId="1"  fileCount="0" byteCount="0" blockCount="0">
            <fileGroup groupId="content" dataSource="contentMetadata-subset" fileCount="0" byteCount="0" blockCount="0"/>
          </fileInventory>
        XML
      end
      let(:exp_ng_xml) { Nokogiri::XML(empty_inventory) }

      %w[shelve publish preserve].each do |subset|
        it 'gets expected result' do
          inventory = content_inventory.inventory_from_cm(content_metadata_empty_subset, 'druid:ms205ty4764', subset, 1)
          inventory_ng_xml = Nokogiri::XML(inventory.to_xml)
          inventory_ng_xml.xpath('//@inventoryDatetime').remove
          exp_ng_xml.xpath('//@dataSource').each { |d| d.value = d.value.gsub(/subset/, subset) }
          expect(inventory_ng_xml).to be_equivalent_to(exp_ng_xml)
        end
      end
    end
  end

  describe '#group_from_cm' do
    let(:cm_with_subsets) { File.read(fixtures_dir.join('data/dd116zh0343/v0001/metadata/contentMetadata.xml')) }

    it 'returns expected Moab::FileGroup object' do
      group = content_inventory.group_from_cm(content_metadata, 'all')
      expect(group).to be_instance_of(Moab::FileGroup)
      expect(group.data_source).to eq('contentMetadata-all')
    end

    context 'when subset all' do
      it 'returns expected files in the group' do
        group = described_class.new.group_from_cm(cm_with_subsets, 'all')
        expect(group.files.size).to eq(12)
      end
    end

    context 'when subset shelve' do
      it 'returns expected files in the group' do
        group = described_class.new.group_from_cm(cm_with_subsets, 'shelve')
        expect(group.files.size).to eq(8)
      end
    end

    context 'when subset publish' do
      it 'returns expected files in the group' do
        group = described_class.new.group_from_cm(cm_with_subsets, 'publish')
        expect(group.files.size).to eq(12)
      end
    end

    context 'when subset preserve' do
      it 'returns expected files in the group' do
        group = described_class.new.group_from_cm(cm_with_subsets, 'preserve')
        expect(group.files.size).to eq(8)
      end
    end

    it 'raises exception for unknown subset' do
      expect do
        described_class.new.group_from_cm(cm_with_subsets, 'dummy')
      end.to raise_exception(Moab::MoabRuntimeError, /Unknown disposition subset/)
    end
  end

  describe '#generate_signature' do
    it 'returns expected fixity' do
      exp_fixity = {
        size: '40873',
        md5: '1a726cd7963bd6d3ceb10a8c353ec166',
        sha1: '583220e0572640abcd3ddd97393d224e8053a6ad'
      }
      expect(content_inventory.generate_signature(node).fixity).to eq(exp_fixity)
    end

    context 'when sha256 checksum is added' do
      let(:node2) { node.clone }
      let(:sha256_checksum) { '291208b41c557a5fb15cc836ab7235dadbd0881096385cc830bb446b00d2eb6b' }
      let(:exp_fixity) do
        {
          size: '40873',
          md5: '1a726cd7963bd6d3ceb10a8c353ec166',
          sha1: '583220e0572640abcd3ddd97393d224e8053a6ad',
          sha256: sha256_checksum
        }
      end

      it 'returns expected fixity' do
        Nokogiri::XML::Builder.with(node2) do |xml|
          xml.checksum sha256_checksum, type: 'SHA-256'
        end
        expect(content_inventory.generate_signature(node2).fixity).to eq(exp_fixity)
      end
    end
  end

  describe '#generate_instance' do
    it 'generates the expected hash values' do
      expect(content_inventory.generate_instance(node).to_hash).to eql('path' => 'title.jpg',
                                                                       'datetime' => '2012-03-26T14:15:11Z')
    end
  end

  describe '#generate_content_metadata' do
    let(:generated_content_metadata) do
      directory = test_object_data_dir.join('v0002/content')
      group = Moab::FileGroup.new.group_from_directory(directory, true)
      content_inventory.generate_content_metadata(group, BARE_TEST_DRUID, 2)
    end
    let(:exp_xml) do
      <<-XML
        <contentMetadata type="sample" objectId="jq937jp0017">
          <resource type="version" sequence="1" id="version-2">
            <file preserve="yes" publish="yes"  size="32915" id="page-1.jpg" shelve="yes">
              <checksum type="MD5">c1c34634e2f18a354cd3e3e1574c3194</checksum>
              <checksum type="SHA-1">0616a0bd7927328c364b2ea0b4a79c507ce915ed</checksum>
              <checksum type="SHA-256">b78cc53b7b8d9ed86d5e3bab3b699c7ed0db958d4a111e56b6936c8397137de0</checksum>
            </file>
            <file preserve="yes" publish="yes"  size="39450" id="page-2.jpg" shelve="yes">
              <checksum type="MD5">82fc107c88446a3119a51a8663d1e955</checksum>
              <checksum type="SHA-1">d0857baa307a2e9efff42467b5abd4e1cf40fcd5</checksum>
              <checksum type="SHA-256">235de16df4804858aefb7690baf593fb572d64bb6875ec522a4eea1f4189b5f0</checksum>
            </file>
            <file preserve="yes" publish="yes"  size="19125" id="page-3.jpg" shelve="yes">
              <checksum type="MD5">a5099878de7e2e064432d6df44ca8827</checksum>
              <checksum type="SHA-1">c0ccac433cf02a6cee89c14f9ba6072a184447a2</checksum>
              <checksum type="SHA-256">7bd120459eff0ecd21df94271e5c14771bfca5137d1dd74117b6a37123dfe271</checksum>
            </file>
            <file preserve="yes" publish="yes"  size="40873" id="title.jpg" shelve="yes">
              <checksum type="MD5">1a726cd7963bd6d3ceb10a8c353ec166</checksum>
              <checksum type="SHA-1">583220e0572640abcd3ddd97393d224e8053a6ad</checksum>
              <checksum type="SHA-256">8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5</checksum>
            </file>
          </resource>
        </contentMetadata>
      XML
    end

    it 'returns the expected contentMetadata.xml' do
      generated_ng_xml = Nokogiri::XML(generated_content_metadata)
      generated_ng_xml.xpath('//@datetime').remove
      expect(generated_ng_xml).to be_equivalent_to(Nokogiri::XML(exp_xml))
    end
  end

  describe '#validate_content_metadata' do
    context 'when valid' do
      let(:content_md) { fixtures_dir.join('data', BARE_TEST_DRUID, 'v0001', 'metadata', 'contentMetadata.xml').read }

      it 'returns true' do
        expect(content_inventory.validate_content_metadata(content_md)).to be(true)
      end
    end

    context 'when bad data' do
      let(:content_md) { fixtures_dir.join('bad_data', 'contentMetadata.xml') }

      it 'raises Moab::InvalidMetadataException' do
        expect { content_inventory.validate_content_metadata(content_md) }.to raise_exception(Moab::InvalidMetadataException)
      end
    end
  end

  describe '#validate_content_metadata_details' do
    context 'when errors' do
      let(:result) do
        content_md = fixtures_dir.join('bad_data', 'contentMetadata.xml').read
        content_metadata_doc = Nokogiri::XML(content_md)
        content_inventory.validate_content_metadata_details(content_metadata_doc)
      end

      it 'returns array of those errros' do
        expect(result).to eq(
          [
            'File node 0 is missing id',
            "File node having id='page-1.jpg' is missing size",
            "File node having id='page-2.jpg' is missing md5",
            "File node having id='page-3.jpg' is missing sha1"
          ]
        )
      end
    end

    context 'when content_metadata is empty hash' do
      it 'raises Moab::InvalidMetadataException' do
        expect do
          content_inventory.validate_content_metadata_details({})
        end.to raise_exception(Moab::InvalidMetadataException, /Content Metadata is in unrecognized format/)
      end
    end
  end

  describe '#remediate_content_metadata' do
    let(:content_md) { fixtures_dir.join('bad_data', 'contentMetadata-missing-fixity.xml').read }
    let(:group) do
      directory = test_object_data_dir.join('v0001/content')
      Moab::FileGroup.new.group_from_directory(directory, true)
    end

    context 'when missing fixity' do
      let(:remediated) do
        content_inventory.remediate_content_metadata(content_md, group)
      end
      let(:exp_xml) do
        <<-XML
          <contentMetadata type="sample" objectId="druid:jq937jp0017">
            <resource type="version" sequence="1" id="version-1">
              <file datetime="2012-03-26T08:15:11-06:00" size="40873" id="title.jpg" shelve="yes" publish="yes" preserve="yes">
                <checksum type="MD5">1a726cd7963bd6d3ceb10a8c353ec166</checksum>
                <checksum type="SHA-1">583220e0572640abcd3ddd97393d224e8053a6ad</checksum>
                <checksum type="SHA-256">8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5</checksum>
              </file>
              <file datetime="2012-03-26T08:20:35-06:00" id="intro-1.jpg" shelve="yes" publish="yes" preserve="yes" size="41981">
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
                <checksum type="MD5">3dee12fb4f1c28351c7482b76ff76ae4</checksum><checksum type="SHA-1">906c1314f3ab344563acbbbe2c7930f08429e35b</checksum>
                <checksum type="SHA-256">41aaf8598c9d8e3ee5d55efb9be11c542099d9f994b5935995d0abea231b8bad</checksum>
              </file>
              <file datetime="2012-03-26T09:23:36-06:00" id="page-2.jpg" shelve="yes" publish="yes" preserve="yes" size="39450">
                <checksum type="MD5">82fc107c88446a3119a51a8663d1e955</checksum><checksum type="SHA-1">d0857baa307a2e9efff42467b5abd4e1cf40fcd5</checksum>
                <checksum type="SHA-256">235de16df4804858aefb7690baf593fb572d64bb6875ec522a4eea1f4189b5f0</checksum>
              </file>
              <file datetime="2012-03-26T09:24:39-06:00" size="19125" id="page-3.jpg" shelve="yes" publish="yes" preserve="yes">
                <checksum type="MD5">a5099878de7e2e064432d6df44ca8827</checksum>
                <checksum type="SHA-1">c0ccac433cf02a6cee89c14f9ba6072a184447a2</checksum>
                <checksum type="SHA-256">7bd120459eff0ecd21df94271e5c14771bfca5137d1dd74117b6a37123dfe271</checksum>
              </file>
            </resource>
          </contentMetadata>
        XML
      end

      it 'adds missing checksums' do
        expect(Nokogiri::XML(remediated)).to be_equivalent_to(Nokogiri::XML(exp_xml))
      end
    end

    context 'when size is incorrect' do
      let(:content_md_bad_size) { content_md.sub(/40873/, '37804') }

      it 'raises Moab::MoabRuntimeError' do
        expect do
          content_inventory.remediate_content_metadata(content_md_bad_size, group)
        end.to raise_exception(Moab::MoabRuntimeError, /Inconsistent size for title.jpg: 37804 != 40873/)
      end
    end

    context 'when checksum is incorrect' do
      let(:cm_bad_checksum) { content_md.sub(/1a726cd7963bd6d3ceb10a8c353ec166/, '915c0305bf50c55143f1506295dc122c') }

      it 'bad checksum raises exception' do
        exp_regex = /Inconsistent md5 for title.jpg: 915c0305bf50c55143f1506295dc122c != 1a726cd7963bd6d3ceb10a8c353ec166/
        expect do
          content_inventory.remediate_content_metadata(cm_bad_checksum, group)
        end.to raise_exception(Moab::MoabRuntimeError, exp_regex)
      end
    end
  end
end
