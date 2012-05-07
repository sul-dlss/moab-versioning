require 'spec_helper'

# Unit tests for class {Stanford::DorMetadata}
describe 'Stanford::DorMetadata' do
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Stanford::DorMetadata#initialize}
    # Which returns an instance of: [Stanford::DorMetadata]
    # For input parameters:
    # * digital_object_id [String] = The digital object identifier 
    # * version_id [Integer] = The ordinal version number 
    specify 'Stanford::DorMetadata#initialize' do
       
      # test initialization with required parameters (if any)
      digital_object_id = 'Test digital_object_id' 
      version_id = 68 
      dor_metadata = DorMetadata.new(digital_object_id, version_id)
      dor_metadata.should be_instance_of(DorMetadata)
      dor_metadata.digital_object_id.should == digital_object_id
      dor_metadata.version_id.should == version_id
       
      # def initialize(digital_object_id, version_id=nil)
      #   @digital_object_id = digital_object_id
      #   @version_id = version_id
      # end
    end
  
  end
  
  describe '=========================== INSTANCE ATTRIBUTES ===========================' do
    
    before(:all) do
      digital_object_id = 'Test digital_object_id' 
      version_id = 27 
      @dor_metadata = DorMetadata.new(digital_object_id, version_id)
    end
    
    # Unit test for attribute: {Stanford::DorMetadata#digital_object_id}
    # Which stores: [String] The digital object identifier (druid)
    specify 'Stanford::DorMetadata#digital_object_id' do
      value = 'Test digital_object_id'
      @dor_metadata.digital_object_id= value
      @dor_metadata.digital_object_id.should == value
       
      # def digital_object_id=(value)
      #   @digital_object_id = value
      # end
       
      # def digital_object_id
      #   @digital_object_id
      # end
    end
    
    # Unit test for attribute: {Stanford::DorMetadata#version_id}
    # Which stores: [Integer] \@versionId = The ordinal version number
    specify 'Stanford::DorMetadata#version_id' do
      value = 10
      @dor_metadata.version_id= value
      @dor_metadata.version_id.should == value
       
      # def version_id=(value)
      #   @version_id = value
      # end
       
      # def version_id
      #   @version_id
      # end
    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do

    before (:all) do
      @digital_object_id = @obj
      @version_id = 2
      @content_metadata = @data.join('v2/metadata/contentMetadata.xml')
      @node = Nokogiri::XML(IO.read(@content_metadata)).xpath('//file').first
    end

    before(:each) do
      @dor_metadata = DorMetadata.new(@digital_object_id, @version_id)
    end
    
    # Unit test for method: {Stanford::DorMetadata#inventory_from_directory}
    # Which returns: [FileInventory] Inventory of the files under the specified directory
    # For input parameters:
    # * directory [String] = The location of the directory to be inventoried 
    # * version_id [Integer] = The ordinal version number 
    specify 'Stanford::DorMetadata#inventory_from_directory' do
      directory = @data.join('v2/metadata')
      version_id = 2
      inventory = @dor_metadata.inventory_from_directory(directory, version_id)
      inventory.type.should == "version"
      inventory.digital_object_id.should == "jq937jp0017"
      inventory.version_id.should == 2
      inventory.groups.size.should == 2
      inventory.file_count.should == 9

      # def inventory_from_directory(directory, version_id=nil)
      #   version_id ||= @version_id
      #   version_inventory = FileInventory.new(:type=>'version',:digital_object_id=>@digital_object_id, :version_id=>version_id)
      #   content_metadata = IO.read(File.join(directory,'contentMetadata.xml'))
      #   content_group = group_from_file(content_metadata )
      #   version_inventory.groups << content_group
      #   metadata_group = FileGroup.new(:group_id=>'metadata').group_from_directory(directory)
      #   version_inventory.groups << metadata_group
      #   version_inventory
      # end
    end
    
    # Unit test for method: {Stanford::DorMetadata#group_from_file}
    # Which returns: [FileGroup] The {FileGroup} object generated from a contentMetadata instance
    # For input parameters:
    # * content_metadata [String] = The contentMetadata as a string 
    specify 'Stanford::DorMetadata#group_from_file' do
      group = @dor_metadata.group_from_file(@content_metadata)
      group.should be_instance_of(FileGroup)
      group.data_source.should == "contentMetadata"


      # def group_from_file(content_metadata)
      #   content_group = FileGroup.new(:group_id=>'content', :data_source => 'contentMetadata')
      #   Nokogiri::XML(content_metadata).xpath('//file').each do |file_node|
      #     signature = generate_signature(file_node)
      #     instance = generate_instance(file_node)
      #     content_group.add_file_instance(signature, instance)
      #   end
      #   content_group
      # end
    end
    
    # Unit test for method: {Stanford::DorMetadata#generate_signature}
    # Which returns: [FileSignature] The {FileSignature} object generated from the XML data
    # For input parameters:
    # * node [Nokogiri::XML::Node] = The XML node containing file information 
    specify 'Stanford::DorMetadata#generate_signature' do
      @dor_metadata.generate_signature(@node).fixity.should ==
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
    
    # Unit test for method: {Stanford::DorMetadata#generate_instance}
    # Which returns: [FileInstance] The {FileInstance} object generated from the XML data
    # For input parameters:
    # * node [Nokogiri::XML::Node] = The XML node containing file information 
    specify 'Stanford::DorMetadata#generate_instance' do
      node = Nokogiri::XML(@content_metadata).xpath('//file').first
      @dor_metadata.generate_instance(@node).should hash_match({
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
    
    # Unit test for method: {Stanford::DorMetadata#generate_content_metadata}
    # Which returns: [String] The contentMetadata instance generated from the FileGroup
    # For input parameters:
    # * file_group [FileGroup] = The {FileGroup} object used as the data source 
    specify 'Stanford::DorMetadata#generate_content_metadata' do
      directory = @data.join('v2/content')
      recursive = true
      group= FileGroup.new.group_from_directory(directory, recursive)
      cm = @dor_metadata.generate_content_metadata(group)
      #puts cm
      cm.should be_equivalent_to(<<EOF
<?xml version="1.0"?>
<contentMetadata objectId="jq937jp0017" type="sample">
  <resource type="version" sequence="1" id="version-2">
    <file size="32915" id="page-1.jpg" datetime="2012-03-26T15:35:15Z">
      <checksum type="MD5">c1c34634e2f18a354cd3e3e1574c3194</checksum>
      <checksum type="SHA-1">0616a0bd7927328c364b2ea0b4a79c507ce915ed</checksum>
    </file>
    <file size="39450" id="page-2.jpg" datetime="2012-03-26T15:23:36Z">
      <checksum type="MD5">82fc107c88446a3119a51a8663d1e955</checksum>
      <checksum type="SHA-1">d0857baa307a2e9efff42467b5abd4e1cf40fcd5</checksum>
    </file>
    <file size="19125" id="page-3.jpg" datetime="2012-03-26T15:24:39Z">
      <checksum type="MD5">a5099878de7e2e064432d6df44ca8827</checksum>
      <checksum type="SHA-1">c0ccac433cf02a6cee89c14f9ba6072a184447a2</checksum>
    </file>
    <file size="40873" id="title.jpg" datetime="2012-03-26T14:15:11Z">
      <checksum type="MD5">1a726cd7963bd6d3ceb10a8c353ec166</checksum>
      <checksum type="SHA-1">583220e0572640abcd3ddd97393d224e8053a6ad</checksum>
    </file>
  </resource>
</contentMetadata>
EOF
)

      # def generate_content_metadata(file_group)
      #   cm = Nokogiri::XML::Builder.new do |xml|
      #     xml.contentMetadata(:type=>"sample", :objectId=>@digital_object_id) {
      #       xml.resource(:type=>"version", :sequence=>"1", :id=>"version-#{@version_id.to_s}") {
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
