# frozen_string_literal: true

describe Moab::StorageObject do
  let(:ingests_object_dir) { ingests_dir.join(BARE_TEST_DRUID) }
  let(:storage_object_from_ingests) { described_class.new(FULL_TEST_DRUID, ingests_object_dir) }
  let(:temp_dir_ingests) { temp_dir.join('ingests') }
  let(:temp_object_dir) { temp_dir_ingests.join(BARE_TEST_DRUID) }
  let(:storage_object_from_temp) do
    storage_object_from_temp = described_class.new(FULL_TEST_DRUID, temp_object_dir)
    storage_object_from_temp.initialize_storage
    storage_object_from_temp.storage_root = fixtures_dir.join('derivatives')
    storage_object_from_temp
  end

  before do
    temp_object_dir.rmtree if temp_object_dir.exist?
  end

  after do
    temp_object_dir.rmtree if temp_object_dir.exist?
  end

  describe '.version_dirname' do
    it 'turns Integer into Strings starting with v and having at least 4 digits' do
      expect(described_class.version_dirname(1)).to eq 'v0001'
      expect(described_class.version_dirname(22)).to eq 'v0022'
      expect(described_class.version_dirname(333)).to eq 'v0333'
      expect(described_class.version_dirname(4444)).to eq 'v4444'
      expect(described_class.version_dirname(55555)).to eq 'v55555'
    end
  end

  describe '#initialize' do
    it 'sets digital_object_id and object_pathname' do
      storage_obj = described_class.new(FULL_TEST_DRUID, temp_object_dir)
      expect(storage_obj.digital_object_id).to eq FULL_TEST_DRUID
      expect(storage_obj.object_pathname.to_s).to include("temp/ingests/#{BARE_TEST_DRUID}")
    end
  end

  describe '#initialize_storage' do
    let(:storage_obj) { described_class.new(FULL_TEST_DRUID, temp_object_dir) }

    it 'creates the object directory' do
      expect(temp_object_dir.exist?).to be false
      storage_obj.initialize_storage
      expect(temp_object_dir.exist?).to be true
    end

    it 'creates the storage object' do
      expect(storage_obj.exist?).to be false
      storage_obj.initialize_storage
      expect(storage_obj.exist?).to be true
    end
  end

  describe '#deposit_home' do
    it 'returns derivatives/packages' do
      expect(storage_object_from_temp.deposit_home).to eq(packages_dir)
    end
  end

  describe '#deposit_bag_pathname' do
    it 'returns derivatives/packages/[bare_druid]' do
      expect(storage_object_from_temp.deposit_bag_pathname).to eq(packages_dir.join(BARE_TEST_DRUID))
    end
  end

  describe '#ingest_bag' do
    context 'with use_links' do
      context 'with bag_dir by the version folder' do
        before do
          (1..3).each do |version|
            temp_object_dir.mkpath
            unless temp_object_dir.join("v000#{version}").exist?
              bag_dir = packages_dir.join(TEST_OBJECT_VERSIONS[version])
              described_class.new(FULL_TEST_DRUID, temp_object_dir).ingest_bag(bag_dir)
            end
          end
        end

        it 'ingests directory has expected files for each version' do
          files = []
          temp_dir_ingests.find { |f| files << f.relative_path_from(temp_dir).to_s }
          expect(files.sort).to eq [
            'ingests',
            'ingests/jq937jp0017',
            'ingests/jq937jp0017/v0001',
            'ingests/jq937jp0017/v0001/data',
            'ingests/jq937jp0017/v0001/data/content',
            'ingests/jq937jp0017/v0001/data/content/intro-1.jpg',
            'ingests/jq937jp0017/v0001/data/content/intro-2.jpg',
            'ingests/jq937jp0017/v0001/data/content/page-1.jpg',
            'ingests/jq937jp0017/v0001/data/content/page-2.jpg',
            'ingests/jq937jp0017/v0001/data/content/page-3.jpg',
            'ingests/jq937jp0017/v0001/data/content/title.jpg',
            'ingests/jq937jp0017/v0001/data/metadata',
            'ingests/jq937jp0017/v0001/data/metadata/contentMetadata.xml',
            'ingests/jq937jp0017/v0001/data/metadata/descMetadata.xml',
            'ingests/jq937jp0017/v0001/data/metadata/identityMetadata.xml',
            'ingests/jq937jp0017/v0001/data/metadata/provenanceMetadata.xml',
            'ingests/jq937jp0017/v0001/data/metadata/versionMetadata.xml',
            'ingests/jq937jp0017/v0001/manifests',
            'ingests/jq937jp0017/v0001/manifests/fileInventoryDifference.xml',
            'ingests/jq937jp0017/v0001/manifests/manifestInventory.xml',
            'ingests/jq937jp0017/v0001/manifests/signatureCatalog.xml',
            'ingests/jq937jp0017/v0001/manifests/versionAdditions.xml',
            'ingests/jq937jp0017/v0001/manifests/versionInventory.xml',
            'ingests/jq937jp0017/v0002',
            'ingests/jq937jp0017/v0002/data',
            'ingests/jq937jp0017/v0002/data/content',
            'ingests/jq937jp0017/v0002/data/content/page-1.jpg',
            'ingests/jq937jp0017/v0002/data/metadata',
            'ingests/jq937jp0017/v0002/data/metadata/contentMetadata.xml',
            'ingests/jq937jp0017/v0002/data/metadata/provenanceMetadata.xml',
            'ingests/jq937jp0017/v0002/data/metadata/versionMetadata.xml',
            'ingests/jq937jp0017/v0002/manifests',
            'ingests/jq937jp0017/v0002/manifests/fileInventoryDifference.xml',
            'ingests/jq937jp0017/v0002/manifests/manifestInventory.xml',
            'ingests/jq937jp0017/v0002/manifests/signatureCatalog.xml',
            'ingests/jq937jp0017/v0002/manifests/versionAdditions.xml',
            'ingests/jq937jp0017/v0002/manifests/versionInventory.xml',
            'ingests/jq937jp0017/v0003',
            'ingests/jq937jp0017/v0003/data',
            'ingests/jq937jp0017/v0003/data/content',
            'ingests/jq937jp0017/v0003/data/content/page-2.jpg',
            'ingests/jq937jp0017/v0003/data/metadata',
            'ingests/jq937jp0017/v0003/data/metadata/contentMetadata.xml',
            'ingests/jq937jp0017/v0003/data/metadata/provenanceMetadata.xml',
            'ingests/jq937jp0017/v0003/data/metadata/versionMetadata.xml',
            'ingests/jq937jp0017/v0003/manifests',
            'ingests/jq937jp0017/v0003/manifests/fileInventoryDifference.xml',
            'ingests/jq937jp0017/v0003/manifests/manifestInventory.xml',
            'ingests/jq937jp0017/v0003/manifests/signatureCatalog.xml',
            'ingests/jq937jp0017/v0003/manifests/versionAdditions.xml',
            'ingests/jq937jp0017/v0003/manifests/versionInventory.xml'
          ]
        end
      end

      context 'with plain bag for single version' do
        let(:bag_dir) { temp_dir.join('plain_bag') }

        before do
          bag_dir.rmtree if bag_dir.exist?
          FileUtils.cp_r(packages_dir.join(TEST_OBJECT_VERSIONS[1]).to_s, bag_dir.to_s, preserve: true)
          bag_dir.join('versionInventory.xml').delete
          bag_dir.join('versionAdditions.xml').delete
        end

        after do
          bag_dir.rmtree if bag_dir.exist?
        end

        it 'creates versionInventory.xml and versionAdditions.xml in bag directory' do
          expect(bag_dir.join('versionInventory.xml').exist?).to be false
          expect(bag_dir.join('versionAdditions.xml').exist?).to be false

          described_class.new(FULL_TEST_DRUID, temp_object_dir).ingest_bag(bag_dir)

          expect(bag_dir.join('versionInventory.xml').exist?).to be true
          expect(bag_dir.join('versionAdditions.xml').exist?).to be true
        end
      end
    end

    context 'without use_links' do
      context 'with bag_dir by the version folder' do
        before do
          (1..3).each do |version|
            temp_object_dir.mkpath
            unless temp_object_dir.join("v000#{version}").exist?
              bag_dir = packages_dir.join(TEST_OBJECT_VERSIONS[version])
              described_class.new(FULL_TEST_DRUID, temp_object_dir).ingest_bag(bag_dir, use_links: false)
            end
          end
        end

        it 'ingests directory has expected files for each version' do
          files = []
          temp_dir_ingests.find { |f| files << f.relative_path_from(temp_dir).to_s }
          expect(files.sort).to eq [
            'ingests',
            'ingests/jq937jp0017',
            'ingests/jq937jp0017/v0001',
            'ingests/jq937jp0017/v0001/data',
            'ingests/jq937jp0017/v0001/data/content',
            'ingests/jq937jp0017/v0001/data/content/intro-1.jpg',
            'ingests/jq937jp0017/v0001/data/content/intro-2.jpg',
            'ingests/jq937jp0017/v0001/data/content/page-1.jpg',
            'ingests/jq937jp0017/v0001/data/content/page-2.jpg',
            'ingests/jq937jp0017/v0001/data/content/page-3.jpg',
            'ingests/jq937jp0017/v0001/data/content/title.jpg',
            'ingests/jq937jp0017/v0001/data/metadata',
            'ingests/jq937jp0017/v0001/data/metadata/contentMetadata.xml',
            'ingests/jq937jp0017/v0001/data/metadata/descMetadata.xml',
            'ingests/jq937jp0017/v0001/data/metadata/identityMetadata.xml',
            'ingests/jq937jp0017/v0001/data/metadata/provenanceMetadata.xml',
            'ingests/jq937jp0017/v0001/data/metadata/versionMetadata.xml',
            'ingests/jq937jp0017/v0001/manifests',
            'ingests/jq937jp0017/v0001/manifests/fileInventoryDifference.xml',
            'ingests/jq937jp0017/v0001/manifests/manifestInventory.xml',
            'ingests/jq937jp0017/v0001/manifests/signatureCatalog.xml',
            'ingests/jq937jp0017/v0001/manifests/versionAdditions.xml',
            'ingests/jq937jp0017/v0001/manifests/versionInventory.xml',
            'ingests/jq937jp0017/v0002',
            'ingests/jq937jp0017/v0002/data',
            'ingests/jq937jp0017/v0002/data/content',
            'ingests/jq937jp0017/v0002/data/content/page-1.jpg',
            'ingests/jq937jp0017/v0002/data/metadata',
            'ingests/jq937jp0017/v0002/data/metadata/contentMetadata.xml',
            'ingests/jq937jp0017/v0002/data/metadata/provenanceMetadata.xml',
            'ingests/jq937jp0017/v0002/data/metadata/versionMetadata.xml',
            'ingests/jq937jp0017/v0002/manifests',
            'ingests/jq937jp0017/v0002/manifests/fileInventoryDifference.xml',
            'ingests/jq937jp0017/v0002/manifests/manifestInventory.xml',
            'ingests/jq937jp0017/v0002/manifests/signatureCatalog.xml',
            'ingests/jq937jp0017/v0002/manifests/versionAdditions.xml',
            'ingests/jq937jp0017/v0002/manifests/versionInventory.xml',
            'ingests/jq937jp0017/v0003',
            'ingests/jq937jp0017/v0003/data',
            'ingests/jq937jp0017/v0003/data/content',
            'ingests/jq937jp0017/v0003/data/content/page-2.jpg',
            'ingests/jq937jp0017/v0003/data/metadata',
            'ingests/jq937jp0017/v0003/data/metadata/contentMetadata.xml',
            'ingests/jq937jp0017/v0003/data/metadata/provenanceMetadata.xml',
            'ingests/jq937jp0017/v0003/data/metadata/versionMetadata.xml',
            'ingests/jq937jp0017/v0003/manifests',
            'ingests/jq937jp0017/v0003/manifests/fileInventoryDifference.xml',
            'ingests/jq937jp0017/v0003/manifests/manifestInventory.xml',
            'ingests/jq937jp0017/v0003/manifests/signatureCatalog.xml',
            'ingests/jq937jp0017/v0003/manifests/versionAdditions.xml',
            'ingests/jq937jp0017/v0003/manifests/versionInventory.xml'
          ]
        end
      end
    end
  end

  describe '#versionize_bag' do
    let(:bag_dir) { temp_dir.join('plain_bag') }
    let(:current_version) { storage_object_from_temp.storage_object_version(0) }
    let(:new_version) { storage_object_from_temp.storage_object_version(1) }
    let(:versionize_bag_result) { storage_object_from_temp.versionize_bag(bag_dir, current_version, new_version) }
    let(:file_inventory_version_for_comparison_ng_xml) do
      comparison_ng_xml = Nokogiri::XML(versionize_bag_result.to_xml)
      comparison_ng_xml.xpath('//@datetime').each { |d| d.value = '' }
      comparison_ng_xml.xpath('//@dataSource').each do |d|
        d.value = d.value.gsub(/.*moab-versioning/, 'moab-versioning')
        d.value = d.value.gsub('/home/circleci/project', 'moab-versioning')
      end
      comparison_ng_xml.xpath('//@inventoryDatetime').remove
      comparison_ng_xml
    end
    let(:exp_file_inventory_version_xml) do
      <<-XML
        <fileInventory type="version" objectId="druid:jq937jp0017" versionId="1"  fileCount="11" byteCount="217820" blockCount="216">
          <fileGroup groupId="content" dataSource="moab-versioning/spec/temp/plain_bag/data/content" fileCount="6" byteCount="206432" blockCount="203">
            <file>
              <fileSignature size="41981" md5="915c0305bf50c55143f1506295dc122c" sha1="60448956fbe069979fce6a6e55dba4ce1f915178" sha256="4943c6ffdea7e33b74fd7918de900de60e9073148302b0ad1bf5df0e6cec032a"/>
              <fileInstance path="intro-1.jpg" datetime=""/>
            </file>
            <file>
              <fileSignature size="39850" md5="77f1a4efdcea6a476505df9b9fba82a7" sha1="a49ae3f3771d99ceea13ec825c9c2b73fc1a9915" sha256="3a28718a8867e4329cd0363a84aee1c614d0f11229a82e87c6c5072a6e1b15e7"/>
              <fileInstance path="intro-2.jpg" datetime=""/>
            </file>
            <file>
              <fileSignature size="25153" md5="3dee12fb4f1c28351c7482b76ff76ae4" sha1="906c1314f3ab344563acbbbe2c7930f08429e35b" sha256="41aaf8598c9d8e3ee5d55efb9be11c542099d9f994b5935995d0abea231b8bad"/>
              <fileInstance path="page-1.jpg" datetime=""/>
            </file>
            <file>
              <fileSignature size="39450" md5="82fc107c88446a3119a51a8663d1e955" sha1="d0857baa307a2e9efff42467b5abd4e1cf40fcd5" sha256="235de16df4804858aefb7690baf593fb572d64bb6875ec522a4eea1f4189b5f0"/>
              <fileInstance path="page-2.jpg" datetime=""/>
            </file>
            <file>
              <fileSignature size="19125" md5="a5099878de7e2e064432d6df44ca8827" sha1="c0ccac433cf02a6cee89c14f9ba6072a184447a2" sha256="7bd120459eff0ecd21df94271e5c14771bfca5137d1dd74117b6a37123dfe271"/>
              <fileInstance path="page-3.jpg" datetime=""/>
            </file>
            <file>
              <fileSignature size="40873" md5="1a726cd7963bd6d3ceb10a8c353ec166" sha1="583220e0572640abcd3ddd97393d224e8053a6ad" sha256="8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5"/>
              <fileInstance path="title.jpg" datetime=""/>
            </file>
          </fileGroup>
          <fileGroup groupId="metadata" dataSource="moab-versioning/spec/temp/plain_bag/data/metadata" fileCount="5" byteCount="11388" blockCount="13">
            <file>
              <fileSignature size="1871" md5="8cdee9c3470552d258a4351bf4c117e2" sha1="321737e42cc4a3134164539f768514d4f7f6d184" sha256="af38d344d9aee248b01b0af9c85dffbfbd1aeb0f2c6dadf3620797ca73ab24c3"/>
              <fileInstance path="contentMetadata.xml" datetime=""/>
            </file>
            <file>
              <fileSignature size="3055" md5="19c96e98dd25dd68c493faa6a0fde4d0" sha1="541d5845cc866d7676fa43c337b3f7a59f597487" sha256="a575d9058a56d77a4e65e2b1bedb619686a03d5f717374bd0df98d422432e1fe"/>
              <fileInstance path="descMetadata.xml" datetime=""/>
            </file>
            <file>
              <fileSignature size="932" md5="f0815d7b45530491931d5897ccbe2dd1" sha1="4065ff5523e227c1914098372a3dc587f739030e" sha256="f48727374e73776d00517dcdc8af62ec8b18a24cff46c66a5c5f85515144628e"/>
              <fileInstance path="identityMetadata.xml" datetime=""/>
            </file>
            <file>
              <fileSignature size="5306" md5="17193dbf595571d728ba59aa31638db9" sha1="c8b91eacf9ad7532a42dc52b3c9cf03b4ad2c7f6" sha256="d38899a57d4cfca2b1ac73356c8a89cd3c902d35b853ae52f468004887b73dbe"/>
              <fileInstance path="provenanceMetadata.xml" datetime=""/>
            </file>
            <file>
              <fileSignature size="224" md5="36e3c1dadad827cb49e521f5d6559127" sha1="af96327b72bf37e3e60cf51c6de4dba1f6dea620" sha256="65426a7389e13dfa73d37c0ab1417c3e31de74289bf77cc74b3dcc3ffa6f4c8e"/>
              <fileInstance path="versionMetadata.xml" datetime=""/>
            </file>
          </fileGroup>
        </fileInventory>
      XML
    end
    let(:file_inventory_additions_for_comparison_ng_xml) do
      versionize_bag_result # instantiate this
      inventory_w_additions_ng_xml = Nokogiri::XML(bag_dir.join('versionAdditions.xml').read)
      inventory_w_additions_ng_xml.xpath('//@datetime').each { |d| d.value = '' }
      inventory_w_additions_ng_xml.xpath('//@inventoryDatetime').remove
      inventory_w_additions_ng_xml
    end
    let(:exp_file_inventory_additions_xml) do
      <<-XML
        <fileInventory type="additions" objectId="druid:jq937jp0017" versionId="1"  fileCount="11" byteCount="217820" blockCount="216">
          <fileGroup groupId="content" dataSource="" fileCount="6" byteCount="206432" blockCount="203">
            <file>
              <fileSignature size="41981" md5="915c0305bf50c55143f1506295dc122c" sha1="60448956fbe069979fce6a6e55dba4ce1f915178" sha256="4943c6ffdea7e33b74fd7918de900de60e9073148302b0ad1bf5df0e6cec032a"/>
              <fileInstance path="intro-1.jpg" datetime=""/>
            </file>
            <file>
              <fileSignature size="39850" md5="77f1a4efdcea6a476505df9b9fba82a7" sha1="a49ae3f3771d99ceea13ec825c9c2b73fc1a9915" sha256="3a28718a8867e4329cd0363a84aee1c614d0f11229a82e87c6c5072a6e1b15e7"/>
              <fileInstance path="intro-2.jpg" datetime=""/>
            </file>
            <file>
              <fileSignature size="25153" md5="3dee12fb4f1c28351c7482b76ff76ae4" sha1="906c1314f3ab344563acbbbe2c7930f08429e35b" sha256="41aaf8598c9d8e3ee5d55efb9be11c542099d9f994b5935995d0abea231b8bad"/>
              <fileInstance path="page-1.jpg" datetime=""/>
            </file>
            <file>
              <fileSignature size="39450" md5="82fc107c88446a3119a51a8663d1e955" sha1="d0857baa307a2e9efff42467b5abd4e1cf40fcd5" sha256="235de16df4804858aefb7690baf593fb572d64bb6875ec522a4eea1f4189b5f0"/>
              <fileInstance path="page-2.jpg" datetime=""/>
            </file>
            <file>
              <fileSignature size="19125" md5="a5099878de7e2e064432d6df44ca8827" sha1="c0ccac433cf02a6cee89c14f9ba6072a184447a2" sha256="7bd120459eff0ecd21df94271e5c14771bfca5137d1dd74117b6a37123dfe271"/>
              <fileInstance path="page-3.jpg" datetime=""/>
            </file>
            <file>
              <fileSignature size="40873" md5="1a726cd7963bd6d3ceb10a8c353ec166" sha1="583220e0572640abcd3ddd97393d224e8053a6ad" sha256="8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5"/>
              <fileInstance path="title.jpg" datetime=""/>
            </file>
          </fileGroup>
          <fileGroup groupId="metadata" dataSource="" fileCount="5" byteCount="11388" blockCount="13">
            <file>
              <fileSignature size="1871" md5="8cdee9c3470552d258a4351bf4c117e2" sha1="321737e42cc4a3134164539f768514d4f7f6d184" sha256="af38d344d9aee248b01b0af9c85dffbfbd1aeb0f2c6dadf3620797ca73ab24c3"/>
              <fileInstance path="contentMetadata.xml" datetime=""/>
            </file>
            <file>
              <fileSignature size="3055" md5="19c96e98dd25dd68c493faa6a0fde4d0" sha1="541d5845cc866d7676fa43c337b3f7a59f597487" sha256="a575d9058a56d77a4e65e2b1bedb619686a03d5f717374bd0df98d422432e1fe"/>
              <fileInstance path="descMetadata.xml" datetime=""/>
            </file>
            <file>
              <fileSignature size="932" md5="f0815d7b45530491931d5897ccbe2dd1" sha1="4065ff5523e227c1914098372a3dc587f739030e" sha256="f48727374e73776d00517dcdc8af62ec8b18a24cff46c66a5c5f85515144628e"/>
              <fileInstance path="identityMetadata.xml" datetime=""/>
            </file>
            <file>
              <fileSignature size="5306" md5="17193dbf595571d728ba59aa31638db9" sha1="c8b91eacf9ad7532a42dc52b3c9cf03b4ad2c7f6" sha256="d38899a57d4cfca2b1ac73356c8a89cd3c902d35b853ae52f468004887b73dbe"/>
              <fileInstance path="provenanceMetadata.xml" datetime=""/>
            </file>
            <file>
              <fileSignature size="224" md5="36e3c1dadad827cb49e521f5d6559127" sha1="af96327b72bf37e3e60cf51c6de4dba1f6dea620" sha256="65426a7389e13dfa73d37c0ab1417c3e31de74289bf77cc74b3dcc3ffa6f4c8e"/>
              <fileInstance path="versionMetadata.xml" datetime=""/>
            </file>
          </fileGroup>
        </fileInventory>
      XML
    end

    before do
      bag_dir.rmtree if bag_dir.exist?
      FileUtils.cp_r(packages_dir.join(TEST_OBJECT_VERSIONS[1]).to_s, bag_dir.to_s, preserve: true)
      bag_dir.join('versionInventory.xml').rename(bag_dir.join('vi.save'))
      bag_dir.join('versionAdditions.xml').rename(bag_dir.join('va.save'))
    end

    after do
      bag_dir.rmtree if bag_dir.exist?
    end

    it 'returns the expected fileInventory.xml' do
      expect(file_inventory_version_for_comparison_ng_xml).to be_equivalent_to(exp_file_inventory_version_xml)
    end

    it 'creates the expected versionAdditions.xml' do
      expect(file_inventory_additions_for_comparison_ng_xml).to be_equivalent_to(exp_file_inventory_additions_xml)
    end
  end

  describe '#reconstruct_version' do
    context 'when versions exist with no duplicate resources' do
      let(:reconstructs_dir) { temp_dir.join('reconstructs') }

      before do
        reconstructs_dir.rmtree if reconstructs_dir.exist?
        (1..3).each do |version|
          bag_dir = reconstructs_dir.join(TEST_OBJECT_VERSIONS[version])
          described_class.new(FULL_TEST_DRUID, ingests_object_dir).reconstruct_version(version, bag_dir) unless bag_dir.exist?
        end
      end

      after do
        reconstructs_dir.rmtree if reconstructs_dir.exist?
      end

      it 'reconstructs the versions in the bag' do
        files = []
        reconstructs_dir.find { |f| files << f.relative_path_from(temp_dir).to_s }
        expect(files.sort).to eq [
          'reconstructs',
          'reconstructs/v0001',
          'reconstructs/v0001/bag-info.txt',
          'reconstructs/v0001/bagit.txt',
          'reconstructs/v0001/data',
          'reconstructs/v0001/data/content',
          'reconstructs/v0001/data/content/intro-1.jpg',
          'reconstructs/v0001/data/content/intro-2.jpg',
          'reconstructs/v0001/data/content/page-1.jpg',
          'reconstructs/v0001/data/content/page-2.jpg',
          'reconstructs/v0001/data/content/page-3.jpg',
          'reconstructs/v0001/data/content/title.jpg',
          'reconstructs/v0001/data/metadata',
          'reconstructs/v0001/data/metadata/contentMetadata.xml',
          'reconstructs/v0001/data/metadata/descMetadata.xml',
          'reconstructs/v0001/data/metadata/identityMetadata.xml',
          'reconstructs/v0001/data/metadata/provenanceMetadata.xml',
          'reconstructs/v0001/data/metadata/versionMetadata.xml',
          'reconstructs/v0001/manifest-md5.txt',
          'reconstructs/v0001/manifest-sha1.txt',
          'reconstructs/v0001/manifest-sha256.txt',
          'reconstructs/v0001/tagmanifest-md5.txt',
          'reconstructs/v0001/tagmanifest-sha1.txt',
          'reconstructs/v0001/tagmanifest-sha256.txt',
          'reconstructs/v0001/versionInventory.xml',
          'reconstructs/v0002',
          'reconstructs/v0002/bag-info.txt',
          'reconstructs/v0002/bagit.txt',
          'reconstructs/v0002/data',
          'reconstructs/v0002/data/content',
          'reconstructs/v0002/data/content/page-1.jpg',
          'reconstructs/v0002/data/content/page-2.jpg',
          'reconstructs/v0002/data/content/page-3.jpg',
          'reconstructs/v0002/data/content/title.jpg',
          'reconstructs/v0002/data/metadata',
          'reconstructs/v0002/data/metadata/contentMetadata.xml',
          'reconstructs/v0002/data/metadata/descMetadata.xml',
          'reconstructs/v0002/data/metadata/identityMetadata.xml',
          'reconstructs/v0002/data/metadata/provenanceMetadata.xml',
          'reconstructs/v0002/data/metadata/versionMetadata.xml',
          'reconstructs/v0002/manifest-md5.txt',
          'reconstructs/v0002/manifest-sha1.txt',
          'reconstructs/v0002/manifest-sha256.txt',
          'reconstructs/v0002/tagmanifest-md5.txt',
          'reconstructs/v0002/tagmanifest-sha1.txt',
          'reconstructs/v0002/tagmanifest-sha256.txt',
          'reconstructs/v0002/versionInventory.xml',
          'reconstructs/v0003',
          'reconstructs/v0003/bag-info.txt',
          'reconstructs/v0003/bagit.txt',
          'reconstructs/v0003/data',
          'reconstructs/v0003/data/content',
          'reconstructs/v0003/data/content/page-1.jpg',
          'reconstructs/v0003/data/content/page-2.jpg',
          'reconstructs/v0003/data/content/page-3.jpg',
          'reconstructs/v0003/data/content/page-4.jpg',
          'reconstructs/v0003/data/content/title.jpg',
          'reconstructs/v0003/data/metadata',
          'reconstructs/v0003/data/metadata/contentMetadata.xml',
          'reconstructs/v0003/data/metadata/descMetadata.xml',
          'reconstructs/v0003/data/metadata/identityMetadata.xml',
          'reconstructs/v0003/data/metadata/provenanceMetadata.xml',
          'reconstructs/v0003/data/metadata/versionMetadata.xml',
          'reconstructs/v0003/manifest-md5.txt',
          'reconstructs/v0003/manifest-sha1.txt',
          'reconstructs/v0003/manifest-sha256.txt',
          'reconstructs/v0003/tagmanifest-md5.txt',
          'reconstructs/v0003/tagmanifest-sha1.txt',
          'reconstructs/v0003/tagmanifest-sha256.txt',
          'reconstructs/v0003/versionInventory.xml'
        ]
      end
    end

    context 'when there is a duplicate resource' do
      let(:bare_druid) { 'bb077xv1376' }
      let(:object_dir) { File.join(fixtures_directory, "/storage_root03/moab_storage_trunk/bb/077/xv/1376/#{bare_druid}") }
      let(:storage_obj) { described_class.new(bare_druid, object_dir) }
      let(:bag_dir) { File.join(fixtures_directory, "/storage_root03/deposit_trunk/#{bare_druid}") }

      after do
        FileUtils.rmtree(bag_dir) if File.exist?(bag_dir)
      end

      it 'does not raise error' do
        expect { storage_obj.reconstruct_version(1, bag_dir) }.not_to raise_error(Errno::EEXIST)
      end
    end
  end

  describe '#storage_filepath' do
    context 'when file exists' do
      let(:catalog_filepath) { 'v0001/data/content/intro-1.jpg' }

      it 'returns Pathname' do
        filepath = storage_object_from_ingests.storage_filepath(catalog_filepath)
        expect(filepath).to be_instance_of Pathname
        expect(filepath.to_s).to include 'ingests/jq937jp0017/v0001/data/content/intro-1.jpg'
      end
    end

    context 'when file does not exist' do
      it 'raises Moab::FileNotFoundException' do
        expect { storage_object_from_temp.storage_filepath('not_there') }.to raise_exception Moab::FileNotFoundException
      end
    end
  end

  describe '#version_id_list' do
    context 'when there are no versions' do
      it 'returns an empty Array' do
        expect(storage_object_from_temp.version_id_list).to eq []
      end
    end

    context 'when there are versions' do
      it 'returns an Array of integers' do
        expect(storage_object_from_ingests.version_id_list).to eq [1, 2, 3]
      end
    end
  end

  describe '#version_list' do
    context 'when there are no versions' do
      it 'returns an empty Array' do
        expect(storage_object_from_temp.version_list).to eq []
      end
    end

    context 'when there are versions' do
      let(:version_list) { storage_object_from_ingests.version_list }

      it 'returns an Array of Moab::StorageObjectVersion' do
        expect(version_list.size).to eq 3
        expect(version_list.first).to be_instance_of(Moab::StorageObjectVersion)
        expect(version_list[1].version_id).to eq 2
        expect(version_list[1].version_name).to eq 'v0002'
      end
    end
  end

  describe '#current_version_id' do
    context 'when there are no versions' do
      it 'returns 0' do
        expect(storage_object_from_temp.current_version_id).to eq 0
      end
    end

    context 'when there are versions' do
      it 'returns the lastest version_id' do
        expect(storage_object_from_ingests.current_version_id).to eq 3
      end
    end
  end

  describe '#current_version' do
    context 'when there are no versions' do
      let(:current_version) { storage_object_from_temp.current_version }

      it 'returns Moab::StorageObjectVersion of id 0' do
        expect(current_version).to be_instance_of(Moab::StorageObjectVersion)
        expect(current_version.version_id).to eq 0
        expect(current_version.version_name).to eq 'v0000'
      end
    end

    context 'when there are versions' do
      let(:current_version) { storage_object_from_ingests.current_version }

      it 'returns Moab::StorageObjectVersion of latest version' do
        expect(current_version).to be_instance_of(Moab::StorageObjectVersion)
        expect(current_version.version_id).to eq 3
        expect(current_version.version_name).to eq 'v0003'
      end
    end
  end

  describe '#validate_new_inventory' do
    context 'when requested version is the next consecutive version' do
      let(:version_inventory_4) { instance_double("#{Moab::FileInventory.name}4") }

      before do
        allow(version_inventory_4).to receive(:version_id).and_return 4
      end

      it 'returns true' do
        expect(storage_object_from_ingests.validate_new_inventory(version_inventory_4)).to be true
      end
    end

    context 'when requested version already exists' do
      let(:version_inventory_3) { instance_double("#{Moab::FileInventory.name}3") }

      before do
        allow(version_inventory_3).to receive(:version_id).twice.and_return 3
      end

      it 'raises exception' do
        expect do
          storage_object_from_ingests.validate_new_inventory(version_inventory_3)
        end.to raise_exception(Moab::MoabRuntimeError, /version mismatch - current: 3 new: 3/)
      end
    end
  end

  describe '#find_object_version' do
    it 'existing version' do
      version_2 = storage_object_from_ingests.find_object_version(2)
      expect(version_2).to be_instance_of(Moab::StorageObjectVersion)
      expect(version_2.version_id).to eq 2
      expect(version_2.version_name).to eq 'v0002'
      expect(version_2.version_pathname.to_s).to match(/ingests\/jq937jp0017\/v0002/)
    end

    it 'latest version' do
      version_latest = storage_object_from_ingests.find_object_version
      expect(version_latest).to be_instance_of(Moab::StorageObjectVersion)
      expect(version_latest.version_id).to eq 3
      expect(version_latest.version_name).to eq 'v0003'
      expect(version_latest.version_pathname.to_s).to match(/ingests\/jq937jp0017\/v0003/)
    end

    it 'non-existent versions' do
      expect do
        storage_object_from_ingests.find_object_version(0)
      end.to raise_exception(Moab::MoabRuntimeError, /Version ID 0 does not exist/)
      expect do
        storage_object_from_ingests.find_object_version(4)
      end.to raise_exception(Moab::MoabRuntimeError, /Version ID 4 does not exist/)
    end
  end

  describe '#storage_object_version' do
    context 'when version exists' do
      it 'returns version' do
        version_2 = storage_object_from_ingests.storage_object_version(2)
        expect(version_2).to be_instance_of(Moab::StorageObjectVersion)
        expect(version_2.version_id).to eq 2
        expect(version_2.version_name).to eq 'v0002'
        expect(version_2.version_pathname.to_s).to match(/ingests\/jq937jp0017\/v0002/)
      end
    end

    context 'when version does not exist' do
      it 'does not raise exception' do
        expect { storage_object_from_ingests.storage_object_version(0) }.not_to raise_exception
        expect { storage_object_from_ingests.storage_object_version(4) }.not_to raise_exception
      end
    end

    context 'when version request param is nil' do
      it 'raises exception' do
        expect do
          storage_object_from_ingests.storage_object_version(nil)
        end.to raise_exception(Moab::MoabRuntimeError, /Version ID not specified/)
      end
    end
  end

  describe '#verify_object_storage' do
    context 'when valid' do
      let(:verification_result) { storage_object_from_ingests.verify_object_storage }

      it 'returns VerificationResult with verified property to true' do
        expect(verification_result).to be_instance_of(Moab::VerificationResult)
        expect(verification_result.subentities).not_to be_nil
        expect(verification_result.verified).to be true
      end
    end
  end

  describe '#restore_object' do
    context 'when object is empty and param directory has Moab content' do
      it 'adds the content to the object' do
        expect(storage_object_from_temp.version_list.size).to eq 0
        storage_object_from_temp.restore_object(ingests_object_dir)
        expect(storage_object_from_temp.version_list.size).to eq 3
      end
    end
  end

  describe '#size' do
    context 'when there is content' do
      it 'returns number of bytes' do
        # values may differ from file system to file system (which is to be expected).
        # if this test fails on your mac, make sure you don't have any extraneous .DS_Store files
        # lingering in the fixture directories.
        expect(storage_object_from_ingests.size).to be_between(345_000, 346_000)
      end
    end

    context 'when there is no content' do
      it 'returns 0' do
        expect(storage_object_from_temp.size).to eq 0
      end
    end
  end
end
