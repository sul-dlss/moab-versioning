require 'spec_helper'

# Unit tests for class {Moab::Bagger}
describe 'Moab::Bagger' do
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Moab::Bagger#initialize}
    # Which returns an instance of: [Moab::Bagger]
    # For input parameters:
    # * version_inventory [FileInventory] = The complete inventory of the files comprising a digital object version 
    # * signature_catalog [SignatureCatalog] = The signature catalog, used to specify source paths (in :reconstructor mode), or to filter the version inventory (in :depositor mode) 
    # * bag_pathname [Pathname, String] = The location of the Bagit bag to be created
    specify 'Moab::Bagger#initialize' do
       
      # test initialization with required parameters (if any)
      version_inventory = double(FileInventory.name) 
      signature_catalog = double(SignatureCatalog.name) 
      bag_pathname = @temp.join('bag_pathname')
      bagger = Bagger.new(version_inventory, signature_catalog,  bag_pathname)
      bagger.should be_instance_of(Bagger)
      bagger.version_inventory.should == version_inventory
      bagger.signature_catalog.should == signature_catalog
      bagger.bag_pathname.should == bag_pathname
       
    end
  
  end
  
  describe '=========================== INSTANCE ATTRIBUTES ===========================' do

    
    before(:all) do
      @inventory = FileInventory.read_xml_file(@manifests.join('v0002'),'version')
      @catalog = SignatureCatalog.read_xml_file(@manifests.join('v0001'))
      @bag_pathname = @temp.join('bag_pathname')
      @bagger = Bagger.new(@inventory, @catalog, @bag_pathname)
    end
    
    # Unit test for attribute: {Moab::Bagger#version_inventory}
    # Which stores: [FileInventory] The complete inventory of the files comprising a digital object version
    specify 'Moab::Bagger#version_inventory' do
      value = double(FileInventory.name)
      @bagger.version_inventory= value
      @bagger.version_inventory.should == value
       
      # def version_inventory=(value)
      #   @version_inventory = value
      # end
       
      # def version_inventory
      #   @version_inventory
      # end
    end
    
    # Unit test for attribute: {Moab::Bagger#signature_catalog}
    # Which stores: [SignatureCatalog] The signature catalog, used to specify source paths (in :reconstructor mode), or to filter the version inventory (in :depositor mode)
    specify 'Moab::Bagger#signature_catalog' do
      value = double(SignatureCatalog.name)
      @bagger.signature_catalog= value
      @bagger.signature_catalog.should == value
       
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
      @bagger.bag_pathname.should == value
       
      # def bag_pathname=(value)
      #   @bag_pathname = value
      # end
       
      # def bag_pathname
      #   @bag_pathname
      # end
    end
    
    # Unit test for attribute: {Moab::Bagger#bag_inventory}
    # Which stores: [FileInventory] The actual inventory of the files to be packaged (derived from @version_inventory in {#fill_bag})
    specify 'Moab::Bagger#bag_inventory' do
      value = double(FileInventory.name)
      @bagger.bag_inventory= value
      @bagger.bag_inventory.should == value
       
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
      @bagger.package_mode.should == value
       
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
      @submit_inventory = FileInventory.read_xml_file(@manifests.join('v0002'),'version')
      @submit_catalog = SignatureCatalog.read_xml_file(@manifests.join('v0001'))
      @submit_bag_inventory = @submit_catalog.version_additions(@submit_inventory)
      @submit_bag_pathname = @temp.join('submit_bag_pathname')

      @disseminate_base = @ingests.join(@obj)
      @disseminate_inventory = FileInventory.read_xml_file(@disseminate_base.join('v0002','manifests'),'version')
      @disseminate_catalog = SignatureCatalog.read_xml_file(@disseminate_base.join('v0002','manifests'))
      @disseminate_bag_inventory = @disseminate_inventory
      @disseminate_bag_pathname = @temp.join('disseminate_bag_pathname')

    end

    before(:each) do
      @submit_bag_pathname.rmtree if @submit_bag_pathname.exist?
      @submit_bag_pathname.mkpath
      @submit_bag = Bagger.new(@submit_inventory, @submit_catalog, @submit_bag_pathname)
      @submit_bag.package_mode = :depositor
      @submit_bag.bag_inventory = @submit_bag_inventory

      @disseminate_bag_pathname.rmtree if @disseminate_bag_pathname.exist?
      @disseminate_bag_pathname.mkpath
      @disseminate_bag = Bagger.new(@disseminate_inventory, @disseminate_catalog, @disseminate_bag_pathname)
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
      data_dir.exist?.should == true
      bagger = Bagger.new(nil,nil,bag_dir)
      bagger.delete_bag
      bag_dir.exist?.should == false
    end

    specify 'Moab::Bagger#delete_tarfile' do
      packages =  @temp.join('packages')
      tar_file = packages.join('deleteme.tar')
      tar_file.open('w') {|f| f.puts "delete me please"}
      tar_file.exist?.should == true
      bag_dir = packages.join('deleteme')
      bagger = Bagger.new(nil,nil,bag_dir)
      bagger.delete_tarfile
      tar_file.exist?.should == false
    end
    
    # Unit test for method: {Moab::Bagger#fill_bag}
    # Which returns: [Bagger] Perform all the operations required to fill the bag payload, write the manifests and tagfiles, and checksum the tagfiles
    # For input parameters:
    # * package_mode [Symbol] = The operational mode controlling what gets bagged and the full path of source files (Bagger#fill_payload) 
    specify 'Moab::Bagger#fill_bag' do
      packages_dir = @temp.join('packages')
      packages_dir.rmtree if packages_dir.exist?
      (1..3).each do |version|
        vname = @vname[version]
        package  = packages_dir.join(vname)
        unless package.join('data').exist?
          data_dir = @data.join(vname)
          inventory = FileInventory.read_xml_file(@manifests.join(vname),'version')
          case version
            when 1
              catalog = SignatureCatalog.new(:digital_object_id => inventory.digital_object_id)
            else
              catalog = SignatureCatalog.read_xml_file(@manifests.join(@vname[version-1]))
          end
          Bagger.new(inventory,catalog,package).fill_bag(:depositor, data_dir)
        end
      end

      files = Array.new
      packages_dir.find { |f| files << f.relative_path_from(@temp).to_s }
      files.sort.should == [
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
      ]

      packages_dir.rmtree if packages_dir.exist?

      bag = @submit_bag
      bag.should_receive(:fill_payload)
      bag.should_receive(:create_payload_manifests)
      bag.should_receive(:create_bag_info_txt)
      bag.should_receive(:create_bagit_txt)
      bag.should_receive(:create_tagfile_manifests)
      @submit_inventory.should_receive(:write_xml_file).with(@submit_bag_pathname,'version')
      @submit_catalog.should_receive(:version_additions).with(@submit_inventory).and_return(@submit_bag_inventory)
      @submit_bag_inventory.should_receive(:write_xml_file).with(@submit_bag_pathname,'additions')
      bag.fill_bag(:depositor, @submit_source_base)
      bag.package_mode.should == :depositor

      bag = @disseminate_bag
      bag.should_receive(:fill_payload)
      bag.should_receive(:create_payload_manifests)
      bag.should_receive(:create_bag_info_txt)
      bag.should_receive(:create_bagit_txt)
      bag.should_receive(:create_tagfile_manifests)
      @disseminate_catalog.should_not_receive(:version_additions)
      @disseminate_bag_inventory.should_receive(:write_xml_file).with(@disseminate_bag_pathname,'version')
      bag.fill_bag(:reconstructor, @disseminate_base)
      bag.package_mode.should == :reconstructor

    end

    # Unit test for method: {Moab::Bagger#fill_payload}
    # Which returns: [void] Fill in the bag's data folder with copies of all files to be packaged for delivery.
    # For input parameters: (None)
    specify 'Moab::Bagger#fill_payload' do
      bag = @submit_bag
      bag.fill_payload(@submit_source_base)
      files = Array.new
      bag.bag_pathname.join('data').find {|f| files << f.relative_path_from(@temp).to_s}
      files.sort.should == [
          "submit_bag_pathname/data",
          "submit_bag_pathname/data/content",
          "submit_bag_pathname/data/content/page-1.jpg",
          "submit_bag_pathname/data/metadata",
          "submit_bag_pathname/data/metadata/contentMetadata.xml",
          "submit_bag_pathname/data/metadata/provenanceMetadata.xml",
          "submit_bag_pathname/data/metadata/versionMetadata.xml"
      ]

      bag = @disseminate_bag
      bag.fill_payload(@disseminate_base)
      files = Array.new
      bag.bag_pathname.join('data').find {|f| files << f.relative_path_from(@temp).to_s}
      files.sort.should == [
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
      ]

    end
    
    # Unit test for method: {Moab::Bagger#create_payload_manifests}
    # Which returns: [void] Using the checksum information from the inventory, create md5 and sha1 manifest files for the payload
    # For input parameters: (None)
    specify 'Moab::Bagger#create_payload_manifests' do
      bag = @submit_bag
      bag.fill_payload(@submit_source_base)
      bag.create_payload_manifests()
      md5 = bag.bag_pathname.join('manifest-md5.txt')
      md5.exist?.should == true
      md5.readlines.sort.should == [
          "351e4c872148e0bc9dc24874c7ef6c08 data/metadata/provenanceMetadata.xml\n",
          "8672613ac1757cda4e44cc464559cd04 data/metadata/contentMetadata.xml\n",
          "89cfd15470d0accf4ceb4a09fbcb85ab data/metadata/versionMetadata.xml\n",
          "c1c34634e2f18a354cd3e3e1574c3194 data/content/page-1.jpg\n"       ]
      sha1 = bag.bag_pathname.join('manifest-sha1.txt')
      sha1.exist?.should == true
      sha1.readlines.sort.should == [
          "0616a0bd7927328c364b2ea0b4a79c507ce915ed data/content/page-1.jpg\n",
          "565473bbc865b1c6f88efc99b6b5b73fd5cadbc8 data/metadata/provenanceMetadata.xml\n",
          "65ea161b5bb5578ab4a06c4cd77fe3376f5adfa6 data/metadata/versionMetadata.xml\n",
          "c3961c0f619a81eaf8779a122219b1f860dbc2f9 data/metadata/contentMetadata.xml\n"
      ]

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
      bag_info.exist?.should == true
      bag_info.readlines.should == [
          "External-Identifier: druid:jq937jp0017-v2\n",
          "Payload-Oxum: 35181.4\n",
          "Bag-Size: 34.36 KB\n"
      ]

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
      bagit.exist?.should == true
      bagit.readlines.should == [
          "Tag-File-Character-Encoding: UTF-8\n",
           "BagIt-Version: 0.97\n"
      ]

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
      md5.exist?.should == true
      (md5.readlines.collect{ |line| line.split(/ /)[1] }).should match_array [
          "bag-info.txt\n",
          "bagit.txt\n",
          "manifest-md5.txt\n",
          "manifest-sha1.txt\n",
          "manifest-sha256.txt\n",
          "versionAdditions.xml\n",
          "versionInventory.xml\n"
      ]

      sha1 = bag.bag_pathname.join('tagmanifest-sha1.txt')
      sha1.exist?.should == true
      (sha1.readlines.collect{ |line| line.split(/ /)[1] }).should match_array [
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
      #       signature = FileSignature.new.signature_from_file(file.realpath)
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
      bagger = Bagger.new(nil,nil,bag_dir)
      bagger.should_receive(:shell_execute).with("cd '#{@packages}'; tar --dereference --force-local -cf  '#{@temp}/test.tar' 'v0001'")
      lambda{bagger.create_tarfile(tarfile)}.should raise_exception(/Unable to create tarfile/)
    end
  
  end

end
