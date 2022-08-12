# frozen_string_literal: true

describe Moab::StorageServices do
  let(:eq_xml_opts) { { element_order: false, normalize_whitespace: true } }

  it 'only instantiates StorageRepository once for the class, even if multiple threads try to access it' do
    # Object#object_id Returns an integer identifier for obj.  The same number will be returned
    # on all calls to object_id for a given object, and no two active objects will share an id.
    # https://ruby-doc.org/core-3.0.1/Object.html#method-i-object_id
    threads = []
    100.times { threads << Thread.new { described_class.repository.object_id } }
    threads.each(&:join)
    expect(threads.map(&:value).uniq.size).to eq(1)
  end

  it '.storage_roots' do
    expect(described_class.storage_roots).to eq([fixtures_dir.join('derivatives'),
                                                 fixtures_dir.join('derivatives2'),
                                                 fixtures_dir.join('newnode')])
  end

  it '.deposit_trunk' do
    expect(described_class.deposit_trunk).to eq 'packages'
  end

  it '.deposit_branch' do
    expect(described_class.deposit_branch(BARE_TEST_DRUID)).to eq BARE_TEST_DRUID
  end

  describe '.find_storage_object' do
    it 'include_deposit = false' do
      expect(described_class.repository).to receive(:find_storage_object).with(BARE_TEST_DRUID, false)
      described_class.find_storage_object(BARE_TEST_DRUID)
    end

    it 'include_deposit = true' do
      expect(described_class.repository).to receive(:find_storage_object).with(BARE_TEST_DRUID, true)
      described_class.find_storage_object(BARE_TEST_DRUID, true)
    end
  end

  describe '.search_storage_objects' do
    it 'include_deposit = false' do
      expect(described_class.repository).to receive(:search_storage_objects).with(BARE_TEST_DRUID, false)
      described_class.search_storage_objects(BARE_TEST_DRUID)
    end

    it 'include_deposit = true' do
      expect(described_class.repository).to receive(:search_storage_objects).with(BARE_TEST_DRUID, true)
      described_class.search_storage_objects(BARE_TEST_DRUID, true)
    end
  end

  describe '.storage_object' do
    it 'create = false' do
      expect(described_class.repository).to receive(:storage_object).with(BARE_TEST_DRUID, false)
      described_class.storage_object(BARE_TEST_DRUID)
    end

    it 'create = true' do
      expect(described_class.repository).to receive(:storage_object).with(BARE_TEST_DRUID, true)
      described_class.storage_object(BARE_TEST_DRUID, true)
    end
  end

  it '.object_path' do
    expect(described_class.object_path(BARE_TEST_DRUID)).to match('spec/fixtures/derivatives/ingests/jq937jp0017')
  end

  it '.object_version_path' do
    expect(described_class.object_version_path(BARE_TEST_DRUID, 1)).to match(
      'spec/fixtures/derivatives/ingests/jq937jp0017/v0001'
    )
  end

  it '.current_version' do
    expect(described_class.current_version(BARE_TEST_DRUID)).to eq 3
  end

  it '.object_size' do
    expect(described_class.object_size(BARE_TEST_DRUID)).to be_between(340000, 350000)
  end

  describe '.retrieve_file_group' do
    it 'content' do
      group = described_class.retrieve_file_group('content', BARE_TEST_DRUID, 2)
      expect(group.group_id).to eq 'content'
    end

    it 'metadata' do
      group = described_class.retrieve_file_group('metadata', BARE_TEST_DRUID, 2)
      expect(group.group_id).to eq 'metadata'
    end

    it 'manifest' do
      group = described_class.retrieve_file_group('manifest', BARE_TEST_DRUID, 2)
      expect(group.group_id).to eq 'manifests'
    end
  end

  describe '.retrieve_file' do
    it 'content' do
      content_pathname = described_class.retrieve_file('content', 'page-1.jpg', BARE_TEST_DRUID, 2)
      exp_regex = %r{spec/fixtures/derivatives/ingests/jq937jp0017/v0002/data/content/page-1.jpg}
      expect(content_pathname.to_s).to match(exp_regex)
      expect(content_pathname).to exist
    end

    it 'metadata' do
      metadata_pathname = described_class.retrieve_file('metadata', 'contentMetadata.xml', BARE_TEST_DRUID, 2)
      exp_regex = %r{spec/fixtures/derivatives/ingests/jq937jp0017/v0002/data/metadata/contentMetadata.xml}
      expect(metadata_pathname.to_s).to match(exp_regex)
      expect(metadata_pathname).to exist
    end

    it 'manifest' do
      manifest_pathname = described_class.retrieve_file('manifest', 'versionAdditions.xml', BARE_TEST_DRUID, 2)
      exp_regex = %r{spec/fixtures/derivatives/ingests/jq937jp0017/v0002/manifests/versionAdditions.xml}
      expect(manifest_pathname.to_s).to match(exp_regex)
      expect(manifest_pathname).to exist
    end
  end

  it '.retrieve_file_using_signature' do
    fixity_hash = {
      size: '40873',
      md5: '1a726cd7963bd6d3ceb10a8c353ec166',
      sha1: '583220e0572640abcd3ddd97393d224e8053a6ad'
    }
    file_signature = Moab::FileSignature.new(fixity_hash)
    filepath = described_class.retrieve_file_using_signature('content', file_signature, BARE_TEST_DRUID, 2)
    exp_regex = %r{spec/fixtures/derivatives/ingests/jq937jp0017/v0001/data/content/title.jpg}
    expect(filepath.to_s).to match(exp_regex)
  end

  describe '.retrieve_file_signature' do
    it 'content signature' do
      content_signature = described_class.retrieve_file_signature('content', 'page-1.jpg', BARE_TEST_DRUID, 2)
      expected_sig_fixity = {
        size: '32915',
        md5: 'c1c34634e2f18a354cd3e3e1574c3194',
        sha1: '0616a0bd7927328c364b2ea0b4a79c507ce915ed',
        sha256: 'b78cc53b7b8d9ed86d5e3bab3b699c7ed0db958d4a111e56b6936c8397137de0'
      }
      expect(content_signature.fixity).to eq expected_sig_fixity
    end

    it 'metadata signature' do
      metadata_signature = described_class.retrieve_file_signature('metadata', 'contentMetadata.xml', BARE_TEST_DRUID, 2)
      expected_sig_fixity = {
        size: '1303',
        md5: '8672613ac1757cda4e44cc464559cd04',
        sha1: 'c3961c0f619a81eaf8779a122219b1f860dbc2f9',
        sha256: '02b3bb1d059a705cb693bb2fe2550a8090b47cd3c32e823891b2071156485b73'
      }
      expect(metadata_signature.fixity).to eq expected_sig_fixity
    end

    it 'manifest signature' do
      manifest_signature = described_class.retrieve_file_signature('manifest', 'versionAdditions.xml', BARE_TEST_DRUID, 2)
      expect(manifest_signature.size).to eq 1631
    end
  end

  it '.version_differences' do
    differences = described_class.version_differences(BARE_TEST_DRUID, 2, 3)
    diff_ng_xml = Nokogiri::XML(differences.to_xml)
    diff_ng_xml.xpath('//@reportDatetime').remove
    exp_xml = <<-XML
      <fileInventoryDifference objectId="druid:jq937jp0017" differenceCount="6" basis="v2" other="v3" >
        <fileGroupDifference groupId="content" differenceCount="3" identical="2" copyadded="0" copydeleted="0" renamed="2" modified="0" deleted="0" added="1">
          <subset change="identical" count="2">
            <file change="identical" basisPath="page-1.jpg" otherPath="same">
              <fileSignature size="32915" md5="c1c34634e2f18a354cd3e3e1574c3194" sha1="0616a0bd7927328c364b2ea0b4a79c507ce915ed" sha256="b78cc53b7b8d9ed86d5e3bab3b699c7ed0db958d4a111e56b6936c8397137de0"/>
            </file>
            <file change="identical" basisPath="title.jpg" otherPath="same">
              <fileSignature size="40873" md5="1a726cd7963bd6d3ceb10a8c353ec166" sha1="583220e0572640abcd3ddd97393d224e8053a6ad" sha256="8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5"/>
            </file>
          </subset>
          <subset change="renamed" count="2">
            <file change="renamed" basisPath="page-2.jpg" otherPath="page-3.jpg">
              <fileSignature size="39450" md5="82fc107c88446a3119a51a8663d1e955" sha1="d0857baa307a2e9efff42467b5abd4e1cf40fcd5" sha256="235de16df4804858aefb7690baf593fb572d64bb6875ec522a4eea1f4189b5f0"/>
            </file>
            <file change="renamed" basisPath="page-3.jpg" otherPath="page-4.jpg">
              <fileSignature size="19125" md5="a5099878de7e2e064432d6df44ca8827" sha1="c0ccac433cf02a6cee89c14f9ba6072a184447a2" sha256="7bd120459eff0ecd21df94271e5c14771bfca5137d1dd74117b6a37123dfe271"/>
            </file>
          </subset>
          <subset change="copyadded" count="0"/>
          <subset change="copydeleted" count="0"/>
          <subset change="modified" count="0"/>
          <subset change="deleted" count="0"/>
          <subset change="added" count="1">
            <file change="added" basisPath="" otherPath="page-2.jpg">
              <fileSignature size="39539" md5="fe6e3ffa1b02ced189db640f68da0cc2" sha1="43ced73681687bc8e6f483618f0dcff7665e0ba7" sha256="42c0cd1fe06615d8fdb8c2e3400d6fe38461310b4ecc252e1774e0c9e3981afa"/>
            </file>
          </subset>
        </fileGroupDifference>
        <fileGroupDifference groupId="metadata" differenceCount="3" identical="2" copyadded="0" copydeleted="0" renamed="0" modified="3" deleted="0" added="0">
          <subset change="identical" count="2">
            <file change="identical" basisPath="descMetadata.xml" otherPath="same">
              <fileSignature size="3055" md5="19c96e98dd25dd68c493faa6a0fde4d0" sha1="541d5845cc866d7676fa43c337b3f7a59f597487" sha256="a575d9058a56d77a4e65e2b1bedb619686a03d5f717374bd0df98d422432e1fe"/>
            </file>
            <file change="identical" basisPath="identityMetadata.xml" otherPath="same">
              <fileSignature size="932" md5="f0815d7b45530491931d5897ccbe2dd1" sha1="4065ff5523e227c1914098372a3dc587f739030e" sha256="f48727374e73776d00517dcdc8af62ec8b18a24cff46c66a5c5f85515144628e"/>
            </file>
          </subset>
          <subset change="renamed" count="0"/>
          <subset change="modified" count="3">
            <file change="modified" basisPath="contentMetadata.xml" otherPath="same">
              <fileSignature size="1303" md5="8672613ac1757cda4e44cc464559cd04" sha1="c3961c0f619a81eaf8779a122219b1f860dbc2f9" sha256="02b3bb1d059a705cb693bb2fe2550a8090b47cd3c32e823891b2071156485b73"/>
              <fileSignature size="1586" md5="7e551285744fbe06d25c525fe1b6fd3c" sha1="c88408b79cb0fcf4c06ae4e0bd21662e21eee741" sha256="0cbf6ace137ad69607b3bb14a488bb5501e2c9e3279cd147840fe6c6a5fa70ca"/>
            </file>
            <file change="modified" basisPath="provenanceMetadata.xml" otherPath="same">
              <fileSignature size="564" md5="351e4c872148e0bc9dc24874c7ef6c08" sha1="565473bbc865b1c6f88efc99b6b5b73fd5cadbc8" sha256="ee62fdef9736ff12e394c3510f3d0a6ccd18bd5b1fb7e42fe46800d5934c9001"/>
              <fileSignature size="564" md5="17071e4607de4b272f3f06ec76be4c4a" sha1="b796a0b569bde53953ba0835bb47f4009f654349" sha256="452cd9fa6c3b8f4bd5dfda1b7f3752b4058a82b94c6f4583e4e5fe1e51317d80"/>
            </file>
            <file change="modified" basisPath="versionMetadata.xml" otherPath="same">
              <fileSignature size="399" md5="89cfd15470d0accf4ceb4a09fbcb85ab" sha1="65ea161b5bb5578ab4a06c4cd77fe3376f5adfa6" sha256="291208b41c557a5fb15cc836ab7235dadbd0881096385cc830bb446b00d2eb6b"/>
              <fileSignature size="589" md5="ab28cda36767a2ca0ca7aa8322ee6516" sha1="6fc850a1b106a1b039a597d319e821845150d85a" sha256="db9a480e829d17aa26b19ce2d52f5cc12c3cc99b4f30e6c0a217d41bd38a6298"/>
            </file>
          </subset>
          <subset change="copyadded" count="0"/>
          <subset change="copydeleted" count="0"/>
          <subset change="deleted" count="0"/>
          <subset change="added" count="0"/>
        </fileGroupDifference>
      </fileInventoryDifference>
    XML
    expect(EquivalentXml.equivalent?(diff_ng_xml, Nokogiri::XML(exp_xml), eq_xml_opts)).to be true
  end
end
