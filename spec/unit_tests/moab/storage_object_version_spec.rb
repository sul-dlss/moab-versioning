require 'spec_helper'

# Unit tests for class {Moab::StorageObjectVersion}
describe 'Moab::StorageObjectVersion' do

  describe '=========================== CONSTRUCTOR ===========================' do

    before(:all) do
      @temp_ingests = @temp.join("ingests")
      @temp_object_dir = @temp_ingests.join(@obj)      
    end
    
    after(:all) do
      @temp_ingests.rmtree if @temp_ingests.exist?
    end

    # Unit test for constructor: {Moab::StorageObjectVersion#initialize}
    # Which returns an instance of: [Moab::StorageObjectVersion]
    # For input parameters:
    # * storage_object [StorageObject] = The object representing the digital object's storage location 
    # * version_id [Integer] = The ordinal version number
    specify 'Moab::StorageObjectVersion#initialize' do

      # test initialization with required parameters (if any)
      storage_object = StorageObject.new(@obj, @temp_object_dir)
      version_id = 2
      storage_object_version = StorageObjectVersion.new(storage_object, version_id)
      storage_object_version.should be_instance_of(StorageObjectVersion)
      storage_object_version.storage_object.should == storage_object
      storage_object_version.version_id.should == version_id

      # def initialize(storage_object, version_id)
      #   @version_id = version_id
      #   @version_name = StorageObject.version_dirname(version_id)
      #   @version_pathname = storage_object.object_pathname.join(@version_name)
      #   @storage_object=storage_object
      # end
    end

  end

  describe '=========================== INSTANCE ATTRIBUTES ===========================' do

    before(:all) do
      storage_object = StorageObject.new(@obj, @ingests.join(@obj))
      version_id = 2
      @storage_object_version = StorageObjectVersion.new(storage_object, version_id)
    end

    # Unit test for attribute: {Moab::StorageObjectVersion#version_id}
    # Which stores: [Integer] The ordinal version number
    specify 'Moab::StorageObjectVersion#version_id' do
      value = 84
      @storage_object_version.version_id= value
      @storage_object_version.version_id.should == value

      # def version_id=(value)
      #   @version_id = value
      # end

      # def version_id
      #   @version_id
      # end
    end

    # Unit test for attribute: {Moab::StorageObjectVersion#version_name}
    # Which stores: [String] The "v0001" directory name derived from the version id
    specify 'Moab::StorageObjectVersion#version_name' do
      value = 'Test version_name'
      @storage_object_version.version_name= value
      @storage_object_version.version_name.should == value

      # def version_name=(value)
      #   @version_name = value
      # end

      # def version_name
      #   @version_name
      # end
    end

    # Unit test for attribute: {Moab::StorageObjectVersion#version_pathname}
    # Which stores: [Pathname] The location of the version inside the home directory
    specify 'Moab::StorageObjectVersion#version_pathname' do
      value = @temp.join('version_pathname')
      @storage_object_version.version_pathname= value
      @storage_object_version.version_pathname.should == value

      # def version_pathname=(value)
      #   @version_pathname = value
      # end

      # def version_pathname
      #   @version_pathname
      # end
    end

    # Unit test for attribute: {Moab::StorageObjectVersion#storage_object}
    # Which stores: [Pathname] The location of the object's home directory
    specify 'Moab::StorageObjectVersion#storage_object' do
      value = @temp.join('storage_object')
      @storage_object_version.storage_object= value
      @storage_object_version.storage_object.should == value

      # def storage_object=(value)
      #   @storage_object = value
      # end

      # def storage_object
      #   @storage_object
      # end
    end

  end

  describe '=========================== INSTANCE METHODS ===========================' do

    before(:all) do
      @existing_object_pathname = @ingests.join(@obj)
      @existing_storage_object = StorageObject.new(@obj, @existing_object_pathname)
      @existing_storage_object_version = StorageObjectVersion.new(@existing_storage_object, version_id=2)
      @temp_ingests = @temp.join("ingests")
      @temp_object_dir = @temp_ingests.join(@obj)
      @temp_storage_object = StorageObject.new(@obj, @temp_object_dir)
      @temp_package_pathname = @temp.join("packages")
    end

    before(:each) do
      @temp_object_dir.rmtree if @temp_object_dir.exist?
    end

    after(:all) do
      @temp_ingests.rmtree if @temp_ingests.exist?
    end

    # Unit test for method: {Moab::StorageObjectVersion#find_signature}
    # Which returns: [FileSignature] signature of the specified file
    # For input parameters:
    # * file_category [String] = The category of file ('content', 'metadata', or 'manifest'))
    # * file_id [String] = The name of the file (path relative to base directory)
    specify 'Moab::StorageObjectVersion#find_signature' do
      signature = @existing_storage_object_version.find_signature('content', 'title.jpg')
      signature.fixity.should == {:size=>"40873", :md5=>"1a726cd7963bd6d3ceb10a8c353ec166", :sha1=>"583220e0572640abcd3ddd97393d224e8053a6ad", :sha256=>"8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5"}
      signature = @existing_storage_object_version.find_signature('content', 'page-1.jpg')
      signature.fixity.should == {:size=>"32915", :md5=>"c1c34634e2f18a354cd3e3e1574c3194", :sha1=>"0616a0bd7927328c364b2ea0b4a79c507ce915ed", :sha256=>"b78cc53b7b8d9ed86d5e3bab3b699c7ed0db958d4a111e56b6936c8397137de0"}
      signature = @existing_storage_object_version.find_signature('manifest', 'versionInventory.xml')
      signature.size.should == 3278

      lambda{@existing_storage_object_version.find_signature('manifest', 'dummy.xml')}.should raise_exception

      # def find_signature(file_category, file_id)
      #   case file_category
      #     when 'manifest'
      #       file_inventory('manifests').file_signature('manifests',file_id)
      #     else
      #       file_inventory('version').file_signature(file_category, file_id)
      #   end
      # end
    end

    # Unit test for method: {Moab::StorageObjectVersion#find_filepath}
    # Which returns: [Pathname] Pathname object containing the full path for the specified file
    # For input parameters:
    # * file_category [String] = The category of file ('content', 'metadata', or 'manifest')
    # * file_id [String] = The name of the file (path relative to base directory)
    specify 'Moab::StorageObjectVersion#find_filepath' do
      pathname = @existing_storage_object_version.find_filepath('content', 'title.jpg')
      pathname.to_s.include?('ingests/jq937jp0017/v0001/data/content/title.jpg').should == true
      pathname = @existing_storage_object_version.find_filepath('content', 'page-1.jpg')
      pathname.to_s.include?('ingests/jq937jp0017/v0002/data/content/page-1.jpg').should == true
      pathname = @existing_storage_object_version.find_filepath('manifest', 'versionInventory.xml')
      pathname.to_s.include?('ingests/jq937jp0017/v0002/manifests/versionInventory.xml').should == true
      lambda{@existing_storage_object_version.find_filepath('manifest', 'dummy.xml')}.should raise_exception

      # def find_filepath(file_category, file_id)
      #   this_version_filepath = file_pathname(file_category, file_id)
      #   return this_version_filepath if this_version_filepath.exist?
      #   raise "manifest file #{file_id} not found for #{@storage_object.digital_object_id} - #{@version_id}" if file_category == 'manifest'
      #   file_signature = file_inventory('version').file_signature(file_category, file_id)
      #   catalog_filepath = signature_catalog.catalog_filepath(file_signature)
      #   @storage_object.storage_filepath(catalog_filepath)
      # end
    end

    # Unit test for method: {Moab::StorageObjectVersion#find_filepath_using_signature}
    # Which returns: [Pathname] Pathname object containing the full path for the specified file
    # For input parameters:
    # * file_category [String] = The category of file ('content', 'metadata', or 'manifest')
    # * file_signature [FileSignature] = The signature of the file
    specify 'Moab::StorageObjectVersion#find_filepath_using_signature' do
      file_category = 'content'
      file_signature = FileSignature.new(:size=>40873,:md5=>"1a726cd7963bd6d3ceb10a8c353ec166",:sha1=>"583220e0572640abcd3ddd97393d224e8053a6ad")
      @existing_storage_object_version.find_filepath_using_signature(file_category, file_signature).
          to_s.should =~ %r{moab-versioning/spec/fixtures/derivatives/ingests/jq937jp0017/v0001/data/content/title.jpg}

      # def find_filepath_using_signature(file_category, file_signature)
      #   catalog_filepath = signature_catalog.catalog_filepath(file_signature)
      #   @storage_object.storage_filepath(catalog_filepath)
      # end
    end

    # Unit test for method: {Moab::StorageObjectVersion#file_pathname}
    # Which returns: [Pathname] Pathname object containing this version's storage path for the specified file
    # For input parameters:
    # * file_category [String] = The category of file ('content', 'metadata', or 's')
    # * file_id [String] = The name of the file (path relative to base directory)
    specify 'Moab::StorageObjectVersion#file_pathname' do
      pathname = @existing_storage_object_version.file_pathname('content','title.jpg')
      pathname.to_s.include?('ingests/jq937jp0017/v0002/data/content/title.jpg').should == true
      pathname = @existing_storage_object_version.file_pathname('metadata','descMetadata.xml')
      pathname.to_s.include?('ingests/jq937jp0017/v0002/data/metadata/descMetadata.xml').should == true
      pathname= @existing_storage_object_version.file_pathname('manifest','signatureCatalog.xml')
      pathname.to_s.include?('ingests/jq937jp0017/v0002/manifests/signatureCatalog.xml').should == true

      # def file_pathname(file_category, file_id)
      #   case file_category
      #     when 'manifest'
      #       @version_pathname.join(file_id)
      #     else
      #       @version_pathname.join('data',file_category, file_id)
      #   end
      # end
    end

    # Unit test for method: {Moab::StorageObjectVersion#file_category_pathname}
    # Which returns: [Pathname] Pathname object containing this version's storage home for the specified file category
    # For input parameters:
    # * file_category [String] = The category of file ('content', 'metadata', or 's')
    specify 'Moab::StorageObjectVersion#file_category_pathname' do
      file_category = 'content'
      @existing_storage_object_version.file_category_pathname(file_category).
        to_s.should =~ %r{moab-versioning/spec/fixtures/derivatives/ingests/jq937jp0017/v0002/data/content}
      file_category = 'metadata'
      @existing_storage_object_version.file_category_pathname(file_category).
        to_s.should =~ %r{moab-versioning/spec/fixtures/derivatives/ingests/jq937jp0017/v0002/data/metadata}
      file_category = 'manifests'
      @existing_storage_object_version.file_category_pathname(file_category).
        to_s.should =~ %r{moab-versioning/spec/fixtures/derivatives/ingests/jq937jp0017/v0002}

      # def file_category_pathname(file_category)
      #   case file_category
      #     when 'manifest'
      #       @version_pathname
      #     else
      #       @version_pathname.join('data',file_category)
      #   end
      # end
    end

    # Unit test for method: {Moab::StorageObjectVersion#file_inventory}
    # Which returns: [FileInventory] The file inventory of the specified type for this version
    # For input parameters:
    # * type [String] = The type of inventory to return (version|additions|manifests)
    specify 'Moab::StorageObjectVersion#file_inventory' do
      type = 'version'
      @existing_storage_object_version.file_inventory(type).should be_an_instance_of(FileInventory)

      # def file_inventory(type)
      #   if version_id > 0
      #   FileInventory.read_xml_file(@version_pathname, type)
      #   else
      #     groups = ['content','metadata'].collect { |id| FileGroup.new(:group_id=>id)}
      #     FileInventory.new(
      #         :type=>'version',
      #         :digital_object_id => @storage_object.digital_object_id,
      #         :version_id => @version_id,
      #         :groups => groups
      #     )
      #   end
      # end
    end

    # Unit test for method: {Moab::StorageObjectVersion#signature_catalog}
    # Which returns: [SignatureCatalog] The signature catalog of the digital object as of this version
    # For input parameters: (None)
    specify 'Moab::StorageObjectVersion#signature_catalog' do
      @existing_storage_object_version.signature_catalog().should be_instance_of(SignatureCatalog)

      # def signature_catalog
      #   if version_id > 0
      #     SignatureCatalog.read_xml_file(@version_pathname)
      #   else
      #     SignatureCatalog.new(:digital_object_id => @storage_object.digital_object_id)
      #   end
      # end
    end

    # Unit test for method: {Moab::StorageObjectVersion#ingest_bag_data}
    # Which returns: [void] Create the version subdirectory and move files into it
    # For input parameters:
    # * bag_dir [Pathname, String] = The location of the bag to be ingested
    specify 'Moab::StorageObjectVersion#ingest_bag_data' do
      version_id = 1
      temp_storage_object_version = StorageObjectVersion.new(@temp_storage_object, version_id)
      bag_dir = @packages.join("v0001")
      temp_storage_object_version.ingest_bag_data(bag_dir)
      files = Array.new
      @temp_object_dir.find { |f| files << f.relative_path_from(@temp).to_s }
      files.sort.should == [
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
          "ingests/jq937jp0017/v0001/manifests/versionAdditions.xml",
          "ingests/jq937jp0017/v0001/manifests/versionInventory.xml"
      ]

      # def ingest_bag_data(bag_dir)
      #   raise "Version already exists: #{@version_pathname.to_s}" if @version_pathname.exist?
      #   @version_pathname.mkpath
      #   bag_dir=Pathname(bag_dir)
      #   ingest_dir(bag_dir.join('data'),@version_pathname.join('data'))
      #   ingest_file(bag_dir.join(FileInventory.xml_filename('version')),@version_pathname)
      #   ingest_file(bag_dir.join(FileInventory.xml_filename('additions')),@version_pathname)
      # end
    end

    # Unit test for method: {Moab::StorageObjectVersion#ingest_dir}
    # Which returns: [void] recursively link or copy the source directory contents to the target directory
    # For input parameters:
    # * source_dir [Pathname] = The source location of the directory whose contents are to be ingested
    # * target_dir [Pathname] = The target location of the directory into which files are ingested
    # * use_links [Boolean] = If true, use hard links; if false, make copies
    specify 'Moab::StorageObjectVersion#ingest_dir' do
      source_dir = @packages.join("v0001/data")
      temp_storage_object_version = StorageObjectVersion.new(@temp_storage_object, 1)
      target_dir = temp_storage_object_version.version_pathname.join('data')
      use_links = true
      temp_storage_object_version.ingest_dir(source_dir, target_dir, use_links)
      files = Array.new
      @temp_object_dir.find { |f| files << f.relative_path_from(@temp).to_s }
      files.sort.should == [
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
      ]

      # def ingest_dir(source_dir, target_dir, use_links=true)
      #   raise "cannot copy - target already exists: #{target_dir.realpath}" if target_dir.exist?
      #   target_dir.mkpath
      #   source_dir.children.each do |child|
      #     if child.directory?
      #       ingest_dir(child, target_dir.join(child.basename), use_links)
      #     else
      #       ingest_file(child, target_dir, use_links)
      #     end
      #   end
      # end
    end

    # Unit test for method: {Moab::StorageObjectVersion#ingest_file}
    # Which returns: [void] link or copy the specified file from source location to the version directory
    # For input parameters:
    # * source_file [Pathname] = The source location of the file to be ingested
    # * target_dir [Pathname] = The location of the directory in which to place the file
    # * use_links [Boolean] = If true, use hard links; if false, make copies
    specify 'Moab::StorageObjectVersion#ingest_file' do
      version_id = 2
      temp_storage_object_version = StorageObjectVersion.new(@temp_storage_object, version_id)
      temp_version_pathname = temp_storage_object_version.version_pathname
      temp_version_pathname.mkpath
      source_file = @packages.join("v0002").join( 'versionInventory.xml')
      temp_storage_object_version.ingest_file(source_file, temp_version_pathname)
      files = Array.new
      @temp_object_dir.find { |f| files << f.relative_path_from(@temp).to_s }
      files.sort.should == [
          "ingests/jq937jp0017",
          "ingests/jq937jp0017/v0002",
          "ingests/jq937jp0017/v0002/versionInventory.xml"
      ]
      source_file = @packages.join("v0002").join( 'versionAdditions.xml')
      temp_storage_object_version.ingest_file(source_file, temp_version_pathname, use_links=false)
      files = Array.new
      @temp_object_dir.find { |f| files << f.relative_path_from(@temp).to_s }
      files.sort.should == [
          "ingests/jq937jp0017",
          "ingests/jq937jp0017/v0002",
          "ingests/jq937jp0017/v0002/versionAdditions.xml",
          "ingests/jq937jp0017/v0002/versionInventory.xml"
      ]

      # def ingest_file(source_file, target_dir, use_links=true)
      #   if use_links
      #     FileUtils.link(source_file.to_s, target_dir.to_s) #, :force => true)
      #   else
      #     FileUtils.copy(source_file.to_s, target_dir.to_s)
      #   end
      # end
    end

    # Unit test for method: {Moab::StorageObjectVersion#update_catalog}
    # Which returns: [void] Updates the catalog to include newly added files, then saves it to disk
    # For input parameters:
    # * signature_catalog [SignatureCatalog] = The current version's catalog
    # * new_inventory [FileInventory] = The new version's inventory
    specify 'Moab::StorageObjectVersion#update_catalog' do
      temp_storage_object_version = StorageObjectVersion.new(@temp_storage_object, 4)
      signature_catalog = mock(SignatureCatalog.name)
      new_inventory = mock(FileInventory.name)
      signature_catalog.should_receive(:update).with(new_inventory,temp_storage_object_version.version_pathname.join('data'))
      signature_catalog.should_receive(:write_xml_file).with(temp_storage_object_version.version_pathname.join('manifests'))
      temp_storage_object_version.update_catalog(signature_catalog, new_inventory)

      # def update_catalog(signature_catalog,new_inventory)
      #   signature_catalog.update(new_inventory)
      #   signature_catalog.write_xml_file(@version_pathname)
      # end
    end

    # Unit test for method: {Moab::StorageObjectVersion#generate_differences_report}
    # Which returns: [void] generate a file inventory differences report and save to disk
    # For input parameters:
    # * old_inventory [FileInventory] = The old version's inventory
    # * new_inventory [FileInventory] = The new version's inventory
    specify 'Moab::StorageObjectVersion#generate_differences_report' do
      old_inventory = mock(FileInventory.name)
      new_inventory = mock(FileInventory.name)
      mock_fid = mock(FileInventoryDifference.name)
      FileInventoryDifference.should_receive(:new).and_return(mock_fid)
      mock_fid.should_receive(:compare).with(old_inventory, new_inventory).and_return(mock_fid)
      mock_fid.should_receive(:write_xml_file)
      @existing_storage_object_version.generate_differences_report(old_inventory, new_inventory)

      # def generate_differences_report(old_inventory,new_inventory)
      #   differences = FileInventoryDifference.new.compare(old_inventory, new_inventory)
      #   differences.write_xml_file(@version_pathname)
      # end
    end

    # Unit test for method: {Moab::StorageObjectVersion#generate_manifest_inventory}
    # Which returns: [void] examine the version's directory and create/serialize a {FileInventory} containing the manifest files
    # For input parameters: (None)
    specify 'Moab::StorageObjectVersion#generate_manifest_inventory' do
      version_id = 2
      temp_storage_object_version = StorageObjectVersion.new(@temp_storage_object, version_id)
      temp_version_pathname = temp_storage_object_version.version_pathname
      temp_version_pathname.mkpath
      source_file = @packages.join("v0002").join( 'versionInventory.xml')
      temp_storage_object_version.ingest_file(source_file, temp_version_pathname)
      source_file = @packages.join("v0002").join( 'versionAdditions.xml')
      temp_storage_object_version.ingest_file(source_file, temp_version_pathname)
      temp_storage_object_version.generate_manifest_inventory()
      FileInventory.xml_pathname_exist?(temp_version_pathname.join('manifests'),'manifests').should == true

      # def generate_manifest_inventory
      #   manifest_inventory = FileInventory.new(
      #       :type=>'manifests',
      #       :digital_object_id=>@storage_object.digital_object_id,
      #       :version_id=>@version_id)
      #   manifest_inventory.groups << FileGroup.new(:group_id=>'manifests').group_from_directory(@version_pathname, recursive=false)
      #   manifest_inventory.write_xml_file(@version_pathname)
      # end
    end

    specify 'Moab::StorageObjectVersion#verify_storage' do
      version = @existing_storage_object_version
      version.verify_storage.should == true
    end

    specify 'Moab::StorageObjectVersion#verify_manifest_inventory' do
      version = @existing_storage_object_version
      version.verify_manifest_inventory.should == true
    end

    specify 'Moab::StorageObjectVersion#verify_version_inventory' do
      version = @existing_storage_object_version
      version.verify_version_inventory.should == true
    end

    specify 'Moab::StorageObjectVersion#verify_version_additions' do
      version = @existing_storage_object_version
      version.verify_version_additions.should == true
    end

  end

end




