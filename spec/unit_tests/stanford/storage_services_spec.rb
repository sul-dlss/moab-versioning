require 'spec_helper'

# Unit tests for class {Stanford::StorageServices}
describe 'Stanford::StorageServices' do
  
  describe '=========================== CLASS METHODS ===========================' do

    before (:all) do
      @digital_object_id = @obj
      @version_id = 2
      @content_metadata = IO.read(@data.join('v2/metadata/contentMetadata.xml'))
    end
    
    # Unit test for method: {Stanford::StorageServices.compare_cm_to_version_inventory}
    # Which returns: [FileInventoryDifference] The report of differences between the content metadata and the specified version
    # For input parameters:
    # * content_metadata [String] = The content metadata to be compared 
    # * object_id [String] = The digital object identifier of the object whose version inventory is the basis of the comparison 
    # * version_id [Integer] = The ID of the version whose inventory is to be compared, if nil use latest version 
    specify 'Stanford::StorageServices.compare_cm_to_version_inventory' do
      diff = Stanford::StorageServices.compare_cm_to_version_inventory(@content_metadata, @druid, 1)
      diff.should be_instance_of(FileInventoryDifference)
      diff.to_xml.gsub(/reportDatetime=".*?"/,'').should be_equivalent_to(<<-EOF
        <fileInventoryDifference objectId="druid:jq937jp0017" differenceCount="3" basis="v1" other="contentMetadata" >
          <fileGroupDifference groupId="content" differenceCount="3" identical="3" renamed="0" modified="1" deleted="2" added="0">
            <subset change="identical" count="3">
              <file change="identical" basisPath="page-2.jpg" otherPath="same">
                <fileSignature size="39450" md5="82fc107c88446a3119a51a8663d1e955" sha1="d0857baa307a2e9efff42467b5abd4e1cf40fcd5"/>
              </file>
              <file change="identical" basisPath="page-3.jpg" otherPath="same">
                <fileSignature size="19125" md5="a5099878de7e2e064432d6df44ca8827" sha1="c0ccac433cf02a6cee89c14f9ba6072a184447a2"/>
              </file>
              <file change="identical" basisPath="title.jpg" otherPath="same">
                <fileSignature size="40873" md5="1a726cd7963bd6d3ceb10a8c353ec166" sha1="583220e0572640abcd3ddd97393d224e8053a6ad"/>
              </file>
            </subset>
            <subset change="renamed" count="0"/>
            <subset change="modified" count="1">
              <file change="modified" basisPath="page-1.jpg" otherPath="same">
                <fileSignature size="25153" md5="3dee12fb4f1c28351c7482b76ff76ae4" sha1="906c1314f3ab344563acbbbe2c7930f08429e35b"/>
                <fileSignature size="32915" md5="c1c34634e2f18a354cd3e3e1574c3194" sha1="0616a0bd7927328c364b2ea0b4a79c507ce915ed"/>
              </file>
            </subset>
            <subset change="deleted" count="2">
              <file change="deleted" basisPath="intro-1.jpg" otherPath="">
                <fileSignature size="41981" md5="915c0305bf50c55143f1506295dc122c" sha1="60448956fbe069979fce6a6e55dba4ce1f915178"/>
              </file>
              <file change="deleted" basisPath="intro-2.jpg" otherPath="">
                <fileSignature size="39850" md5="77f1a4efdcea6a476505df9b9fba82a7" sha1="a49ae3f3771d99ceea13ec825c9c2b73fc1a9915"/>
              </file>
            </subset>
            <subset change="added" count="0"/>
          </fileGroupDifference>
        </fileInventoryDifference>
        EOF
      )
       
      # def self.compare_cm_to_version_inventory(content_metadata, object_id, version_id=nil)
      #   cm_inventory = ContentInventory.new.inventory_from_cm(content_metadata, object_id)
      #   storage_object_version = @@repository.storage_object_version(object_id,version_id)
      #   version_inventory = storage_object_version.file_inventory('version')
      #   FileInventoryDifference.new.compare(version_inventory,cm_inventory)
      # end
    end
    
    # Unit test for method: {Stanford::StorageServices.cm_version_additions}
    # Which returns: [FileInventory] The versionAddtions report showing which files are new or modified in the content metadata
    # For input parameters:
    # * content_metadata [String] = The content metadata to be evaluated 
    # * object_id [String] = The digital object identifier of the object whose signature catalog is to be used 
    # * version_id [Integer] = The ID of the version whose signature catalog is to be used, if nil use latest version 
    specify 'Stanford::StorageServices.cm_version_additions' do
      content_metadata = 'Test content_metadata' 
      object_id = 'Test object_id' 
      version_id = 78 
      adds = Stanford::StorageServices.cm_version_additions(@content_metadata, @druid, 1)
      adds.should be_instance_of(FileInventory)
      adds.to_xml.gsub(/inventoryDatetime=".*?"/,'').should be_equivalent_to(<<-EOF
        <fileInventory type="additions" objectId="druid:jq937jp0017" versionId="" fileCount="1" byteCount="32915" blockCount="33">
          <fileGroup groupId="content" dataSource="" fileCount="1" byteCount="32915" blockCount="33">
            <file>
              <fileSignature size="32915" md5="c1c34634e2f18a354cd3e3e1574c3194" sha1="0616a0bd7927328c364b2ea0b4a79c507ce915ed"/>
              <fileInstance path="page-1.jpg" datetime="2012-03-26T15:35:15Z"/>
            </file>
          </fileGroup>
        </fileInventory>
        EOF
      )
       
      # def self.cm_version_additions(content_metadata, object_id, version_id=nil)
      #   cm_inventory = ContentInventory.new.inventory_from_cm(content_metadata, object_id)
      #   storage_object_version = @@repository.storage_object_version(object_id,version_id)
      #   signature_catalog = storage_object_version.signature_catalog
      #   signature_catalog.version_additions(cm_inventory)
      # end
    end

  end

end
