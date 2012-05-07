require 'moab'

include Moab

module Stanford

  # Stanford-specific utility methods for interfacing with DOR metadata files (esp contentMetadata)
  #
  # ====Data Model
  # * <b>{DorMetadata} = utility methods for interfacing with Stanford metadata files (esp contentMetadata)</b>
  #   * {ActiveFedoraObject} [1..*] = utility for extracting content or other information from a Fedora Instance
  #
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class DorMetadata

    # @return [String] The digital object identifier (druid)
    attr_accessor :digital_object_id

    # @return [Integer] \@versionId = The ordinal version number
    attr_accessor :version_id

    # @param digital_object_id [String] The digital object identifier
    # @param version_id [Integer] The ordinal version number
    # @return [Stanford::DorMetadata]
    def initialize(digital_object_id, version_id=nil)
      @digital_object_id = digital_object_id
      @version_id = version_id
    end

    # @api internal
    # @param directory [String] The location of the directory to be inventoried
    # @param version_id (see #initialize)
    # @return [FileInventory]  Inventory of the files under the specified directory
    def inventory_from_directory(directory, version_id=nil)
      version_id ||= @version_id
      version_inventory = FileInventory.new(:type=>'version',:digital_object_id=>@digital_object_id, :version_id=>version_id)
      content_metadata = IO.read(File.join(directory,'contentMetadata.xml'))
      content_group = group_from_file(content_metadata )
      version_inventory.groups << content_group
      metadata_group = FileGroup.new(:group_id=>'metadata').group_from_directory(directory)
      version_inventory.groups << metadata_group
      version_inventory
    end

    # @api external
    # @param content_metadata [String] The contentMetadata as a string
    # @return [FileGroup] The {FileGroup} object generated from a contentMetadata instance
    # @example {include:file:spec/features/stanford/content_metadata_read_spec.rb}
      def group_from_file(content_metadata)
      content_group = FileGroup.new(:group_id=>'content', :data_source => 'contentMetadata')
      Nokogiri::XML(content_metadata).xpath('//file').each do |file_node|
        signature = generate_signature(file_node)
        instance = generate_instance(file_node)
        content_group.add_file_instance(signature, instance)
      end
      content_group
    end

    # @api internal
    # @param node [Nokogiri::XML::Node] The XML node containing file information
    # @return [FileSignature] The {FileSignature} object generated from the XML data
    def generate_signature(node)
      signature = FileSignature.new()
      signature.size = node.attributes['size'].content
      checksum_nodes = node.xpath('checksum')
      checksum_nodes.each do |checksum_node|
        case checksum_node.attributes['type'].content.upcase
          when 'MD5'
            signature.md5 = checksum_node.text
          when 'SHA1', 'SHA-1'
            signature.sha1 = checksum_node.text
        end
      end
      signature
    end

    # @api internal
    # @param node (see #generate_signature)
    # @return [FileInstance] The {FileInstance} object generated from the XML data
    def generate_instance(node)
      instance = FileInstance.new()
      instance.path = node.attributes['id'].content
      instance.datetime = node.attributes['datetime'].content rescue nil
      instance
    end

    # @api external
    # @param file_group [FileGroup] The {FileGroup} object used as the data source
    # @return [String] The contentMetadata instance generated from the FileGroup
    # @example {include:file:spec/features/stanford/content_metadata_write_spec.rb}
    def generate_content_metadata(file_group)
      cm = Nokogiri::XML::Builder.new do |xml|
        xml.contentMetadata(:type=>"sample", :objectId=>@digital_object_id) {
          xml.resource(:type=>"version", :sequence=>"1", :id=>"version-#{@version_id.to_s}") {
            file_group.files.each do |file_manifestation|
              signature = file_manifestation.signature
              file_manifestation.instances.each do |instance|
                xml.file(:id=>instance.path, :size=>signature.size, :datetime=>instance.datetime) {
                  xml.checksum(:type=>"MD5") {xml.text signature.md5 }
                  xml.checksum(:type=>"SHA-1") {xml.text signature.sha1}
                }
              end
            end
          }
        }
      end
      cm.to_xml
    end

  end

end