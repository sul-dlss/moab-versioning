require 'spec_helper'

describe 'Moab::Bagger' do

  specify '#initialize' do
    version_inventory = double(Moab::FileInventory.name)
    signature_catalog = double(Moab::SignatureCatalog.name)
    bag_pathname = @temp.join('bag_pathname')
    bagger = Moab::Bagger.new(version_inventory, signature_catalog, bag_pathname)
    expect(bagger.version_inventory).to eq version_inventory
    expect(bagger.signature_catalog).to eq signature_catalog
    expect(bagger.bag_pathname).to eq bag_pathname
  end

  describe '=========================== INSTANCE ATTRIBUTES ===========================' do


    before(:all) do
      @inventory = Moab::FileInventory.read_xml_file(@manifests.join('v0002'),'version')
      @catalog = Moab::SignatureCatalog.read_xml_file(@manifests.join('v0001'))
      @bag_pathname = @temp.join('bag_pathname')
      @bagger = Moab::Bagger.new(@inventory, @catalog, @bag_pathname)
    end

    # Unit test for attribute: {Moab::Bagger#version_inventory}
    # Which stores: [Moab::FileInventory] The complete inventory of the files comprising a digital object version
    specify 'Moab::Bagger#version_inventory' do
      value = double(Moab::FileInventory.name)
      @bagger.version_inventory= value
      expect(@bagger.version_inventory).to eq(value)

      # def version_inventory=(value)
      #   @version_inventory = value
      # end

      # def version_inventory
      #   @version_inventory
      # end
    end

    # Unit test for attribute: {Moab::Bagger#signature_catalog}
    # Which stores: [Moab::SignatureCatalog] The signature catalog, used to specify source paths (in :reconstructor
    #  mode), or to filter the version inventory (in :depositor mode)
    specify 'Moab::Bagger#signature_catalog' do
      value = double(Moab::SignatureCatalog.name)
      @bagger.signature_catalog= value
      expect(@bagger.signature_catalog).to eq(value)

      # def signature_catalog=(value)
      #   @signature_catalog = value
      # end

      # def signature_catalog
      #   @signature_catalog
      # end
    end

    # Unit test for attribute: {Moab::Bagger#bag_pathname}
    # Which stores: [Pathname] The location of the Bagit bag to be created
    specify 'Moab::Bagger#bag_pathname' do
      value = @temp.join('bag_pathname')
      @bagger.bag_pathname= value
      expect(@bagger.bag_pathname).to eq(value)

      # def bag_pathname=(value)
      #   @bag_pathname = value
      # end

      # def bag_pathname
      #   @bag_pathname
      # end
    end

    # Unit test for attribute: {Moab::Bagger#bag_inventory}
    # Which stores: [Moab::FileInventory] The actual inventory of the files to be packaged (derived from @version_inventory in {#fill_bag})
    specify 'Moab::Bagger#bag_inventory' do
      value = double(Moab::FileInventory.name)
      @bagger.bag_inventory= value
      expect(@bagger.bag_inventory).to eq(value)

      # def bag_inventory=(value)
      #   @bag_inventory = value
      # end

      # def bag_inventory
      #   @bag_inventory
      # end
    end

    # Unit test for attribute: {Moab::Bagger#package_mode}
    # Which stores: [Symbol] The operational mode controlling what gets bagged {#fill_bag} and the full path of source files {#fill_payload}
    specify 'Moab::Bagger#package_mode' do
      value = :test_package_mode
      @bagger.package_mode= value
      expect(@bagger.package_mode).to eq(value)

      # def package_mode=(value)
      #   @package_mode = value
      # end

      # def package_mode
      #   @package_mode
      # end
    end

  end

  describe '=========================== INSTANCE METHODS ===========================' do

    before(:all) do
      @submit_source_base = @data.join('v0002')
      @submit_inventory = Moab::FileInventory.read_xml_file(@manifests.join('v0002'),'version')
      @submit_catalog = Moab::SignatureCatalog.read_xml_file(@manifests.join('v0001'))
      @submit_bag_inventory = @submit_catalog.version_additions(@submit_inventory)
      @submit_bag_pathname = @temp.join('submit_bag_pathname')

      @disseminate_base = @ingests.join(@obj)
      @disseminate_inventory = Moab::FileInventory.read_xml_file(@disseminate_base.join('v0002','manifests'),'version')
      @disseminate_catalog = Moab::SignatureCatalog.read_xml_file(@disseminate_base.join('v0002','manifests'))
      @disseminate_bag_inventory = @disseminate_inventory
      @disseminate_bag_pathname = @temp.join('disseminate_bag_pathname')

    end

    before(:each) do
      @submit_bag_pathname.rmtree if @submit_bag_pathname.exist?
      @submit_bag_pathname.mkpath
      @submit_bag = Moab::Bagger.new(@submit_inventory, @submit_catalog, @submit_bag_pathname)
      @submit_bag.package_mode = :depositor
      @submit_bag.bag_inventory = @submit_bag_inventory

      @disseminate_bag_pathname.rmtree if @disseminate_bag_pathname.exist?
      @disseminate_bag_pathname.mkpath
      @disseminate_bag = Moab::Bagger.new(@disseminate_inventory, @disseminate_catalog, @disseminate_bag_pathname)
      @disseminate_bag.package_mode = :reconstructor
      @disseminate_bag.bag_inventory = @disseminate_bag_inventory
    end

    after(:all) do
      @submit_bag_pathname.rmtree if @submit_bag_pathname.exist?
      @disseminate_bag_pathname.rmtree if @disseminate_bag_pathname.exist?
    end

    specify 'Moab::Bagger#delete_bag' do
      packages =  @temp.join('packages')
      bag_dir = packages.join('deleteme')
      data_dir = bag_dir.join('data')
      data_dir.mkpath
      expect(data_dir.exist?).to eq(true)
      bagger = Moab::Bagger.new(nil,nil,bag_dir)
      bagger.delete_bag
      expect(bag_dir.exist?).to eq(false)
    end

    specify 'Moab::Bagger#delete_tarfile' do
      packages =  @temp.join('packages')
      tar_file = packages.join('deleteme.tar')
      tar_file.open('w') {|f| f.puts "delete me please"}
      expect(tar_file.exist?).to eq(true)
      bag_dir = packages.join('deleteme')
      bagger = Moab::Bagger.new(nil,nil,bag_dir)
      bagger.delete_tarfile
      expect(tar_file.exist?).to eq(false)
    end

    # Unit test for method: {Moab::Bagger#fill_bag}
    # Which returns: [Moab::Bagger] Perform all the operations required to fill the bag payload, write the manifests
    #   and tagfiles, and checksum the tagfiles
    # For input parameters:
    # * package_mode [Symbol] = The operational mode controlling what gets bagged and the full path of source files
    #  (Moab::Bagger#fill_payload)
    specify 'Moab::Bagger#fill_bag' do
      packages_dir = @temp.join('packages')
      packages_dir.rmtree if packages_dir.exist?
      (1..3).each do |version|
        vname = @vname[version]
        package  = packages_dir.join(vname)
        unless package.join('data').exist?
          data_dir = @data.join(vname)
          inventory = Moab::FileInventory.read_xml_file(@manifests.join(vname),'version')
          catalog = case version
                      when 1
                        Moab::SignatureCatalog.new(:digital_object_id => inventory.digital_object_id)
                      else
                        Moab::SignatureCatalog.read_xml_file(@manifests.join(@vname[version-1]))
                    end
          Moab::Bagger.new(inventory,catalog,package).fill_bag(:depositor, data_dir)
        end
      end

      files = Array.new
      packages_dir.find { |f| files << f.relative_path_from(@temp).to_s }
      expect(files.sort).to eq([
          "packages",
          "packages/v0001",
          "packages/v0001/bag-info.txt",
          "packages/v0001/bagit.txt",
          "packages/v0001/data",
          "packages/v0001/data/content",
          "packages/v0001/data/content/intro-1.jpg",
          "packages/v0001/data/content/intro-2.jpg",
          "packages/v0001/data/content/page-1.jpg",
          "packages/v0001/data/content/page-2.jpg",
          "packages/v0001/data/content/page-3.jpg",
          "packages/v0001/data/content/title.jpg",
          "packages/v0001/data/metadata",
          "packages/v0001/data/metadata/contentMetadata.xml",
          "packages/v0001/data/metadata/descMetadata.xml",
          "packages/v0001/data/metadata/identityMetadata.xml",
          "packages/v0001/data/metadata/provenanceMetadata.xml",
          "packages/v0001/data/metadata/versionMetadata.xml",
          "packages/v0001/manifest-md5.txt",
          "packages/v0001/manifest-sha1.txt",
          "packages/v0001/manifest-sha256.txt",
          "packages/v0001/tagmanifest-md5.txt",
          "packages/v0001/tagmanifest-sha1.txt",
          "packages/v0001/tagmanifest-sha256.txt",
          "packages/v0001/versionAdditions.xml",
          "packages/v0001/versionInventory.xml",
          "packages/v0002",
          "packages/v0002/bag-info.txt",
          "packages/v0002/bagit.txt",
          "packages/v0002/data",
          "packages/v0002/data/content",
          "packages/v0002/data/content/page-1.jpg",
          "packages/v0002/data/metadata",
          "packages/v0002/data/metadata/contentMetadata.xml",
          "packages/v0002/data/metadata/provenanceMetadata.xml",
          "packages/v0002/data/metadata/versionMetadata.xml",
          "packages/v0002/manifest-md5.txt",
          "packages/v0002/manifest-sha1.txt",
          "packages/v0002/manifest-sha256.txt",
          "packages/v0002/tagmanifest-md5.txt",
          "packages/v0002/tagmanifest-sha1.txt",
          "packages/v0002/tagmanifest-sha256.txt",
          "packages/v0002/versionAdditions.xml",
          "packages/v0002/versionInventory.xml",
          "packages/v0003",
          "packages/v0003/bag-info.txt",
          "packages/v0003/bagit.txt",
          "packages/v0003/data",
          "packages/v0003/data/content",
          "packages/v0003/data/content/page-2.jpg",
          "packages/v0003/data/metadata",
          "packages/v0003/data/metadata/contentMetadata.xml",
          "packages/v0003/data/metadata/provenanceMetadata.xml",
          "packages/v0003/data/metadata/versionMetadata.xml",
          "packages/v0003/manifest-md5.txt",
          "packages/v0003/manifest-sha1.txt",
          "packages/v0003/manifest-sha256.txt",
          "packages/v0003/tagmanifest-md5.txt",
          "packages/v0003/tagmanifest-sha1.txt",
          "packages/v0003/tagmanifest-sha256.txt",
          "packages/v0003/versionAdditions.xml",
          "packages/v0003/versionInventory.xml"
      ])

      packages_dir.rmtree if packages_dir.exist?

      bag = @submit_bag
      expect(bag).to receive(:fill_payload)
      expect(bag).to receive(:create_payload_manifests)
      expect(bag).to receive(:create_bag_info_txt)
      expect(bag).to receive(:create_bagit_txt)
      expect(bag).to receive(:create_tagfile_manifests)
      expect(@submit_inventory).to receive(:write_xml_file).with(@submit_bag_pathname,'version')
      expect(@submit_catalog).to receive(:version_additions).with(@submit_inventory).and_return(@submit_bag_inventory)
      expect(@submit_bag_inventory).to receive(:write_xml_file).with(@submit_bag_pathname,'additions')
      bag.fill_bag(:depositor, @submit_source_base)
      expect(bag.package_mode).to eq(:depositor)

      bag = @disseminate_bag
      expect(bag).to receive(:fill_payload)
      expect(bag).to receive(:create_payload_manifests)
      expect(bag).to receive(:create_bag_info_txt)
      expect(bag).to receive(:create_bagit_txt)
      expect(bag).to receive(:create_tagfile_manifests)
      expect(@disseminate_catalog).not_to receive(:version_additions)
      expect(@disseminate_bag_inventory).to receive(:write_xml_file).with(@disseminate_bag_pathname,'version')
      bag.fill_bag(:reconstructor, @disseminate_base)
      expect(bag.package_mode).to eq(:reconstructor)

    end

    # Unit test for method: {Moab::Bagger#fill_payload}
    # Which returns: [void] Fill in the bag's data folder with copies of all files to be packaged for delivery.
    # For input parameters: (None)
    specify 'Moab::Bagger#fill_payload' do
      bag = @submit_bag
      bag.fill_payload(@submit_source_base)
      files = Array.new
      bag.bag_pathname.join('data').find {|f| files << f.relative_path_from(@temp).to_s}
      expect(files.sort).to eq([
          "submit_bag_pathname/data",
          "submit_bag_pathname/data/content",
          "submit_bag_pathname/data/content/page-1.jpg",
          "submit_bag_pathname/data/metadata",
          "submit_bag_pathname/data/metadata/contentMetadata.xml",
          "submit_bag_pathname/data/metadata/provenanceMetadata.xml",
          "submit_bag_pathname/data/metadata/versionMetadata.xml"
      ])

      bag = @disseminate_bag
      bag.fill_payload(@disseminate_base)
      files = Array.new
      bag.bag_pathname.join('data').find {|f| files << f.relative_path_from(@temp).to_s}
      expect(files.sort).to eq([
          "disseminate_bag_pathname/data",
          "disseminate_bag_pathname/data/content",
          "disseminate_bag_pathname/data/content/page-1.jpg",
          "disseminate_bag_pathname/data/content/page-2.jpg",
          "disseminate_bag_pathname/data/content/page-3.jpg",
          "disseminate_bag_pathname/data/content/title.jpg",
          "disseminate_bag_pathname/data/metadata",
          "disseminate_bag_pathname/data/metadata/contentMetadata.xml",
          "disseminate_bag_pathname/data/metadata/descMetadata.xml",
          "disseminate_bag_pathname/data/metadata/identityMetadata.xml",
          "disseminate_bag_pathname/data/metadata/provenanceMetadata.xml",
          "disseminate_bag_pathname/data/metadata/versionMetadata.xml"
      ])

    end

    # Unit test for method: {Moab::Bagger#create_payload_manifests}
    # Which returns: [void] Using the checksum information from the inventory, create md5 and sha1 manifest files for the payload
    # For input parameters: (None)
    specify 'Moab::Bagger#create_payload_manifests' do
      bag = @submit_bag
      bag.fill_payload(@submit_source_base)
      bag.create_payload_manifests()
      md5 = bag.bag_pathname.join('manifest-md5.txt')
      expect(md5.exist?).to eq(true)
      expect(md5.readlines.sort).to eq([
          "351e4c872148e0bc9dc24874c7ef6c08 data/metadata/provenanceMetadata.xml\n",
          "8672613ac1757cda4e44cc464559cd04 data/metadata/contentMetadata.xml\n",
          "89cfd15470d0accf4ceb4a09fbcb85ab data/metadata/versionMetadata.xml\n",
          "c1c34634e2f18a354cd3e3e1574c3194 data/content/page-1.jpg\n"       ])
      sha1 = bag.bag_pathname.join('manifest-sha1.txt')
      expect(sha1.exist?).to eq(true)
      expect(sha1.readlines.sort).to eq([
          "0616a0bd7927328c364b2ea0b4a79c507ce915ed data/content/page-1.jpg\n",
          "565473bbc865b1c6f88efc99b6b5b73fd5cadbc8 data/metadata/provenanceMetadata.xml\n",
          "65ea161b5bb5578ab4a06c4cd77fe3376f5adfa6 data/metadata/versionMetadata.xml\n",
          "c3961c0f619a81eaf8779a122219b1f860dbc2f9 data/metadata/contentMetadata.xml\n"
      ])

      # def create_payload_manifests
      #   md5 = @bag_pathname.join('manifest-md5.txt').open('w')
      #   sha1 = @bag_pathname.join('manifest-sha1.txt').open('w')
      #   @bag_inventory.groups.each do |group|
      #     group.files.each do |file|
      #       file.instances.each do |instance|
      #         signature = file.signature
      #         relative_path = File.join(group.group_id, instance.path)
      #         md5.puts("#{signature.md5} *#{relative_path}")
      #         sha1.puts("#{signature.sha1} *#{relative_path}")
      #       end
      #     end
      #   end
      # ensure
      #   md5.close if md5
      #   sha1.close if sha1
      # end
    end

    # Unit test for method: {Moab::Bagger#create_bag_info_txt}
    # Which returns: [void] Generate the bag-info.txt tag file
    # For input parameters: (None)
    specify 'Moab::Bagger#create_bag_info_txt' do
      bag = @submit_bag
      bag.create_bag_info_txt()
      bag_info = bag.bag_pathname.join('bag-info.txt')
      expect(bag_info.exist?).to eq(true)
      expect(bag_info.readlines).to eq([
          "External-Identifier: druid:jq937jp0017-v2\n",
          "Payload-Oxum: 35181.4\n",
          "Bag-Size: 34.36 KB\n"
      ])

      # def create_bag_info_txt
      #   @bag_pathname.join("bag-info.txt").open('w') do |f|
      #     f.puts "External-Identifier: #{@bag_inventory.package_id}"
      #     f.puts "Payload-Oxum: #{@bag_inventory.byte_count}.#{@bag_inventory.file_count}"
      #     f.puts "Bag-Size: #{@bag_inventory.human_size}"
      #   end
      # end
    end

    # Unit test for method: {Moab::Bagger#create_bagit_txt}
    # Which returns: [void] Generate the bagit.txt tag file
    # For input parameters: (None)
    specify 'Moab::Bagger#create_bagit_txt' do
      bag = @submit_bag
      bag.create_bagit_txt()
      bagit = bag.bag_pathname.join('bagit.txt')
      expect(bagit.exist?).to eq(true)
      expect(bagit.readlines).to eq([
          "Tag-File-Character-Encoding: UTF-8\n",
           "BagIt-Version: 0.97\n"
      ])

      # def create_bagit_txt()
      #   @bag_pathname.join("bagit.txt").open('w') do |f|
      #     f.puts "Tag-File-Character-Encoding: UTF-8"
      #     f.puts "BagIt-Version: 0.97"
      #   end
      # end
    end

    # Unit test for method: {Moab::Bagger#create_tagfile_manifests}
    # Which returns: [void] create md5 and sha1 manifest files containing checksums for all files in the bag's root directory
    # For input parameters: (None)
    specify 'Moab::Bagger#create_tagfile_manifests' do
      bag = @submit_bag
      bag.fill_bag(:depositor,@submit_source_base)
      md5 = bag.bag_pathname.join('tagmanifest-md5.txt')
      expect(md5.exist?).to eq(true)
      expect(md5.readlines.collect{ |line| line.split(/ /)[1] }).to match_array [
          "bag-info.txt\n",
          "bagit.txt\n",
          "manifest-md5.txt\n",
          "manifest-sha1.txt\n",
          "manifest-sha256.txt\n",
          "versionAdditions.xml\n",
          "versionInventory.xml\n"
      ]

      sha1 = bag.bag_pathname.join('tagmanifest-sha1.txt')
      expect(sha1.exist?).to eq(true)
      expect(sha1.readlines.collect{ |line| line.split(/ /)[1] }).to match_array [
          "bag-info.txt\n",
          "bagit.txt\n",
          "manifest-md5.txt\n",
          "manifest-sha1.txt\n",
          "manifest-sha256.txt\n",
          "versionAdditions.xml\n",
          "versionInventory.xml\n"
      ]
      # def create_tagfile_manifests()
      #   md5 = @bag_pathname.join('tagmanifest-md5.txt').open('w')
      #   sha1 = @bag_pathname.join('tagmanifest-sha1.txt').open('w')
      #   @bag_pathname.children.each do |file|
      #     unless file.directory? || file.basename.to_s[0, 11] == 'tagmanifest'
      #       signature = Moab::FileSignature.new.signature_from_file(file.realpath)
      #       md5.puts("#{signature.md5} *#{file.basename}")
      #       sha1.puts("#{signature.sha1} *#{file.basename}")
      #     end
      #   end
      # ensure
      #   md5.close if md5
      #   sha1.close if sha1
      # end
    end

    specify 'Moab::Bagger#create_tarfile' do
      bag_dir = @packages.join('v0001')
      tarfile = @temp.join('test.tar')
      bagger = Moab::Bagger.new(nil,nil,bag_dir)
      expect(bagger).to receive(:shell_execute).with("cd '#{@packages}'; tar --dereference --force-local -cf  '#{@temp}/test.tar' 'v0001'")
      expect{bagger.create_tarfile(tarfile)}.to raise_exception(/Unable to create tarfile/)
    end

  end

end
