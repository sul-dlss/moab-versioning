# frozen_string_literal: true

describe Moab::StorageObject do
  let(:eq_xml_opts) { { :element_order => false, :normalize_whitespace => true } }
  let(:storage_object) { described_class.new(@druid, @ingest_object_dir) }

  before do
    @storage_object = described_class.new(@druid, @temp_object_dir)
    @storage_object.initialize_storage
    @storage_object.storage_root = @fixtures.join('derivatives')
  end

  after(:all) do
    unless @temp_ingests.nil?
      @temp_ingests.rmtree if @temp_ingests.exist?
    end
  end

  before(:all) do
    @temp_ingests = @temp.join("ingests")
    @temp_object_dir = @temp_ingests.join(@obj)
    @ingest_object_dir = @ingests.join(@obj)
  end

  specify '.version_dirname' do
    expect(described_class.version_dirname(1)).to eq "v0001"
    expect(described_class.version_dirname(22)).to eq "v0022"
    expect(described_class.version_dirname(333)).to eq "v0333"
    expect(described_class.version_dirname(4444)).to eq "v4444"
    expect(described_class.version_dirname(55555)).to eq "v55555"
  end

  specify '#initialize' do
    storage_object = described_class.new(@druid, @temp_object_dir)
    expect(storage_object.digital_object_id).to eq @druid
    expect(storage_object.object_pathname.to_s).to include('temp/ingests/jq937jp0017')
  end

  specify '#initialize_storage' do
    @temp_object_dir.rmtree if @temp_object_dir.exist?
    expect(@temp_object_dir.exist?).to eq false
    expect(@storage_object.exist?).to eq false
    @storage_object.initialize_storage
    expect(@temp_object_dir.exist?).to eq true
    expect(@storage_object.exist?).to eq true
  end

  specify '#deposit_home' do
    expect(@storage_object.deposit_home).to eq(@packages)
  end

  specify '#deposit_bag_pathname' do
    expect(@storage_object.deposit_bag_pathname).to eq(@packages.join('jq937jp0017'))
  end

  describe '#ingest_bag' do
    it 'by the version folder' do
      ingests_dir = @temp.join('ingests')
      (1..3).each do |version|
        object_dir = ingests_dir.join(@obj)
        object_dir.mkpath
        unless object_dir.join("v000#{version}").exist?
          bag_dir = @packages.join(@vname[version])
          described_class.new(@druid, object_dir).ingest_bag(bag_dir)
        end
      end

      files = []
      ingests_dir.find { |f| files << f.relative_path_from(@temp).to_s }
      expect(files.sort).to eq [
        "ingests",
        "ingests/jq937jp0017",
        "ingests/jq937jp0017/v0001",
        "ingests/jq937jp0017/v0001/data",
        "ingests/jq937jp0017/v0001/data/content",
        "ingests/jq937jp0017/v0001/data/content/intro-1.jpg",
        "ingests/jq937jp0017/v0001/data/content/intro-2.jpg",
        "ingests/jq937jp0017/v0001/data/content/page-1.jpg",
        "ingests/jq937jp0017/v0001/data/content/page-2.jpg",
        "ingests/jq937jp0017/v0001/data/content/page-3.jpg",
        "ingests/jq937jp0017/v0001/data/content/title.jpg",
        "ingests/jq937jp0017/v0001/data/metadata",
        "ingests/jq937jp0017/v0001/data/metadata/contentMetadata.xml",
        "ingests/jq937jp0017/v0001/data/metadata/descMetadata.xml",
        "ingests/jq937jp0017/v0001/data/metadata/identityMetadata.xml",
        "ingests/jq937jp0017/v0001/data/metadata/provenanceMetadata.xml",
        "ingests/jq937jp0017/v0001/data/metadata/versionMetadata.xml",
        "ingests/jq937jp0017/v0001/manifests",
        "ingests/jq937jp0017/v0001/manifests/fileInventoryDifference.xml",
        "ingests/jq937jp0017/v0001/manifests/manifestInventory.xml",
        "ingests/jq937jp0017/v0001/manifests/signatureCatalog.xml",
        "ingests/jq937jp0017/v0001/manifests/versionAdditions.xml",
        "ingests/jq937jp0017/v0001/manifests/versionInventory.xml",
        "ingests/jq937jp0017/v0002",
        "ingests/jq937jp0017/v0002/data",
        "ingests/jq937jp0017/v0002/data/content",
        "ingests/jq937jp0017/v0002/data/content/page-1.jpg",
        "ingests/jq937jp0017/v0002/data/metadata",
        "ingests/jq937jp0017/v0002/data/metadata/contentMetadata.xml",
        "ingests/jq937jp0017/v0002/data/metadata/provenanceMetadata.xml",
        "ingests/jq937jp0017/v0002/data/metadata/versionMetadata.xml",
        "ingests/jq937jp0017/v0002/manifests",
        "ingests/jq937jp0017/v0002/manifests/fileInventoryDifference.xml",
        "ingests/jq937jp0017/v0002/manifests/manifestInventory.xml",
        "ingests/jq937jp0017/v0002/manifests/signatureCatalog.xml",
        "ingests/jq937jp0017/v0002/manifests/versionAdditions.xml",
        "ingests/jq937jp0017/v0002/manifests/versionInventory.xml",
        "ingests/jq937jp0017/v0003",
        "ingests/jq937jp0017/v0003/data",
        "ingests/jq937jp0017/v0003/data/content",
        "ingests/jq937jp0017/v0003/data/content/page-2.jpg",
        "ingests/jq937jp0017/v0003/data/metadata",
        "ingests/jq937jp0017/v0003/data/metadata/contentMetadata.xml",
        "ingests/jq937jp0017/v0003/data/metadata/provenanceMetadata.xml",
        "ingests/jq937jp0017/v0003/data/metadata/versionMetadata.xml",
        "ingests/jq937jp0017/v0003/manifests",
        "ingests/jq937jp0017/v0003/manifests/fileInventoryDifference.xml",
        "ingests/jq937jp0017/v0003/manifests/manifestInventory.xml",
        "ingests/jq937jp0017/v0003/manifests/signatureCatalog.xml",
        "ingests/jq937jp0017/v0003/manifests/versionAdditions.xml",
        "ingests/jq937jp0017/v0003/manifests/versionInventory.xml"
      ]
      ingests_dir.rmtree if ingests_dir.exist? # cleanup
    end

    it 'creates versionInventory and versionAdditions' do
      ingests_dir = @temp.join('ingests')
      object_dir = ingests_dir.join(@obj)
      object_dir.mkpath
      bag_dir = @temp.join('plain_bag')
      bag_dir.rmtree if bag_dir.exist?
      FileUtils.cp_r(@packages.join(@vname[1]).to_s, bag_dir.to_s, preserve: true)

      bag_dir.join('versionInventory.xml').delete
      bag_dir.join('versionAdditions.xml').delete
      expect(bag_dir.join('versionInventory.xml').exist?).to eq false
      expect(bag_dir.join('versionAdditions.xml').exist?).to eq false
      described_class.new(@druid, object_dir).ingest_bag(bag_dir)
      expect(bag_dir.join('versionInventory.xml').exist?).to eq true
      expect(bag_dir.join('versionAdditions.xml').exist?).to eq true
      ingests_dir.rmtree if ingests_dir.exist? # cleanup
    end
  end

  specify '#versionize_bag' do
    bag_dir = @temp.join('plain_bag')
    bag_dir.rmtree if bag_dir.exist?
    FileUtils.cp_r(@packages.join(@vname[1]).to_s, bag_dir.to_s, preserve: true)
    bag_dir.join('versionInventory.xml').rename(bag_dir.join('vi.save'))
    bag_dir.join('versionAdditions.xml').rename(bag_dir.join('va.save'))
    current_version = @storage_object.storage_object_version(0)
    new_version = @storage_object.storage_object_version(1)
    new_inventory = @storage_object.versionize_bag(bag_dir, current_version, new_version)

    new_inventory_ng_xml = Nokogiri::XML(new_inventory.to_xml)
    new_inventory_ng_xml.xpath('//@datetime').each { |d| d.value = '' }
    new_inventory_ng_xml.xpath('//@dataSource').each { |d| d.value = d.value.gsub(/.*moab-versioning/, 'moab-versioning') }
    new_inventory_ng_xml.xpath('//@inventoryDatetime').remove
    exp_xml = <<-XML
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
    expect(EquivalentXml.equivalent?(new_inventory_ng_xml, Nokogiri::XML(exp_xml), eq_xml_opts)).to be true

    inventory_w_additions_ng_xml = Nokogiri::XML(bag_dir.join('versionAdditions.xml').read)
    inventory_w_additions_ng_xml.xpath('//@datetime').each { |d| d.value = '' }
    inventory_w_additions_ng_xml.xpath('//@inventoryDatetime').remove
    exp_xml = <<-XML
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
    expect(EquivalentXml.equivalent?(inventory_w_additions_ng_xml, Nokogiri::XML(exp_xml), eq_xml_opts)).to be true
    bag_dir.rmtree if bag_dir.exist?
  end

  describe '#reconstruct_version' do
    it 'bags a particular version' do
      reconstructs_dir = @temp.join('reconstructs')
      reconstructs_dir.rmtree if reconstructs_dir.exist?
      (1..3).each do |version|
        bag_dir = reconstructs_dir.join(@vname[version])
        described_class.new(@druid, @ingest_object_dir).reconstruct_version(version, bag_dir) unless bag_dir.exist?
      end

      files = []
      reconstructs_dir.find { |f| files << f.relative_path_from(@temp).to_s }
      expect(files.sort).to eq [
        "reconstructs",
        "reconstructs/v0001",
        "reconstructs/v0001/bag-info.txt",
        "reconstructs/v0001/bagit.txt",
        "reconstructs/v0001/data",
        "reconstructs/v0001/data/content",
        "reconstructs/v0001/data/content/intro-1.jpg",
        "reconstructs/v0001/data/content/intro-2.jpg",
        "reconstructs/v0001/data/content/page-1.jpg",
        "reconstructs/v0001/data/content/page-2.jpg",
        "reconstructs/v0001/data/content/page-3.jpg",
        "reconstructs/v0001/data/content/title.jpg",
        "reconstructs/v0001/data/metadata",
        "reconstructs/v0001/data/metadata/contentMetadata.xml",
        "reconstructs/v0001/data/metadata/descMetadata.xml",
        "reconstructs/v0001/data/metadata/identityMetadata.xml",
        "reconstructs/v0001/data/metadata/provenanceMetadata.xml",
        "reconstructs/v0001/data/metadata/versionMetadata.xml",
        "reconstructs/v0001/manifest-md5.txt",
        "reconstructs/v0001/manifest-sha1.txt",
        "reconstructs/v0001/manifest-sha256.txt",
        "reconstructs/v0001/tagmanifest-md5.txt",
        "reconstructs/v0001/tagmanifest-sha1.txt",
        "reconstructs/v0001/tagmanifest-sha256.txt",
        "reconstructs/v0001/versionInventory.xml",
        "reconstructs/v0002",
        "reconstructs/v0002/bag-info.txt",
        "reconstructs/v0002/bagit.txt",
        "reconstructs/v0002/data",
        "reconstructs/v0002/data/content",
        "reconstructs/v0002/data/content/page-1.jpg",
        "reconstructs/v0002/data/content/page-2.jpg",
        "reconstructs/v0002/data/content/page-3.jpg",
        "reconstructs/v0002/data/content/title.jpg",
        "reconstructs/v0002/data/metadata",
        "reconstructs/v0002/data/metadata/contentMetadata.xml",
        "reconstructs/v0002/data/metadata/descMetadata.xml",
        "reconstructs/v0002/data/metadata/identityMetadata.xml",
        "reconstructs/v0002/data/metadata/provenanceMetadata.xml",
        "reconstructs/v0002/data/metadata/versionMetadata.xml",
        "reconstructs/v0002/manifest-md5.txt",
        "reconstructs/v0002/manifest-sha1.txt",
        "reconstructs/v0002/manifest-sha256.txt",
        "reconstructs/v0002/tagmanifest-md5.txt",
        "reconstructs/v0002/tagmanifest-sha1.txt",
        "reconstructs/v0002/tagmanifest-sha256.txt",
        "reconstructs/v0002/versionInventory.xml",
        "reconstructs/v0003",
        "reconstructs/v0003/bag-info.txt",
        "reconstructs/v0003/bagit.txt",
        "reconstructs/v0003/data",
        "reconstructs/v0003/data/content",
        "reconstructs/v0003/data/content/page-1.jpg",
        "reconstructs/v0003/data/content/page-2.jpg",
        "reconstructs/v0003/data/content/page-3.jpg",
        "reconstructs/v0003/data/content/page-4.jpg",
        "reconstructs/v0003/data/content/title.jpg",
        "reconstructs/v0003/data/metadata",
        "reconstructs/v0003/data/metadata/contentMetadata.xml",
        "reconstructs/v0003/data/metadata/descMetadata.xml",
        "reconstructs/v0003/data/metadata/identityMetadata.xml",
        "reconstructs/v0003/data/metadata/provenanceMetadata.xml",
        "reconstructs/v0003/data/metadata/versionMetadata.xml",
        "reconstructs/v0003/manifest-md5.txt",
        "reconstructs/v0003/manifest-sha1.txt",
        "reconstructs/v0003/manifest-sha256.txt",
        "reconstructs/v0003/tagmanifest-md5.txt",
        "reconstructs/v0003/tagmanifest-sha1.txt",
        "reconstructs/v0003/tagmanifest-sha256.txt",
        "reconstructs/v0003/versionInventory.xml"
      ]
      reconstructs_dir.rmtree if reconstructs_dir.exist?
    end

    it 'bags a druid with a duplicate resource' do
      object_id = 'bb077xv1376'
      object_dir = File.join(fixtures_directory, "/storage_root03/moab_storage_trunk/bb/077/xv/1376/#{object_id}")
      bag_dir = File.join(fixtures_directory, "/storage_root03/deposit_trunk/#{object_id}")
      storage_object = described_class.new(object_id, object_dir)
      expect { storage_object.reconstruct_version(1, bag_dir) }.not_to raise_error(Errno::EEXIST)
      FileUtils.rmtree(bag_dir) if File.exist?(bag_dir)
    end
  end

  describe '#storage_filepath' do
    it 'returns Pathname if file exists' do
      catalog_filepath = 'v0001/data/content/intro-1.jpg'
      filepath = storage_object.storage_filepath(catalog_filepath)
      expect(filepath).to be_instance_of Pathname
      expect(filepath.to_s).to include 'ingests/jq937jp0017/v0001/data/content/intro-1.jpg'
    end

    it 'non-existent file raises Moab::FileNotFoundException' do
      expect { @storage_object.storage_filepath('dummy') }.to raise_exception Moab::FileNotFoundException
    end
  end

  specify '#version_id_list' do
    expect(@storage_object.version_id_list.size).to eq 0
    expect(storage_object.version_id_list.size).to eq 3
  end

  specify '#version_list' do
    expect(@storage_object.version_list.size).to eq 0
    version_list = storage_object.version_list
    expect(version_list.size).to eq 3
    expect(version_list[1].version_id).to eq 2
  end

  specify '#current_version_id' do
    expect(@storage_object.current_version_id).to eq 0
    expect(storage_object.current_version_id).to eq 3
  end

  specify '#current_version' do
    expect(@storage_object.current_version.version_id).to eq 0
    expect(storage_object.current_version.version_id).to eq 3
  end

  specify '#validate_new_inventory' do
    version_inventory_3 = double(Moab::FileInventory.name + "3")
    expect(version_inventory_3).to receive(:version_id).twice.and_return 3
    exp_regex = /version mismatch/
    expect { storage_object.validate_new_inventory(version_inventory_3) }.to raise_exception(Moab::MoabRuntimeError, exp_regex)

    version_inventory_4 = double(Moab::FileInventory.name + "4")
    expect(version_inventory_4).to receive(:version_id).and_return 4
    expect(storage_object.validate_new_inventory(version_inventory_4)).to eq true
  end

  describe '#find_object_version' do
    before { @storage_object = described_class.new(@druid, @ingest_object_dir) }

    it 'existing version' do
      version_2 = @storage_object.find_object_version(2)
      expect(version_2).to be_instance_of(Moab::StorageObjectVersion)
      expect(version_2.version_id).to eq 2
      expect(version_2.version_name).to eq 'v0002'
      expect(version_2.version_pathname.to_s).to match(/ingests\/jq937jp0017\/v0002/)
    end

    it 'latest version' do
      version_latest = @storage_object.find_object_version
      expect(version_latest).to be_instance_of(Moab::StorageObjectVersion)
      expect(version_latest.version_id).to eq 3
      expect(version_latest.version_name).to eq 'v0003'
      expect(version_latest.version_pathname.to_s).to match(/ingests\/jq937jp0017\/v0003/)
    end

    it 'non-existent versions' do
      expect { @storage_object.find_object_version(0) }.to raise_exception(Moab::MoabRuntimeError, /Version ID 0 does not exist/)
      expect { @storage_object.find_object_version(4) }.to raise_exception(Moab::MoabRuntimeError, /Version ID 4 does not exist/)
    end
  end

  describe '#storage_object_version' do
    before { @storage_object = described_class.new(@druid, @ingest_object_dir) }

    it 'existing version' do
      version_2 = @storage_object.storage_object_version(2)
      expect(version_2).to be_instance_of(Moab::StorageObjectVersion)
      expect(version_2.version_id).to eq 2
      expect(version_2.version_name).to eq 'v0002'
      expect(version_2.version_pathname.to_s).to match(/ingests\/jq937jp0017\/v0002/)
    end

    it 'non-existent versions do not raise exception' do
      expect { @storage_object.storage_object_version(0) }.not_to raise_exception
      expect { @storage_object.storage_object_version(4) }.not_to raise_exception
    end

    it 'nil version raises exception' do
      exp_msg_regex = /Version ID not specified/
      expect { @storage_object.storage_object_version(nil) }.to raise_exception(Moab::MoabRuntimeError, exp_msg_regex)
    end
  end

  specify '#verify_object_storage' do
    expect(storage_object.verify_object_storage.verified).to eq true
  end

  specify '#restore_object' do
    expect(@storage_object.version_list.size).to eq 0
    @storage_object.restore_object(@ingest_object_dir)
    expect(@storage_object.version_list.size).to eq 3
  end

  it '#size' do
    # values may differ from file system to file system (which is to be expected).
    # if this test fails on your mac, make sure you don't have any extraneous .DS_Store files
    # lingering in the fixture directories.
    expect(@storage_object.size).to be_between(345_000, 346_000)
  end
end
