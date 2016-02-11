require 'spec_helper'

# Unit tests for class {Stanford::ContentInventory}
describe 'Stanford::ContentInventory' do
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Stanford::ContentInventory#initialize}
    # Which returns an instance of: [Stanford::ContentInventory]
    specify 'Stanford::ContentInventory#initialize' do
       
      # test initialization with required parameters (if any)
      content_inventory = ContentInventory.new()
      expect(content_inventory).to be_instance_of(ContentInventory)

      # def initialize()
      # end
    end

  end

  describe '=========================== INSTANCE METHODS ===========================' do

    before (:all) do
      @digital_object_id = @obj
      @version_id = 2
      @content_metadata = IO.read(@data.join('v0002/metadata/contentMetadata.xml'))
      @content_metadata_empty_subset = IO.read(@fixtures.join('bad_data/contentMetadata-empty-subsets.xml'))
      @node = Nokogiri::XML(@content_metadata).xpath('//file').first
   end

    before(:each) do
      @content_inventory = ContentInventory.new()
    end

    # Unit test for method: {Stanford::ContentInventory#inventory_from_cm}
    # Which returns: [Moab::FileInventory] The versionInventory equivalent of the contentMetadata
    # For input parameters:
    # * content_metadata [String] = The content metadata to be transformed into a versionInventory
    # * object_id [String] = The identifier of the digital object
    # * version_id [Integer] = The ID of the version whosen content metadata is to be transformed
    specify 'Stanford::ContentInventory#inventory_from_cm' do
      version_id = 2
      inventory = @content_inventory.inventory_from_cm(@content_metadata, @druid, 'all', version_id)
      xmlObj1 = Nokogiri::XML(inventory.to_xml)
      xmlObj1.xpath('//@inventoryDatetime').remove
      xmlTest = <<-EOF
        <fileInventory type="version" objectId="druid:jq937jp0017" versionId="2"  fileCount="4" byteCount="132363" blockCount="131">
          <fileGroup groupId="content" dataSource="contentMetadata-all" fileCount="4" byteCount="132363" blockCount="131">
            <file>
              <fileSignature size="40873" md5="1a726cd7963bd6d3ceb10a8c353ec166" sha1="583220e0572640abcd3ddd97393d224e8053a6ad" sha256=""/>
              <fileInstance path="title.jpg" datetime="2012-03-26T14:15:11Z"/>
            </file>
            <file>
              <fileSignature size="32915" md5="c1c34634e2f18a354cd3e3e1574c3194" sha1="0616a0bd7927328c364b2ea0b4a79c507ce915ed" sha256=""/>
              <fileInstance path="page-1.jpg" datetime="2012-03-26T15:35:15Z"/>
            </file>
            <file>
              <fileSignature size="39450" md5="82fc107c88446a3119a51a8663d1e955" sha1="d0857baa307a2e9efff42467b5abd4e1cf40fcd5" sha256=""/>
              <fileInstance path="page-2.jpg" datetime="2012-03-26T15:23:36Z"/>
            </file>
            <file>
              <fileSignature size="19125" md5="a5099878de7e2e064432d6df44ca8827" sha1="c0ccac433cf02a6cee89c14f9ba6072a184447a2" sha256=""/>
              <fileInstance path="page-3.jpg" datetime="2012-03-26T15:24:39Z"/>
            </file>
          </fileGroup>
        </fileInventory>
      EOF
      xmlObj2 = Nokogiri::XML(xmlTest)
      same = EquivalentXml.equivalent?(xmlObj1, xmlObj2, opts = { :element_order => false, :normalize_whitespace => true })
      expect(same).to be true

      cm_with_subsets = IO.read(@fixtures.join('data/dd116zh0343/v0001/metadata/contentMetadata.xml'))
      version_id = 1
      inventory = ContentInventory.new.inventory_from_cm(cm_with_subsets, "druid:dd116zh0343", 'preserve', version_id)
      xmlObj1 = Nokogiri::XML(inventory.to_xml)
      xmlObj1.xpath('//@inventoryDatetime').remove
      xmlTest = <<-EOF
        <fileInventory type="version" objectId="druid:dd116zh0343" versionId="1"  fileCount="8" byteCount="70979" blockCount="73">
          <fileGroup groupId="content" dataSource="contentMetadata-preserve" fileCount="8" byteCount="70979" blockCount="73">
            <file>
              <fileSignature size="7888" md5="e2837b9f02e0b0b76f526eeb81c7aa7b" sha1="61dfac472b7904e1413e0cbf4de432bda2a97627" sha256=""/>
              <fileInstance path="folder1PuSu/story1u.txt" datetime="2012-06-15T22:57:43Z"/>
            </file>
            <file>
              <fileSignature size="5983" md5="dc2be64ae43f1c1db4a068603465955d" sha1="b8a672c1848fc3d13b5f380e15835690e24600e0" sha256=""/>
              <fileInstance path="folder1PuSu/story2r.txt" datetime="2012-06-15T22:58:56Z"/>
            </file>
            <file>
              <fileSignature size="5951" md5="3d67f52e032e36b641d0cad40816f048" sha1="548f349c79928b6d0996b7ff45990bdce5ee9753" sha256=""/>
              <fileInstance path="folder1PuSu/story3m.txt" datetime="2012-06-15T23:00:43Z"/>
            </file>
            <file>
              <fileSignature size="6307" md5="34f3f646523b0a8504f216483a57bce4" sha1="d498b513add5bb138ed4f6205453a063a2434dc4" sha256=""/>
              <fileInstance path="folder1PuSu/story4d.txt" datetime="2012-06-15T23:02:22Z"/>
            </file>
            <file>
              <fileSignature size="2534" md5="1f15cc786bfe832b2fa1e6f047c500ba" sha1="bf3af01de2afa15719d8c42a4141e3b43d06fef6" sha256=""/>
              <fileInstance path="folder2PdSa/story6u.txt" datetime="2012-06-15T23:05:03Z"/>
            </file>
            <file>
              <fileSignature size="17074" md5="205271287477c2309512eb664eff9130" sha1="b23aa592ab673030ace6178e29fad3cf6a45bd32" sha256=""/>
              <fileInstance path="folder2PdSa/story7r.txt" datetime="2012-06-15T23:08:35Z"/>
            </file>
            <file>
              <fileSignature size="5643" md5="ce474f4c512953f20a8c4c5b92405cf7" sha1="af9cbf5ab4f020a8bb17b180fbd5c41598d89b37" sha256=""/>
              <fileInstance path="folder2PdSa/story8m.txt" datetime="2012-06-15T23:09:26Z"/>
            </file>
            <file>
              <fileSignature size="19599" md5="135cb2db6a35afac590687f452053baf" sha1="e74274d7bc06ef44a408a008f5160b3756cb2ab0" sha256=""/>
              <fileInstance path="folder2PdSa/story9d.txt" datetime="2012-06-15T23:14:32Z"/>
            </file>
          </fileGroup>
        </fileInventory>
      EOF
      xmlObj2 = Nokogiri::XML(xmlTest)
      same = EquivalentXml.equivalent?(xmlObj1, xmlObj2, opts = { :element_order => false, :normalize_whitespace => true })
      expect(same).to be true

      # def inventory_from_cm(content_metadata, object_id, version_id=nil)
      #   cm_inventory = Moab::FileInventory.new(:type=>'cm',:digital_object_id=>object_id, :version_id=>version_id)
      #   content_group = group_from_cm(content_metadata )
      #   cm_inventory.groups << content_group
      #   cm_inventory
      # end
    end

    # Unit test for method: {Stanford::ContentInventory#inventory_from_cm}
    # testing boundary case where all subset attributes ar no (e.g. shelve='no')
    specify 'Stanford::ContentInventory#inventory_from_cm with empty subset' do
      empty_inventory = <<-EOF
        <fileInventory type="version" objectId="druid:ms205ty4764" versionId="1"  fileCount="0" byteCount="0" blockCount="0">
          <fileGroup groupId="content" dataSource="contentMetadata-subset" fileCount="0" byteCount="0" blockCount="0"/>
        </fileInventory>
      EOF
      druid = 'druid:ms205ty4764'
      version_id = 1
      subsets = %w(shelve publish preserve)
      subsets.each do |subset|
        inventory = @content_inventory.inventory_from_cm(@content_metadata_empty_subset, druid, subset, version_id)
        #diff.should be_instance_of(Moab::FileInventoryDifference)
        xmlObj1 = Nokogiri::XML(inventory.to_xml)
        xmlObj1.xpath('//@inventoryDatetime').remove
        xmlObj2 = Nokogiri::XML(empty_inventory)
        xmlObj2.xpath('//@dataSource').each {|d| d.value = d.value.gsub(/subset/, subset) }
        same = EquivalentXml.equivalent?(xmlObj1, xmlObj2, opts = { :element_order => false, :normalize_whitespace => true })
        expect(same).to be true
      end
    end

    # Unit test for method: {Stanford::ContentInventory#group_from_cm}
    # Which returns: [Moab::FileGroup] The {Moab::FileGroup} object generated from a contentMetadata instance
    # For input parameters:
    # * content_metadata [String] = The contentMetadata as a string
    specify 'Stanford::ContentInventory#group_from_cm' do
      group = @content_inventory.group_from_cm(@content_metadata,'all')
      expect(group).to be_instance_of(Moab::FileGroup)
      expect(group.data_source).to eq("contentMetadata-all")

      cm_with_subsets = IO.read(@fixtures.join('data/dd116zh0343/v0001/metadata/contentMetadata.xml'))
      group = ContentInventory.new.group_from_cm(cm_with_subsets,"all")
      expect(group.files.size).to eq(12)

      group = ContentInventory.new.group_from_cm(cm_with_subsets,"shelve")
      expect(group.files.size).to eq(8)

      group = ContentInventory.new.group_from_cm(cm_with_subsets,"publish")
      expect(group.files.size).to eq(12)

      group = ContentInventory.new.group_from_cm(cm_with_subsets,"preserve")
      expect(group.files.size).to eq(8)

      expect{ContentInventory.new.group_from_cm(cm_with_subsets,"dummy")}.to raise_exception /Unknown disposition subset/

      # def group_from_cm(content_metadata)
      #   content_group = Moab::FileGroup.new(:group_id=>'content', :data_source => 'contentMetadata')
      #   Nokogiri::XML(content_metadata).xpath('//file').each do |file_node|
      #     signature = generate_signature(file_node)
      #     instance = generate_instance(file_node)
      #     content_group.add_file_instance(signature, instance)
      #   end
      #   content_group
      # end
    end

    # Unit test for method: {Stanford::ContentInventory#generate_signature}
    # Which returns: [Moab::FileSignature] The {Moab::FileSignature} object generated from the XML data
    # For input parameters:
    # * node [Nokogiri::XML::Node] = The XML node containing file information
    specify 'Stanford::ContentInventory#generate_signature' do
      expect(@content_inventory.generate_signature(@node).fixity).to eq(
          {:size=>"40873", :md5=>"1a726cd7963bd6d3ceb10a8c353ec166", :sha1=>"583220e0572640abcd3ddd97393d224e8053a6ad"}
      )
      # add a sha256 checksum
      node2 = @node.clone
      Nokogiri::XML::Builder.with(node2) do |xml|
        xml.checksum '291208b41c557a5fb15cc836ab7235dadbd0881096385cc830bb446b00d2eb6b', :type=>"SHA-256"
      end
      expect(@content_inventory.generate_signature(node2).fixity).to eq(
          {:size=>"40873",
           :md5=>"1a726cd7963bd6d3ceb10a8c353ec166",
           :sha1=>"583220e0572640abcd3ddd97393d224e8053a6ad",
           :sha256=>"291208b41c557a5fb15cc836ab7235dadbd0881096385cc830bb446b00d2eb6b"}
      )
    end

    # Unit test for method: {Stanford::ContentInventory#generate_instance}
    # Which returns: [Moab::FileInstance] The {Moab::FileInstance} object generated from the XML data
    # For input parameters:
    # * node [Nokogiri::XML::Node] = The XML node containing file information
    specify 'Stanford::ContentInventory#generate_instance' do
      node = Nokogiri::XML(@content_metadata).xpath('//file').first
      expect(@content_inventory.generate_instance(@node)).to hash_match({
              "path" => "title.jpg",
          "datetime" => "2012-03-26T14:15:11Z"
      })

      # def generate_instance(node)
      #   instance = Moab::FileInstance.new()
      #   instance.path = node.attributes['id'].content
      #   instance.datetime = node.attributes['datetime'].content rescue nil
      #   instance
      # end
    end

    # Unit test for method: {Stanford::ContentInventory#generate_content_metadata}
    # Which returns: [String] The contentMetadata instance generated from the Moab::FileGroup
    # For input parameters:
    # * file_group [Moab::FileGroup] = The {Moab::FileGroup} object used as the data source
    specify 'Stanford::ContentInventory#generate_content_metadata' do
      directory = @data.join('v0002/content')
      recursive = true
      group= Moab::FileGroup.new.group_from_directory(directory, recursive)
      cm = @content_inventory.generate_content_metadata(group, @digital_object_id, @version_id)
      xmlObj1 = Nokogiri::XML(cm)
      xmlObj1.xpath('//@datetime').remove
      #puts cm
      xmlTest = <<-EOF
        <contentMetadata type="sample" objectId="jq937jp0017">
          <resource type="version" sequence="1" id="version-2">
            <file preserve="yes" publish="yes"  size="32915" id="page-1.jpg" shelve="yes">
              <checksum type="MD5">c1c34634e2f18a354cd3e3e1574c3194</checksum>
              <checksum type="SHA-1">0616a0bd7927328c364b2ea0b4a79c507ce915ed</checksum>
              <checksum type="SHA-256">b78cc53b7b8d9ed86d5e3bab3b699c7ed0db958d4a111e56b6936c8397137de0</checksum>
            </file>
            <file preserve="yes" publish="yes"  size="39450" id="page-2.jpg" shelve="yes">
              <checksum type="MD5">82fc107c88446a3119a51a8663d1e955</checksum>
              <checksum type="SHA-1">d0857baa307a2e9efff42467b5abd4e1cf40fcd5</checksum>
              <checksum type="SHA-256">235de16df4804858aefb7690baf593fb572d64bb6875ec522a4eea1f4189b5f0</checksum>
            </file>
            <file preserve="yes" publish="yes"  size="19125" id="page-3.jpg" shelve="yes">
              <checksum type="MD5">a5099878de7e2e064432d6df44ca8827</checksum>
              <checksum type="SHA-1">c0ccac433cf02a6cee89c14f9ba6072a184447a2</checksum>
              <checksum type="SHA-256">7bd120459eff0ecd21df94271e5c14771bfca5137d1dd74117b6a37123dfe271</checksum>
            </file>
            <file preserve="yes" publish="yes"  size="40873" id="title.jpg" shelve="yes">
              <checksum type="MD5">1a726cd7963bd6d3ceb10a8c353ec166</checksum>
              <checksum type="SHA-1">583220e0572640abcd3ddd97393d224e8053a6ad</checksum>
              <checksum type="SHA-256">8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5</checksum>
            </file>
          </resource>
        </contentMetadata>
      EOF
      xmlObj2 = Nokogiri::XML(xmlTest)
      same = EquivalentXml.equivalent?(xmlObj1, xmlObj2, opts = { :element_order => false, :normalize_whitespace => true })
      expect(same).to be true

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

    specify 'Stanford::ContentInventory#validate_content_metadata' do
      cm = @fixtures.join('data','jq937jp0017','v0001','metadata','contentMetadata.xml').read
      expect(@content_inventory.validate_content_metadata(cm)).to eq(true)

      cm = @fixtures.join('bad_data','contentMetadata.xml')
      expect{@content_inventory.validate_content_metadata(cm)}.to raise_exception(Moab::InvalidMetadataException)
    end

    specify 'Stanford::ContentInventory#validate_content_metadata_details' do
      cm = @fixtures.join('bad_data','contentMetadata.xml').read
      content_metadata_doc = Nokogiri::XML(cm)
      result = @content_inventory.validate_content_metadata_details(content_metadata_doc)
      expect(result).to eq([
          "File node 0 is missing id",
          "File node having id='page-1.jpg' is missing size",
          "File node having id='page-2.jpg' is missing md5",
          "File node having id='page-3.jpg' is missing sha1"
      ])
      expect{@content_inventory.validate_content_metadata_details(Hash.new)}.to raise_exception(
          /Content Metadata is in unrecognized format/)
    end

    specify 'Stanford::ContentInventory#remediate_content_metadata' do
      cm = @fixtures.join('bad_data','contentMetadata-missing-fixity.xml').read
      directory = @data.join('v0001/content')
      group = Moab::FileGroup.new.group_from_directory(directory, recursive=true)
      ng_xml = @content_inventory.remediate_content_metadata(cm, group)
      xmlObj1 = Nokogiri::XML(ng_xml)
      xmlTest = <<-EOF
        <contentMetadata type="sample" objectId="druid:jq937jp0017">
          <resource type="version" sequence="1" id="version-1">
            <file datetime="2012-03-26T08:15:11-06:00" size="40873" id="title.jpg" shelve="yes" publish="yes" preserve="yes">
              <checksum type="MD5">1a726cd7963bd6d3ceb10a8c353ec166</checksum>
              <checksum type="SHA-1">583220e0572640abcd3ddd97393d224e8053a6ad</checksum>
              <checksum type="SHA-256">8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5</checksum>
            </file>
            <file datetime="2012-03-26T08:20:35-06:00" id="intro-1.jpg" shelve="yes" publish="yes" preserve="yes" size="41981">
              <checksum type="MD5">915c0305bf50c55143f1506295dc122c</checksum>
              <checksum type="SHA-1">60448956fbe069979fce6a6e55dba4ce1f915178</checksum>
              <checksum type="SHA-256">4943c6ffdea7e33b74fd7918de900de60e9073148302b0ad1bf5df0e6cec032a</checksum>
            </file>
            <file datetime="2012-03-26T08:19:30-06:00" size="39850" id="intro-2.jpg" shelve="yes" publish="yes" preserve="yes">
              <checksum type="MD5">77f1a4efdcea6a476505df9b9fba82a7</checksum>
              <checksum type="SHA-1">a49ae3f3771d99ceea13ec825c9c2b73fc1a9915</checksum>
              <checksum type="SHA-256">3a28718a8867e4329cd0363a84aee1c614d0f11229a82e87c6c5072a6e1b15e7</checksum>
            </file>
            <file datetime="2012-03-26T09:59:14-06:00" size="25153" id="page-1.jpg" shelve="yes" publish="yes" preserve="yes">
            <checksum type="MD5">3dee12fb4f1c28351c7482b76ff76ae4</checksum><checksum type="SHA-1">906c1314f3ab344563acbbbe2c7930f08429e35b</checksum><checksum type="SHA-256">41aaf8598c9d8e3ee5d55efb9be11c542099d9f994b5935995d0abea231b8bad</checksum></file>
            <file datetime="2012-03-26T09:23:36-06:00" id="page-2.jpg" shelve="yes" publish="yes" preserve="yes" size="39450">
            <checksum type="MD5">82fc107c88446a3119a51a8663d1e955</checksum><checksum type="SHA-1">d0857baa307a2e9efff42467b5abd4e1cf40fcd5</checksum><checksum type="SHA-256">235de16df4804858aefb7690baf593fb572d64bb6875ec522a4eea1f4189b5f0</checksum></file>
            <file datetime="2012-03-26T09:24:39-06:00" size="19125" id="page-3.jpg" shelve="yes" publish="yes" preserve="yes">
              <checksum type="MD5">a5099878de7e2e064432d6df44ca8827</checksum>
              <checksum type="SHA-1">c0ccac433cf02a6cee89c14f9ba6072a184447a2</checksum>
              <checksum type="SHA-256">7bd120459eff0ecd21df94271e5c14771bfca5137d1dd74117b6a37123dfe271</checksum>
            </file>
          </resource>
        </contentMetadata>
      EOF
      xmlObj2 = Nokogiri::XML(xmlTest)
      same = EquivalentXml.equivalent?(xmlObj1, xmlObj2, opts = { :element_order => false, :normalize_whitespace => true })
      expect(same).to be true

      cm_bad_size = cm.sub(/40873/,'37804')
      expect{@content_inventory.remediate_content_metadata(cm_bad_size,group)}.
          to raise_exception(/Inconsistent size for title.jpg: 37804 != 40873/)

      cm_bad_checksum = cm.sub(/1a726cd7963bd6d3ceb10a8c353ec166/,'915c0305bf50c55143f1506295dc122c')
      expect{@content_inventory.remediate_content_metadata(cm_bad_checksum,group)}.
          to raise_exception(/Inconsistent md5 for title.jpg: 915c0305bf50c55143f1506295dc122c != 1a726cd7963bd6d3ceb10a8c353ec166/)

    end


  end

end
