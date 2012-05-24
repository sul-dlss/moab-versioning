require 'spec_helper'

# Unit tests for class {Moab::StorageServices}
describe 'Moab::StorageServices' do
  
  describe '=========================== CLASS METHODS ===========================' do

    before (:all) do
      @digital_object_id = @obj
      @version_id = 2
      @content_metadata = IO.read(@data.join('v2/metadata/contentMetadata.xml'))
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
        <?xml version="1.0" encoding="UTF-8"?>
        <versionMetadata objectId="druid:ab123cd4567">
          <version versionId="1" significance="major">
            <reason>Please preserve my digital object</reason>
            <note>Initial object submission</note>
            <event type="submit" datetime="2012-01-01T12:01:01Z"/>
            <event type="accession" datetime="2012-01-12T12:01:12Z"/>
          </version>
          <version versionId="2" significance="minor">
            <reason>Editing page-1 and removing intro files</reason>
            <note>content change</note>
            <fileGroupDifference groupId="content" differenceCount="3" identical="3" renamed="0" modified="1" deleted="2" added="0"/>
            <fileGroupDifference groupId="metadata" differenceCount="3" identical="2" renamed="0" modified="3" deleted="0" added="0"/>
            <event type="reopen" datetime="2012-02-00T12:00:00Z"/>
            <event type="submit" datetime="2012-02-01T12:01:01Z"/>
            <event type="accession" datetime="2012-02-12T12:01:12Z"/>
          </version>
          <version versionId="3" significance="minor">
            <reason>Inserting new page-2, with renames of pages 2-3 to 3-4</reason>
            <note>content change</note>
            <fileGroupDifference groupId="content" differenceCount="3" identical="2" renamed="2" modified="0" deleted="0" added="1"/>
            <fileGroupDifference groupId="metadata" differenceCount="3" identical="2" renamed="0" modified="3" deleted="0" added="0"/>
            <event type="reopen" datetime="2012-02-00T12:00:00Z"/>
            <event type="submit" datetime="2012-02-01T12:01:01Z"/>
            <event type="accession" datetime="2012-02-12T12:01:12Z"/>
          </version>
        </versionMetadata>
        EOF
        )

      # def self.version_metadata(object_id)
      #   self.retrieve_file('metadata', 'versionMetadata.xml', object_id)
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
      manifest_pathname.to_s.should =~ /spec\/fixtures\/derivatives\/ingests\/jq937jp0017\/v0002\/versionAdditions.xml/
      manifest_pathname.exist?.should == true

      # def self.retrieve_file(file_category, file_id, object_id, version_id=nil)
      #   storage_object_version = @@repository.find_object_version(object_id,version_id)
      #   file_pathname = storage_object_version.find_filepath(file_category, file_id)
      # end
    end

    # Unit test for method: {Moab::StorageServices.retrieve_file_signature}
    # Which returns: [Pathname] Pathname object containing the full path for the specified file
    # For input parameters:
    # * file_category [String] = The category of file ('content', 'metdata', or 'manifest')
    # * file_id [String] = The name of the file (path relative to base directory)
    # * object_id [String] = The digital object identifier of the object
    # * version_id [Integer] = The ID of the version, if nil use latest version
    specify 'Moab::StorageServices.retrieve_file_signature' do
      content_signature = Moab::StorageServices.retrieve_file_signature('content', 'page-1.jpg', @digital_object_id, version_id=2)
      content_signature.fixity.should == ["32915", "c1c34634e2f18a354cd3e3e1574c3194", "0616a0bd7927328c364b2ea0b4a79c507ce915ed"]
      metadata_signature = Moab::StorageServices.retrieve_file_signature('metadata', 'contentMetadata.xml', @digital_object_id, version_id=2)
      metadata_signature.fixity.should == ["1135", "d74bfa778653b6c1b285b2d0c2f07c5b", "0ee15e133c17ae3312b87247adb310b0327ca3df"]
      manifest_signature = Moab::StorageServices.retrieve_file_signature('manifest', 'versionAdditions.xml', @digital_object_id, version_id=2)
      manifest_signature.fixity.should == ["1335", "6cf7f4b6e70a5bf7efcd278947064c35", "b0d342e23bcaf929403795e32466ebe7569c6d08"]

      # def self.retrieve_file_signature(file_category, file_id, object_id, version_id=nil)
      #   storage_object_version = @@repository.find_object_version(object_id,version_id)
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
                <fileSignature size="32915" md5="c1c34634e2f18a354cd3e3e1574c3194" sha1="0616a0bd7927328c364b2ea0b4a79c507ce915ed"/>
              </file>
              <file change="identical" basisPath="title.jpg" otherPath="same">
                <fileSignature size="40873" md5="1a726cd7963bd6d3ceb10a8c353ec166" sha1="583220e0572640abcd3ddd97393d224e8053a6ad"/>
              </file>
            </subset>
            <subset change="renamed" count="2">
              <file change="renamed" basisPath="page-2.jpg" otherPath="page-3.jpg">
                <fileSignature size="39450" md5="82fc107c88446a3119a51a8663d1e955" sha1="d0857baa307a2e9efff42467b5abd4e1cf40fcd5"/>
              </file>
              <file change="renamed" basisPath="page-3.jpg" otherPath="page-4.jpg">
                <fileSignature size="19125" md5="a5099878de7e2e064432d6df44ca8827" sha1="c0ccac433cf02a6cee89c14f9ba6072a184447a2"/>
              </file>
            </subset>
            <subset change="modified" count="0"/>
            <subset change="deleted" count="0"/>
            <subset change="added" count="1">
              <file change="added" basisPath="" otherPath="page-2.jpg">
                <fileSignature size="39539" md5="fe6e3ffa1b02ced189db640f68da0cc2" sha1="43ced73681687bc8e6f483618f0dcff7665e0ba7"/>
              </file>
            </subset>
          </fileGroupDifference>
          <fileGroupDifference groupId="metadata" differenceCount="3" identical="2" renamed="0" modified="3" deleted="0" added="0">
            <subset change="identical" count="2">
              <file change="identical" basisPath="descMetadata.xml" otherPath="same">
                <fileSignature size="3046" md5="a60bb487db6a1ceb5e0b5bb3cae2dfa2" sha1="edefc0e1d7cffd5bd3c7db6a393ab7632b70dc2d"/>
              </file>
              <file change="identical" basisPath="identityMetadata.xml" otherPath="same">
                <fileSignature size="932" md5="f0815d7b45530491931d5897ccbe2dd1" sha1="4065ff5523e227c1914098372a3dc587f739030e"/>
              </file>
            </subset>
            <subset change="renamed" count="0"/>
            <subset change="modified" count="3">
              <file change="modified" basisPath="contentMetadata.xml" otherPath="same">
                <fileSignature size="1135" md5="d74bfa778653b6c1b285b2d0c2f07c5b" sha1="0ee15e133c17ae3312b87247adb310b0327ca3df"/>
                <fileSignature size="1376" md5="44caefdbaf92f808c3fd27d693338c40" sha1="eb6f9c6539c90412bb4994d13311cc8dfe37c334"/>
              </file>
              <file change="modified" basisPath="provenanceMetadata.xml" otherPath="same">
                <fileSignature size="564" md5="351e4c872148e0bc9dc24874c7ef6c08" sha1="565473bbc865b1c6f88efc99b6b5b73fd5cadbc8"/>
                <fileSignature size="564" md5="17071e4607de4b272f3f06ec76be4c4a" sha1="b796a0b569bde53953ba0835bb47f4009f654349"/>
              </file>
              <file change="modified" basisPath="versionMetadata.xml" otherPath="same">
                <fileSignature size="970" md5="8a3b0051d89a90a6db90edb7b76ef63f" sha1="7e18ec3a00f7e64d561a9c1c2bc2950ef7deea33"/>
                <fileSignature size="1571" md5="6ec3d879c5a91922889adc916d991db5" sha1="65c65bedf285fc87c1ea14646bc47e79762359d3"/>
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
