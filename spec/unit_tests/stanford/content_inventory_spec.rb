require 'spec_helper'

# Unit tests for class {Stanford::ContentInventory}
describe 'Stanford::ContentInventory' do
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Stanford::ContentInventory#initialize}
    # Which returns an instance of: [Stanford::ContentInventory]
    specify 'Stanford::ContentInventory#initialize' do
       
      # test initialization with required parameters (if any)
      content_inventory = ContentInventory.new()
      content_inventory.should be_instance_of(ContentInventory)

      # def initialize()
      # end
    end

  end

  describe '=========================== INSTANCE METHODS ===========================' do

    before (:all) do
      @digital_object_id = @obj
      @version_id = 2
      @content_metadata = IO.read(@data.join('v2/metadata/contentMetadata.xml'))
      @node = Nokogiri::XML(@content_metadata).xpath('//file').first
   end

    before(:each) do
      @content_inventory = ContentInventory.new()
    end

    # Unit test for method: {Stanford::ContentInventory#inventory_from_cm}
    # Which returns: [FileInventory] The versionInventory equivalent of the contentMetadata
    # For input parameters:
    # * content_metadata [String] = The content metadata to be transformed into a versionInventory
    # * object_id [String] = The identifier of the digital object
    # * version_id [Integer] = The ID of the version whosen content metadata is to be transformed
    specify 'Stanford::ContentInventory#inventory_from_cm' do
      version_id = 2
      inventory = @content_inventory.inventory_from_cm(@content_metadata, @druid, version_id)
      inventory.to_xml.gsub(/inventoryDatetime=".*?"/,'').should be_equivalent_to(<<-EOF
      <fileInventory type="cm" objectId="druid:jq937jp0017" versionId="2"  fileCount="4" byteCount="132363" blockCount="131">
        <fileGroup groupId="content" dataSource="contentMetadata" fileCount="4" byteCount="132363" blockCount="131">
          <file>
            <fileSignature size="40873" md5="1a726cd7963bd6d3ceb10a8c353ec166" sha1="583220e0572640abcd3ddd97393d224e8053a6ad"/>
            <fileInstance path="title.jpg" datetime="2012-03-26T14:15:11Z"/>
          </file>
          <file>
            <fileSignature size="32915" md5="c1c34634e2f18a354cd3e3e1574c3194" sha1="0616a0bd7927328c364b2ea0b4a79c507ce915ed"/>
            <fileInstance path="page-1.jpg" datetime="2012-03-26T15:35:15Z"/>
          </file>
          <file>
            <fileSignature size="39450" md5="82fc107c88446a3119a51a8663d1e955" sha1="d0857baa307a2e9efff42467b5abd4e1cf40fcd5"/>
            <fileInstance path="page-2.jpg" datetime="2012-03-26T15:23:36Z"/>
          </file>
          <file>
            <fileSignature size="19125" md5="a5099878de7e2e064432d6df44ca8827" sha1="c0ccac433cf02a6cee89c14f9ba6072a184447a2"/>
            <fileInstance path="page-3.jpg" datetime="2012-03-26T15:24:39Z"/>
          </file>
        </fileGroup>
      </fileInventory>
      EOF
      )

      # def inventory_from_cm(content_metadata, object_id, version_id=nil)
      #   cm_inventory = FileInventory.new(:type=>'cm',:digital_object_id=>object_id, :version_id=>version_id)
      #   content_group = group_from_cm(content_metadata )
      #   cm_inventory.groups << content_group
      #   cm_inventory
      # end
    end

    # Unit test for method: {Stanford::ContentInventory#group_from_cm}
    # Which returns: [FileGroup] The {FileGroup} object generated from a contentMetadata instance
    # For input parameters:
    # * content_metadata [String] = The contentMetadata as a string
    specify 'Stanford::ContentInventory#group_from_cm' do
      group = @content_inventory.group_from_cm(@content_metadata)
      group.should be_instance_of(FileGroup)
      group.data_source.should == "contentMetadata"

      # def group_from_cm(content_metadata)
      #   content_group = FileGroup.new(:group_id=>'content', :data_source => 'contentMetadata')
      #   Nokogiri::XML(content_metadata).xpath('//file').each do |file_node|
      #     signature = generate_signature(file_node)
      #     instance = generate_instance(file_node)
      #     content_group.add_file_instance(signature, instance)
      #   end
      #   content_group
      # end
    end

    # Unit test for method: {Stanford::ContentInventory#generate_signature}
    # Which returns: [FileSignature] The {FileSignature} object generated from the XML data
    # For input parameters:
    # * node [Nokogiri::XML::Node] = The XML node containing file information
    specify 'Stanford::ContentInventory#generate_signature' do
      @content_inventory.generate_signature(@node).fixity.should ==
          ["40873", "1a726cd7963bd6d3ceb10a8c353ec166", "583220e0572640abcd3ddd97393d224e8053a6ad"]

      # def generate_signature(node)
      #   signature = FileSignature.new()
      #   signature.size = node.attributes['size'].content
      #   checksum_nodes = node.xpath('checksum')
      #   checksum_nodes.each do |checksum_node|
      #     case checksum_node.attributes['type'].content.upcase
      #       when 'MD5'
      #         signature.md5 = checksum_node.text
      #       when 'SHA1', 'SHA-1'
      #         signature.sha1 = checksum_node.text
      #     end
      #   end
      #   signature
      # end
    end

    # Unit test for method: {Stanford::ContentInventory#generate_instance}
    # Which returns: [FileInstance] The {FileInstance} object generated from the XML data
    # For input parameters:
    # * node [Nokogiri::XML::Node] = The XML node containing file information
    specify 'Stanford::ContentInventory#generate_instance' do
      node = Nokogiri::XML(@content_metadata).xpath('//file').first
      @content_inventory.generate_instance(@node).should hash_match({
              "path" => "title.jpg",
          "datetime" => "2012-03-26T14:15:11Z"
      })

      # def generate_instance(node)
      #   instance = FileInstance.new()
      #   instance.path = node.attributes['id'].content
      #   instance.datetime = node.attributes['datetime'].content rescue nil
      #   instance
      # end
    end

    # Unit test for method: {Stanford::ContentInventory#generate_content_metadata}
    # Which returns: [String] The contentMetadata instance generated from the FileGroup
    # For input parameters:
    # * file_group [FileGroup] = The {FileGroup} object used as the data source
    specify 'Stanford::ContentInventory#generate_content_metadata' do
      directory = @data.join('v2/content')
      recursive = true
      group= FileGroup.new.group_from_directory(directory, recursive)
      cm = @content_inventory.generate_content_metadata(group,@digital_object_id, @version_id)
      #puts cm
      cm.gsub(/datetime=".*Z"/,'').should be_equivalent_to(<<-EOF
        <contentMetadata objectId="jq937jp0017" type="sample">
          <resource type="version" sequence="1" id="version-2">
            <file size="32915" id="page-1.jpg" >
              <checksum type="MD5">c1c34634e2f18a354cd3e3e1574c3194</checksum>
              <checksum type="SHA-1">0616a0bd7927328c364b2ea0b4a79c507ce915ed</checksum>
            </file>
            <file size="39450" id="page-2.jpg" >
              <checksum type="MD5">82fc107c88446a3119a51a8663d1e955</checksum>
              <checksum type="SHA-1">d0857baa307a2e9efff42467b5abd4e1cf40fcd5</checksum>
            </file>
            <file size="19125" id="page-3.jpg" >
              <checksum type="MD5">a5099878de7e2e064432d6df44ca8827</checksum>
              <checksum type="SHA-1">c0ccac433cf02a6cee89c14f9ba6072a184447a2</checksum>
            </file>
            <file size="40873" id="title.jpg" >
              <checksum type="MD5">1a726cd7963bd6d3ceb10a8c353ec166</checksum>
              <checksum type="SHA-1">583220e0572640abcd3ddd97393d224e8053a6ad</checksum>
            </file>
          </resource>
        </contentMetadata>
        EOF
        )

      # def generate_content_metadata(file_group, object_id, version_id)
      #   cm = Nokogiri::XML::Builder.new do |xml|
      #     xml.contentMetadata(:type=>"sample", :objectId=>object_id) {
      #       xml.resource(:type=>"version", :sequence=>"1", :id=>"version-#{version_id.to_s}") {
      #         file_group.files.each do |file_manifestation|
      #           signature = file_manifestation.signature
      #           file_manifestation.instances.each do |instance|
      #             xml.file(:id=>instance.path, :size=>signature.size, :datetime=>instance.datetime) {
      #               xml.checksum(:type=>"MD5") {xml.text signature.md5 }
      #               xml.checksum(:type=>"SHA-1") {xml.text signature.sha1}
      #             }
      #           end
      #         end
      #       }
      #     }
      #   end
      #   cm.to_xml
      # end
    end
  
  end

end
