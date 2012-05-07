require 'spec_helper'

# Unit tests for class {Moab::Bagger}
describe 'Moab::Bagger' do
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Moab::Bagger#initialize}
    # Which returns an instance of: [Moab::Bagger]
    # For input parameters:
    # * version_inventory [FileInventory] = The complete inventory of the files comprising a digital object version 
    # * signature_catalog [SignatureCatalog] = The signature catalog, used to specify source paths (in :reconstructor mode), or to filter the version inventory (in :depositor mode) 
    # * source_base_pathname [Pathname, String] = The home location of the source files 
    # * bag_pathname [Pathname, String] = The location of the Bagit bag to be created 
    specify 'Moab::Bagger#initialize' do
       
      # test initialization with required parameters (if any)
      version_inventory = mock(FileInventory.name) 
      signature_catalog = mock(SignatureCatalog.name) 
      source_base_pathname = @data.join('v2')
      bag_pathname = @temp.join('bag_pathname')
      bagger = Bagger.new(version_inventory, signature_catalog, source_base_pathname, bag_pathname)
      bagger.should be_instance_of(Bagger)
      bagger.version_inventory.should == version_inventory
      bagger.signature_catalog.should == signature_catalog
      bagger.source_base_pathname.should == source_base_pathname.realpath
      bagger.bag_pathname.should == bag_pathname
       
      # def initialize(version_inventory, signature_catalog, source_base_pathname, bag_pathname)
      #   @version_inventory = version_inventory
      #   @signature_catalog = signature_catalog
      #   @source_base_pathname = Pathname.new(source_base_pathname).realpath
      #   @bag_pathname = Pathname.new(bag_pathname)
      # end
    end
  
  end
  
  describe '=========================== INSTANCE ATTRIBUTES ===========================' do

    
    before(:all) do
      @inventory = FileInventory.read_xml_file(@manifests.join('v2'),'version')
      @catalog = SignatureCatalog.read_xml_file(@manifests.join('v1'))
      @source_base = @data.join('v2')
      @bag_pathname = @temp.join('bag_pathname')
      @bagger = Bagger.new(@inventory, @catalog, @source_base, @bag_pathname)
    end
    
    # Unit test for attribute: {Moab::Bagger#version_inventory}
    # Which stores: [FileInventory] The complete inventory of the files comprising a digital object version
    specify 'Moab::Bagger#version_inventory' do
      value = mock(FileInventory.name)
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
      value = mock(SignatureCatalog.name)
      @bagger.signature_catalog= value
      @bagger.signature_catalog.should == value
       
      # def signature_catalog=(value)
      #   @signature_catalog = value
      # end
       
      # def signature_catalog
      #   @signature_catalog
      # end
    end
    
    # Unit test for attribute: {Moab::Bagger#source_base_pathname}
    # Which stores: [Pathname] The home location of the source files
    specify 'Moab::Bagger#source_base_pathname' do
      value = @temp.join('source_base_pathname')
      @bagger.source_base_pathname= value
      @bagger.source_base_pathname.should == value
       
      # def source_base_pathname=(value)
      #   @source_base_pathname = value
      # end
       
      # def source_base_pathname
      #   @source_base_pathname
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
      value = mock(FileInventory.name)
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
      @submit_source_base = @data.join('v2')
      @submit_inventory = FileInventory.read_xml_file(@manifests.join('v2'),'version')
      @submit_catalog = SignatureCatalog.read_xml_file(@manifests.join('v1'))
      @submit_bag_inventory = @submit_catalog.version_additions(@submit_inventory)
      @submit_bag_pathname = @temp.join('submit_bag_pathname')

      @disseminate_base = @ingests.join(@obj)
      @disseminate_inventory = FileInventory.read_xml_file(@disseminate_base.join('v0002'),'version')
      @disseminate_catalog = SignatureCatalog.read_xml_file(@disseminate_base.join('v0002'))
      @disseminate_bag_inventory = @disseminate_inventory
      @disseminate_bag_pathname = @temp.join('disseminate_bag_pathname')

    end

    before(:each) do
      @submit_bag_pathname.rmtree if @submit_bag_pathname.exist?
      @submit_bag_pathname.mkpath
      @submit_bag = Bagger.new(@submit_inventory, @submit_catalog, @submit_source_base, @submit_bag_pathname)
      @submit_bag.package_mode = :depositor
      @submit_bag.bag_inventory = @submit_bag_inventory

      @disseminate_bag_pathname.rmtree if @disseminate_bag_pathname.exist?
      @disseminate_bag_pathname.mkpath
      @disseminate_bag = Bagger.new(@disseminate_inventory, @disseminate_catalog, @disseminate_base, @disseminate_bag_pathname)
      @disseminate_bag.package_mode = :reconstructor
      @disseminate_bag.bag_inventory = @disseminate_bag_inventory
    end

    after(:all) do
      @submit_bag_pathname.rmtree if @submit_bag_pathname.exist?
      @disseminate_bag_pathname.rmtree if @disseminate_bag_pathname.exist?
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
          Bagger.new(inventory,catalog,data_dir,package).fill_bag(:depositor)
        end
      end

      files = Array.new
      packages_dir.find { |f| files << f.relative_path_from(@temp).to_s }
      files.sort.should == [
          "packages",
          "packages/v1",
          "packages/v1/bag-info.txt",
          "packages/v1/bagit.txt",
          "packages/v1/data",
          "packages/v1/data/content",
          "packages/v1/data/content/intro-1.jpg",
          "packages/v1/data/content/intro-2.jpg",
          "packages/v1/data/content/page-1.jpg",
          "packages/v1/data/content/page-2.jpg",
          "packages/v1/data/content/page-3.jpg",
          "packages/v1/data/content/title.jpg",
          "packages/v1/data/metadata",
          "packages/v1/data/metadata/contentMetadata.xml",
          "packages/v1/data/metadata/descMetadata.xml",
          "packages/v1/data/metadata/identityMetadata.xml",
          "packages/v1/data/metadata/provenanceMetadata.xml",
          "packages/v1/data/metadata/versionMetadata.xml",
          "packages/v1/manifest-md5.txt",
          "packages/v1/manifest-sha1.txt",
          "packages/v1/tagmanifest-md5.txt",
          "packages/v1/tagmanifest-sha1.txt",
          "packages/v1/versionAdditions.xml",
          "packages/v1/versionInventory.xml",
          "packages/v2",
          "packages/v2/bag-info.txt",
          "packages/v2/bagit.txt",
          "packages/v2/data",
          "packages/v2/data/content",
          "packages/v2/data/content/page-1.jpg",
          "packages/v2/data/metadata",
          "packages/v2/data/metadata/contentMetadata.xml",
          "packages/v2/data/metadata/provenanceMetadata.xml",
          "packages/v2/data/metadata/versionMetadata.xml",
          "packages/v2/manifest-md5.txt",
          "packages/v2/manifest-sha1.txt",
          "packages/v2/tagmanifest-md5.txt",
          "packages/v2/tagmanifest-sha1.txt",
          "packages/v2/versionAdditions.xml",
          "packages/v2/versionInventory.xml",
          "packages/v3",
          "packages/v3/bag-info.txt",
          "packages/v3/bagit.txt",
          "packages/v3/data",
          "packages/v3/data/content",
          "packages/v3/data/content/page-2.jpg",
          "packages/v3/data/metadata",
          "packages/v3/data/metadata/contentMetadata.xml",
          "packages/v3/data/metadata/provenanceMetadata.xml",
          "packages/v3/data/metadata/versionMetadata.xml",
          "packages/v3/manifest-md5.txt",
          "packages/v3/manifest-sha1.txt",
          "packages/v3/tagmanifest-md5.txt",
          "packages/v3/tagmanifest-sha1.txt",
          "packages/v3/versionAdditions.xml",
          "packages/v3/versionInventory.xml"
      ]

      packages_dir.rmtree if packages_dir.exist?

      bag = @submit_bag
      bag.should_receive(:write_inventory_file)
      bag.should_receive(:fill_payload)
      bag.should_receive(:create_payload_manifests)
      bag.should_receive(:create_bag_info_txt)
      bag.should_receive(:create_bagit_txt)
      bag.should_receive(:create_tagfile_manifests)
      @submit_catalog.should_receive(:version_additions).with(@submit_inventory)
      bag.fill_bag(:depositor)
      bag.package_mode.should == :depositor

      bag = @disseminate_bag
      bag.should_receive(:write_inventory_file)
      bag.should_receive(:fill_payload)
      bag.should_receive(:create_payload_manifests)
      bag.should_receive(:create_bag_info_txt)
      bag.should_receive(:create_bagit_txt)
      bag.should_receive(:create_tagfile_manifests)
      @submit_catalog.should_not_receive(:version_additions)
      bag.fill_bag(:reconstructor)
      bag.package_mode.should == :reconstructor

      # def fill_bag(package_mode)
      #   @package_mode = package_mode
      #   case package_mode
      #     when :depositor
      #       @bag_inventory = @signature_catalog.version_additions(@version_inventory)
      #     when :reconstructor
      #       @bag_inventory = @version_inventory
      #   end
      #   @bag_pathname.mkpath
      #   write_inventory_file
      #   fill_payload
      #   create_payload_manifests
      #   create_bag_info_txt
      #   create_bagit_txt
      #   create_tagfile_manifests
      #   self
      # end
    end
    
    # Unit test for method: {Moab::Bagger#write_inventory_file}
    # Which returns: [void] Create a copy of version inventory file in the bag's root directory
    # For input parameters: (None)
    specify 'Moab::Bagger#write_inventory_file' do
      bag = @submit_bag
      @submit_inventory.should_receive(:write_xml_file).with(@submit_bag_pathname,'version')
      @submit_bag_inventory.should_receive(:write_xml_file).with(@submit_bag_pathname,'additions')
      bag.write_inventory_file

      bag = @disseminate_bag
      source_inventory_pathname = FileInventory.xml_pathname(@disseminate_base.join('v0002'),'version').realpath
      FileUtils.should_receive(:link).with(source_inventory_pathname.to_s,@disseminate_bag_pathname.to_s)
      bag.write_inventory_file

      # def write_inventory_file
      #   case @package_mode
      #     when :depositor
      #       @version_inventory.write_xml_file(@bag_pathname, 'version')
      #       @bag_inventory.write_xml_file(@bag_pathname, 'additions')
      #     when :reconstructor
      #       version_dirname = StorageObject.version_dirname(@version_inventory.version_id)
      #       source_file=FileInventory.xml_pathname(@source_base_pathname.join(version_dirname), 'version')
      #       FileUtils.link(source_file.to_s, @bag_pathname.to_s)
      #   end
      # end
    end
    
    # Unit test for method: {Moab::Bagger#fill_payload}
    # Which returns: [void] Fill in the bag's data folder with copies of all files to be packaged for delivery.
    # For input parameters: (None)
    specify 'Moab::Bagger#fill_payload' do
      bag = @submit_bag
      bag.fill_payload
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
      bag.fill_payload
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

      # def fill_payload
      #   payload_pathname = @bag_pathname.join('data')
      #   payload_pathname.mkpath
      #   @bag_inventory.groups.each do |group|
      #     group.files.each do |file|
      #       file.instances.each do |instance|
      #         relative_path = File.join(group.group_id, instance.path)
      #         case @package_mode
      #           when :depositor
      #             source = @source_base_pathname.join(relative_path)
      #           when :reconstructor
      #             catalog_entry = @signature_catalog.signature_hash[file.signature]
      #             source = @source_base_pathname.join(catalog_entry.storage_path)
      #         end
      #         target = payload_pathname.join(relative_path)
      #         target.parent.mkpath
      #         target.make_link(source)
      #         target.utime(instance.datetime, instance.datetime)
      #       end
      #     end
      #   end
      #   nil
      # end
    end
    
    # Unit test for method: {Moab::Bagger#create_payload_manifests}
    # Which returns: [void] Using the checksum information from the inventory, create md5 and sha1 manifest files for the payload
    # For input parameters: (None)
    specify 'Moab::Bagger#create_payload_manifests' do
      bag = @submit_bag
      bag.fill_payload
      bag.create_payload_manifests()
      md5 = bag.bag_pathname.join('manifest-md5.txt')
      md5.exist?.should == true
      md5.readlines.sort.should == [
          "351e4c872148e0bc9dc24874c7ef6c08 *metadata/provenanceMetadata.xml\n",
          "8a3b0051d89a90a6db90edb7b76ef63f *metadata/versionMetadata.xml\n",
          "c1c34634e2f18a354cd3e3e1574c3194 *content/page-1.jpg\n",
          "d74bfa778653b6c1b285b2d0c2f07c5b *metadata/contentMetadata.xml\n"
      ]
      sha1 = bag.bag_pathname.join('manifest-sha1.txt')
      sha1.exist?.should == true
      sha1.readlines.sort.should == [
          "0616a0bd7927328c364b2ea0b4a79c507ce915ed *content/page-1.jpg\n",
          "0ee15e133c17ae3312b87247adb310b0327ca3df *metadata/contentMetadata.xml\n",
          "565473bbc865b1c6f88efc99b6b5b73fd5cadbc8 *metadata/provenanceMetadata.xml\n",
          "7e18ec3a00f7e64d561a9c1c2bc2950ef7deea33 *metadata/versionMetadata.xml\n"
      ]

      # def create_payload_manifests
      #   md5 = @bag_pathname.join('manifest-md5.txt').open('w')
      #   sha1 = @bag_pathname.join('manifest-sha1.txt').open('w')
      #   @bag_inventory.groups.each do |group|
      #     group.files.each do |file|
      #       file.instances.each do |instance|
      #         signature = file.signature
      #         relative_path = File.join(group.group_id, instance.path)
      #         md5.puts("#{signature.md5}  #{relative_path}")
      #         sha1.puts("#{signature.sha1}  #{relative_path}")
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
          "Payload-Oxum: 35584.4\n",
          "Bag-Size: 34.75 KB\n"
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
      bag.fill_bag(:depositor)
      md5 = bag.bag_pathname.join('tagmanifest-md5.txt')
      md5.exist?.should == true
      (md5.readlines.collect{ |line| line.split(/[*]/)[1] }).should == [
          "bag-info.txt\n",
          "bagit.txt\n",
          "manifest-md5.txt\n",
          "manifest-sha1.txt\n",
          "versionAdditions.xml\n",
          "versionInventory.xml\n"
      ]

      sha1 = bag.bag_pathname.join('tagmanifest-sha1.txt')
      sha1.exist?.should == true
      (sha1.readlines.collect{ |line| line.split(/[*]/)[1] }).should == [
          "bag-info.txt\n",
          "bagit.txt\n",
          "manifest-md5.txt\n",
          "manifest-sha1.txt\n",
          "versionAdditions.xml\n",
          "versionInventory.xml\n"
      ]
      # def create_tagfile_manifests()
      #   md5 = @bag_pathname.join('tagmanifest-md5.txt').open('w')
      #   sha1 = @bag_pathname.join('tagmanifest-sha1.txt').open('w')
      #   @bag_pathname.children.each do |file|
      #     unless file.directory? || file.basename.to_s[0, 11] == 'tagmanifest'
      #       signature = FileSignature.new.signature_from_file(file.realpath)
      #       md5.puts("#{signature.md5}  #{file.basename}")
      #       sha1.puts("#{signature.sha1}  #{file.basename}")
      #     end
      #   end
      # ensure
      #   md5.close if md5
      #   sha1.close if sha1
      # end
    end
  
  end

end
