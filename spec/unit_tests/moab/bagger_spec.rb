# frozen_string_literal: true

describe Moab::Bagger do
  before do
    submit_bag_pathname.rmtree if submit_bag_pathname.exist?
    submit_bag_pathname.mkpath
    disseminate_bag_pathname.rmtree if disseminate_bag_pathname.exist?
    disseminate_bag_pathname.mkpath
  end

  after do
    submit_bag_pathname.rmtree if submit_bag_pathname.exist?
    disseminate_bag_pathname.rmtree if disseminate_bag_pathname.exist?
  end

  let(:submit_bag_pathname) { temp_dir.join('submit_bag_pathname') }
  let(:disseminate_bag_pathname) { temp_dir.join('disseminate_bag_pathname') }
  let(:disseminate_bag) do
    db = described_class.new(disseminate_inventory, disseminate_catalog, disseminate_bag_pathname)
    db.package_mode = :reconstructor
    db.bag_inventory = disseminate_inventory
    db
  end
  let(:disseminate_inventory) { Moab::FileInventory.read_xml_file(disseminate_base.join('v0002', 'manifests'), 'version') }
  let(:disseminate_catalog) { Moab::SignatureCatalog.read_xml_file(disseminate_base.join('v0002', 'manifests')) }
  let(:disseminate_base) { ingests_dir.join(BARE_TEST_DRUID) }
  let(:submit_bag) do
    sb = described_class.new(submit_inventory, submit_catalog, submit_bag_pathname)
    sb.package_mode = :depositor
    sb.bag_inventory = submit_bag_inventory
    sb
  end
  let(:submit_bag_inventory) { submit_catalog.version_additions(submit_inventory) }
  let(:submit_catalog) { Moab::SignatureCatalog.read_xml_file(manifests_dir.join('v0001')) }
  let(:submit_inventory) { Moab::FileInventory.read_xml_file(manifests_dir.join('v0002'), 'version') }
  let(:submit_source_base) { test_object_data_dir.join('v0002') }

  it '#initialize' do
    version_inventory = instance_double(Moab::FileInventory.name)
    signature_catalog = instance_double(Moab::SignatureCatalog.name)
    bag_pathname = temp_dir.join('bag_pathname')
    bagger = described_class.new(version_inventory, signature_catalog, bag_pathname)
    expect(bagger.version_inventory).to eq version_inventory
    expect(bagger.signature_catalog).to eq signature_catalog
    expect(bagger.bag_pathname).to eq bag_pathname
  end

  it '#delete_bag' do
    packages = temp_dir.join('packages')
    bag_dir = packages.join('deleteme')
    bag_data_dir = bag_dir.join('data')
    bag_data_dir.mkpath
    expect(bag_data_dir.exist?).to be true
    bagger = described_class.new(nil, nil, bag_dir)
    bagger.delete_bag
    expect(bag_dir.exist?).to be false
  end

  it '#delete_tarfile' do
    packages = temp_dir.join('packages')
    tar_file = packages.join('deleteme.tar')
    tar_file.open('w') { |f| f.puts 'delete me please' }
    expect(tar_file.exist?).to be true
    bag_dir = packages.join('deleteme')
    bagger = described_class.new(nil, nil, bag_dir)
    bagger.delete_tarfile
    expect(tar_file.exist?).to be false
  end

  describe '#fill_bag' do
    it 'new Bagger made for each of 3 versions' do
      packages_dir = temp_dir.join('packages')
      packages_dir.rmtree if packages_dir.exist?
      (1..3).each do |version|
        vname = TEST_OBJECT_VERSIONS[version]
        package = packages_dir.join(vname)
        unless package.join('data').exist?
          bag_data_dir = test_object_data_dir.join(vname)
          inventory = Moab::FileInventory.read_xml_file(manifests_dir.join(vname), 'version')
          catalog = case version
                    when 1
                      Moab::SignatureCatalog.new(digital_object_id: inventory.digital_object_id)
                    else
                      Moab::SignatureCatalog.read_xml_file(manifests_dir.join(TEST_OBJECT_VERSIONS[version - 1]))
                    end
          described_class.new(inventory, catalog, package).fill_bag(:depositor, bag_data_dir)
        end
      end

      files = []
      packages_dir.find { |f| files << f.relative_path_from(temp_dir).to_s }
      expect(files.sort).to eq [
        'packages',
        'packages/v0001',
        'packages/v0001/bag-info.txt',
        'packages/v0001/bagit.txt',
        'packages/v0001/data',
        'packages/v0001/data/content',
        'packages/v0001/data/content/intro-1.jpg',
        'packages/v0001/data/content/intro-2.jpg',
        'packages/v0001/data/content/page-1.jpg',
        'packages/v0001/data/content/page-2.jpg',
        'packages/v0001/data/content/page-3.jpg',
        'packages/v0001/data/content/title.jpg',
        'packages/v0001/data/metadata',
        'packages/v0001/data/metadata/contentMetadata.xml',
        'packages/v0001/data/metadata/descMetadata.xml',
        'packages/v0001/data/metadata/identityMetadata.xml',
        'packages/v0001/data/metadata/provenanceMetadata.xml',
        'packages/v0001/data/metadata/versionMetadata.xml',
        'packages/v0001/manifest-md5.txt',
        'packages/v0001/manifest-sha1.txt',
        'packages/v0001/manifest-sha256.txt',
        'packages/v0001/tagmanifest-md5.txt',
        'packages/v0001/tagmanifest-sha1.txt',
        'packages/v0001/tagmanifest-sha256.txt',
        'packages/v0001/versionAdditions.xml',
        'packages/v0001/versionInventory.xml',
        'packages/v0002',
        'packages/v0002/bag-info.txt',
        'packages/v0002/bagit.txt',
        'packages/v0002/data',
        'packages/v0002/data/content',
        'packages/v0002/data/content/page-1.jpg',
        'packages/v0002/data/metadata',
        'packages/v0002/data/metadata/contentMetadata.xml',
        'packages/v0002/data/metadata/provenanceMetadata.xml',
        'packages/v0002/data/metadata/versionMetadata.xml',
        'packages/v0002/manifest-md5.txt',
        'packages/v0002/manifest-sha1.txt',
        'packages/v0002/manifest-sha256.txt',
        'packages/v0002/tagmanifest-md5.txt',
        'packages/v0002/tagmanifest-sha1.txt',
        'packages/v0002/tagmanifest-sha256.txt',
        'packages/v0002/versionAdditions.xml',
        'packages/v0002/versionInventory.xml',
        'packages/v0003',
        'packages/v0003/bag-info.txt',
        'packages/v0003/bagit.txt',
        'packages/v0003/data',
        'packages/v0003/data/content',
        'packages/v0003/data/content/page-2.jpg',
        'packages/v0003/data/metadata',
        'packages/v0003/data/metadata/contentMetadata.xml',
        'packages/v0003/data/metadata/provenanceMetadata.xml',
        'packages/v0003/data/metadata/versionMetadata.xml',
        'packages/v0003/manifest-md5.txt',
        'packages/v0003/manifest-sha1.txt',
        'packages/v0003/manifest-sha256.txt',
        'packages/v0003/tagmanifest-md5.txt',
        'packages/v0003/tagmanifest-sha1.txt',
        'packages/v0003/tagmanifest-sha256.txt',
        'packages/v0003/versionAdditions.xml',
        'packages/v0003/versionInventory.xml'
      ]

      packages_dir.rmtree if packages_dir.exist?
    end

    context 'with :depositor' do
      before do
        allow(submit_bag).to receive(:fill_payload).and_call_original
        allow(submit_bag).to receive(:create_payload_manifests).and_call_original
        allow(submit_bag).to receive(:create_bag_info_txt).and_call_original
        allow(submit_bag).to receive(:create_bagit_txt).and_call_original
        allow(submit_bag).to receive(:create_tagfile_manifests).and_call_original
        allow(submit_catalog).to receive(:version_additions).with(submit_inventory).and_return(submit_bag_inventory)
        allow(submit_inventory).to receive(:write_xml_file).with(submit_bag_pathname, 'version')
        allow(submit_bag_inventory).to receive(:write_xml_file).with(submit_bag_pathname, 'additions')

        submit_bag.fill_bag(:depositor, submit_source_base)
      end

      it 'bag has :depositor package_mode and expected methods called' do
        expect(submit_bag.package_mode).to eq :depositor

        expect(submit_bag).to have_received(:fill_payload)
        expect(submit_bag).to have_received(:create_payload_manifests)
        expect(submit_bag).to have_received(:create_bag_info_txt)
        expect(submit_bag).to have_received(:create_bagit_txt)
        expect(submit_bag).to have_received(:create_tagfile_manifests)
        expect(submit_inventory).to have_received(:write_xml_file).with(submit_bag_pathname, 'version')
        expect(submit_catalog).to have_received(:version_additions).with(submit_inventory)
        expect(submit_bag_inventory).to have_received(:write_xml_file).with(submit_bag_pathname, 'additions')
      end
    end

    context 'with :reconstructor' do
      before do
        allow(disseminate_bag).to receive(:fill_payload)
        allow(disseminate_bag).to receive(:create_payload_manifests)
        allow(disseminate_bag).to receive(:create_bag_info_txt)
        allow(disseminate_bag).to receive(:create_bagit_txt)
        allow(disseminate_bag).to receive(:create_tagfile_manifests)
        allow(disseminate_catalog).to receive(:version_additions)
        allow(disseminate_inventory).to receive(:write_xml_file).with(disseminate_bag_pathname, 'version')

        disseminate_bag.fill_bag(:reconstructor, disseminate_base)
      end

      it 'bag has :reconstructor package_mode and expected methods called' do
        expect(disseminate_bag.package_mode).to eq :reconstructor

        expect(disseminate_bag).to have_received(:fill_payload)
        expect(disseminate_bag).to have_received(:create_payload_manifests)
        expect(disseminate_bag).to have_received(:create_bag_info_txt)
        expect(disseminate_bag).to have_received(:create_bagit_txt)
        expect(disseminate_bag).to have_received(:create_tagfile_manifests)
        expect(disseminate_catalog).not_to have_received(:version_additions)
        expect(disseminate_inventory).to have_received(:write_xml_file).with(disseminate_bag_pathname, 'version')
      end
    end
  end

  describe '#fill_payload' do
    it 'submit_bag' do
      submit_bag.fill_payload(submit_source_base)
      files = []
      submit_bag.bag_pathname.join('data').find { |f| files << f.relative_path_from(temp_dir).to_s }
      expect(files.sort).to eq [
        'submit_bag_pathname/data',
        'submit_bag_pathname/data/content',
        'submit_bag_pathname/data/content/page-1.jpg',
        'submit_bag_pathname/data/metadata',
        'submit_bag_pathname/data/metadata/contentMetadata.xml',
        'submit_bag_pathname/data/metadata/provenanceMetadata.xml',
        'submit_bag_pathname/data/metadata/versionMetadata.xml'
      ]
    end

    it 'disseminate_bag' do
      disseminate_bag.fill_payload(disseminate_base)
      files = []
      disseminate_bag.bag_pathname.join('data').find { |f| files << f.relative_path_from(temp_dir).to_s }
      expect(files.sort).to eq [
        'disseminate_bag_pathname/data',
        'disseminate_bag_pathname/data/content',
        'disseminate_bag_pathname/data/content/page-1.jpg',
        'disseminate_bag_pathname/data/content/page-2.jpg',
        'disseminate_bag_pathname/data/content/page-3.jpg',
        'disseminate_bag_pathname/data/content/title.jpg',
        'disseminate_bag_pathname/data/metadata',
        'disseminate_bag_pathname/data/metadata/contentMetadata.xml',
        'disseminate_bag_pathname/data/metadata/descMetadata.xml',
        'disseminate_bag_pathname/data/metadata/identityMetadata.xml',
        'disseminate_bag_pathname/data/metadata/provenanceMetadata.xml',
        'disseminate_bag_pathname/data/metadata/versionMetadata.xml'
      ]
    end
  end

  it '#create_payload_manifests' do
    submit_bag.fill_payload(submit_source_base)
    submit_bag.create_payload_manifests
    md5 = submit_bag.bag_pathname.join('manifest-md5.txt')
    expect(md5.exist?).to be true
    expect(md5.readlines.sort).to eq [
      "351e4c872148e0bc9dc24874c7ef6c08 data/metadata/provenanceMetadata.xml\n",
      "8672613ac1757cda4e44cc464559cd04 data/metadata/contentMetadata.xml\n",
      "89cfd15470d0accf4ceb4a09fbcb85ab data/metadata/versionMetadata.xml\n",
      "c1c34634e2f18a354cd3e3e1574c3194 data/content/page-1.jpg\n"
    ]
    sha1 = submit_bag.bag_pathname.join('manifest-sha1.txt')
    expect(sha1.exist?).to be true
    expect(sha1.readlines.sort).to eq [
      "0616a0bd7927328c364b2ea0b4a79c507ce915ed data/content/page-1.jpg\n",
      "565473bbc865b1c6f88efc99b6b5b73fd5cadbc8 data/metadata/provenanceMetadata.xml\n",
      "65ea161b5bb5578ab4a06c4cd77fe3376f5adfa6 data/metadata/versionMetadata.xml\n",
      "c3961c0f619a81eaf8779a122219b1f860dbc2f9 data/metadata/contentMetadata.xml\n"
    ]
  end

  it '#create_bag_info_txt' do
    submit_bag.create_bag_info_txt
    bag_info = submit_bag.bag_pathname.join('bag-info.txt')
    expect(bag_info.exist?).to be true
    expect(bag_info.readlines).to eq [
      "External-Identifier: druid:jq937jp0017-v2\n",
      "Payload-Oxum: 35181.4\n",
      "Bag-Size: 34.36 KB\n"
    ]
  end

  it '#create_bagit_txt' do
    submit_bag.create_bagit_txt
    bagit = submit_bag.bag_pathname.join('bagit.txt')
    expect(bagit.exist?).to be true
    expect(bagit.readlines).to eq [
      "Tag-File-Character-Encoding: UTF-8\n",
      "BagIt-Version: 0.97\n"
    ]
  end

  it '#create_tagfile_manifests' do
    allow(submit_bag).to receive(:create_tagfile_manifests).and_call_original
    # Add an NFS temp file to be ignored.
    submit_bag.bag_pathname.join('.nfs000000000000000000001').open('w') {} # rubocop:disable Lint/EmptyBlock
    submit_bag.fill_bag(:depositor, submit_source_base)
    expect(submit_bag).to have_received(:create_tagfile_manifests)
    md5 = submit_bag.bag_pathname.join('tagmanifest-md5.txt')
    expect(md5.exist?).to be true
    expect(md5.readlines.collect do |line|
             line.split(/ /)[1]
           end).to contain_exactly("bag-info.txt\n", "bagit.txt\n", "manifest-md5.txt\n", "manifest-sha1.txt\n",
                                   "manifest-sha256.txt\n", "versionAdditions.xml\n", "versionInventory.xml\n")

    sha1 = submit_bag.bag_pathname.join('tagmanifest-sha1.txt')
    expect(sha1.exist?).to be true
    expect(sha1.readlines.collect do |line|
             line.split(/ /)[1]
           end).to contain_exactly("bag-info.txt\n", "bagit.txt\n", "manifest-md5.txt\n", "manifest-sha1.txt\n",
                                   "manifest-sha256.txt\n", "versionAdditions.xml\n", "versionInventory.xml\n")
  end

  it '#create_tarfile' do
    bag_dir = packages_dir.join('v0001')
    tarfile = temp_dir.join('test.tar')
    bagger = described_class.new(nil, nil, bag_dir)
    cmd = "cd '#{packages_dir}'; tar --dereference --force-local -cf  '#{temp_dir}/test.tar' 'v0001'"
    allow(bagger).to receive(:shell_execute).with(cmd)
    expect { bagger.create_tarfile(tarfile) }.to raise_exception(Moab::MoabRuntimeError, /^Unable to create tarfile/)
    expect(bagger).to have_received(:shell_execute).with(cmd)
  end
end
