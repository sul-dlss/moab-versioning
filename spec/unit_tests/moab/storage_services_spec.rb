require 'spec_helper'

# Unit tests for class {Moab::StorageServices}
describe 'Moab::StorageServices' do
  
  describe '=========================== CLASS METHODS ===========================' do

    before (:all) do
      @digital_object_id = @obj
      @version_id = 2
      @content_metadata = IO.read(@data.join('v0002/metadata/contentMetadata.xml'))
    end

    specify 'Moab::StorageServices.object_path' do
      Moab::StorageServices.object_path(@digital_object_id).should match('spec/fixtures/derivatives/ingests/jq937jp0017')
    end

    specify 'Moab::StorageServices.object_version_path' do
      Moab::StorageServices.object_version_path(@digital_object_id,1).should match('spec/fixtures/derivatives/ingests/jq937jp0017/v0001')
    end

    # Unit test for method: {Moab::StorageServices.current_version}
    # Which returns: [Integer] The version number of the currently highest version
    # For input parameters:
    # * object_id [String] = The digital object identifier
    specify 'Moab::StorageServices.current_version' do
      Moab::StorageServices.current_version(@digital_object_id).should == 3

      # def self.current_version(object_id)
      #   @@repository.storage_object(object_id).current_version_id
      # end
    end

    # Unit test for method: {Moab::StorageServices.version_metadata}
    # Which returns: [Pathname] Pathname object containing the full path for the specified file
    # For input parameters:
    # * object_id [String] = The digital object identifier of the object
    specify 'Moab::StorageServices.version_metadata' do
      Moab::StorageServices.version_metadata(@digital_object_id).read.should be_equivalent_to(<<-EOF
          <versionMetadata objectId="druid:jq937jp0017">
            <version versionId="1" label="1.0" significance="major">
              <description>Initial version</description>
            </version>
            <version versionId="2" label="2.0" significance="minor">
              <description>Editing page-1 and removing intro files</description>
              <note>content change</note>
            </version>
            <version versionId="3" label="2.1" significance="minor">
              <description>Inserting new page-2, with renames of pages 2-3 to 3-4</description>
              <note>page insertion</note>
            </version>
          </versionMetadata>
        EOF
        )

      # def self.version_metadata(object_id)
      #   self.retrieve_file('metadata', 'versionMetadata.xml', object_id)
      # end
    end

    # Unit test for method: {Moab::StorageServices.retrieve_file_group}
    # Which returns: [FileInventory] the file inventory for the specified object version
    # For input parameters:
    # * object_id [String] = The digital object identifier of the object
    # * version_id [Integer] = The ID of the version, if nil use latest version
    specify 'Moab::StorageServices.retrieve_file_group' do
      group = Moab::StorageServices.retrieve_file_group('content', @digital_object_id, version_id=2)
      group.group_id.should == 'content'
      group = Moab::StorageServices.retrieve_file_group('metadata', @digital_object_id, version_id=2)
      group.group_id.should == 'metadata'
      group = Moab::StorageServices.retrieve_file_group('manifest', @digital_object_id, version_id=2)
      group.group_id.should == 'manifests'

      # def self.retrieve_file_group(file_category, object_id, version_id=nil)
      #   storage_object_version = @@repository.storage_object(object_id).find_object_version(version_id)
      #   if file_category =~ /manifest/
      #     inventory_type = file_category = 'manifests'
      #   else
      #     inventory_type = 'version'
      #   end
      #   inventory = storage_object_version.file_inventory(inventory_type)
      #   inventory.group(file_category)
      # end
    end

    # Unit test for method: {Moab::StorageServices.retrieve_file}
    # Which returns: [Pathname] Pathname object containing the full path for the specified file
    # For input parameters:
    # * file_category [String] = The category of file ('content', 'metdata', or 'manifest')
    # * file_id [String] = The name of the file (path relative to base directory)
    # * object_id [String] = The digital object identifier of the object
    # * version_id [Integer] = The ID of the version, if nil use latest version
    specify 'Moab::StorageServices.retrieve_file' do
      content_pathname = Moab::StorageServices.retrieve_file('content', 'page-1.jpg', @digital_object_id, version_id=2)
      content_pathname.to_s.should =~ /spec\/fixtures\/derivatives\/ingests\/jq937jp0017\/v0002\/data\/content\/page-1.jpg/
      content_pathname.exist?.should == true
      metadata_pathname = Moab::StorageServices.retrieve_file('metadata', 'contentMetadata.xml', @digital_object_id, version_id=2)
      metadata_pathname.to_s.should =~ /spec\/fixtures\/derivatives\/ingests\/jq937jp0017\/v0002\/data\/metadata\/contentMetadata.xml/
      metadata_pathname.exist?.should == true
      manifest_pathname = Moab::StorageServices.retrieve_file('manifest', 'versionAdditions.xml', @digital_object_id, version_id=2)
      manifest_pathname.to_s.should =~ /spec\/fixtures\/derivatives\/ingests\/jq937jp0017\/v0002\/manifests\/versionAdditions.xml/
      manifest_pathname.exist?.should == true

      # def self.retrieve_file(file_category, file_id, object_id, version_id=nil)
      #   storage_object_version = @@repository.storage_object(object_id).find_object_version(version_id)
      #   file_pathname = storage_object_version.find_filepath(file_category, file_id)
      # end
    end

    # Unit test for method: {Moab::StorageServices.retrieve_file_using_signature}
    # Which returns: [Pathname] Pathname object containing the full path for the specified file
    # For input parameters:
    # * file_category [String] = The category of file ('content', 'metdata', or 'manifest')
    # * file_signature [FileSignature] = The signature of the file
    # * object_id [String] = The digital object identifier of the object
    # * version_id [Integer] = The ID of the version, if nil use latest version
    specify 'Moab::StorageServices.retrieve_file_using_signature' do
      file_category = 'content'
      file_signature = FileSignature.new(:size=>"40873",:md5=>"1a726cd7963bd6d3ceb10a8c353ec166",:sha1=>"583220e0572640abcd3ddd97393d224e8053a6ad")
      object_id = @digital_object_id
      version_id = 2
      filepath = Moab::StorageServices.retrieve_file_using_signature(file_category, file_signature, object_id, version_id)
      filepath.to_s.should =~ %r{moab-versioning/spec/fixtures/derivatives/ingests/jq937jp0017/v0001/data/content/title.jpg}

      # def self.retrieve_file_using_signature(file_category, file_signature, object_id, version_id=nil)
      #   storage_object_version = @@repository.storage_object(object_id).find_object_version(version_id)
      #   file_pathname = storage_object_version.find_filepath_using_signature(file_category, file_signature)
      # end
    end

    # Unit test for method: {Moab::StorageServices.retrieve_file_signature}
    # Which returns: [FileSignature] The signature of the file
    # For input parameters:
    # * file_category [String] = The category of file ('content', 'metdata', or 'manifest')
    # * file_id [String] = The name of the file (path relative to base directory)
    # * object_id [String] = The digital object identifier of the object
    # * version_id [Integer] = The ID of the version, if nil use latest version
    specify 'Moab::StorageServices.retrieve_file_signature' do
      content_signature = Moab::StorageServices.retrieve_file_signature('content', 'page-1.jpg', @digital_object_id, version_id=2)
      content_signature.fixity.should == {:size=>"32915", :md5=>"c1c34634e2f18a354cd3e3e1574c3194", :sha1=>"0616a0bd7927328c364b2ea0b4a79c507ce915ed", :sha256=>"b78cc53b7b8d9ed86d5e3bab3b699c7ed0db958d4a111e56b6936c8397137de0"}
      metadata_signature = Moab::StorageServices.retrieve_file_signature('metadata', 'contentMetadata.xml', @digital_object_id, version_id=2)
      metadata_signature.fixity.should == {:size=>"1303", :md5=>"8672613ac1757cda4e44cc464559cd04", :sha1=>"c3961c0f619a81eaf8779a122219b1f860dbc2f9", :sha256=>"02b3bb1d059a705cb693bb2fe2550a8090b47cd3c32e823891b2071156485b73"}
      manifest_signature = Moab::StorageServices.retrieve_file_signature('manifest', 'versionAdditions.xml', @digital_object_id, version_id=2)
      manifest_signature.size.should == 1631

      # def self.retrieve_file_signature(file_category, file_id, object_id, version_id=nil)
      #   storage_object_version = @@repository.storage_object(object_id).find_object_version(version_id)
      #   file_pathname = storage_object_version.find_signature(file_category, file_id)
      # end
    end

    # Unit test for method: {Moab::StorageServices.version_differences}
    # Which returns: [FileInventoryDifference] The report of the version differences
    # For input parameters:
    # * object_id [String] = The digital object identifier of the object
    # * base_version_id [Object] = The identifier of the base version to be compared
    # * compare_version_id [Object] = The identifier of the version to be compared to the base version
    specify 'Moab::StorageServices.version_differences' do
      differences=Moab::StorageServices.version_differences(@digital_object_id,2,3)
      differences.to_xml.gsub(/reportDatetime=".*?"/,'').should be_equivalent_to(<<-EOF
        <fileInventoryDifference objectId="druid:jq937jp0017" differenceCount="6" basis="v2" other="v3" >
          <fileGroupDifference groupId="content" differenceCount="3" identical="2" renamed="2" modified="0" deleted="0" added="1">
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
            <subset change="modified" count="0"/>
            <subset change="deleted" count="0"/>
            <subset change="added" count="1">
              <file change="added" basisPath="" otherPath="page-2.jpg">
                <fileSignature size="39539" md5="fe6e3ffa1b02ced189db640f68da0cc2" sha1="43ced73681687bc8e6f483618f0dcff7665e0ba7" sha256="42c0cd1fe06615d8fdb8c2e3400d6fe38461310b4ecc252e1774e0c9e3981afa"/>
              </file>
            </subset>
          </fileGroupDifference>
          <fileGroupDifference groupId="metadata" differenceCount="3" identical="2" renamed="0" modified="3" deleted="0" added="0">
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
            <subset change="deleted" count="0"/>
            <subset change="added" count="0"/>
          </fileGroupDifference>
        </fileInventoryDifference>
        EOF
        )
    end

  end

end
