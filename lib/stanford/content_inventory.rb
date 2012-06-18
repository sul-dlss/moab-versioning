require 'moab_stanford'

module Stanford

  # Stanford-specific utility methods for transforming contentMetadata to versionInventory and doing
  #
  # ====Data Model
  # * {DorMetadata} = utility methods for interfacing with Stanford metadata files (esp contentMetadata)
  #   * <b>{ContentInventory} [1..1] = utilities for transforming contentMetadata to versionInventory and doing comparsions</b>
  #   * {ActiveFedoraObject} [1..*] = utility for extracting content or other information from a Fedora Instance
  #
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class ContentInventory

    # @param content_metadata [String] The content metadata to be transformed into a versionInventory
    # @param object_id [String] The identifier of the digital object
    # @param subset [String] Speciifes which subset of files to list (all|preserve|publish|shelve)
    # @param version_id [Integer] The ID of the version whosen content metadata is to be transformed
    # @return [FileInventory] The versionInventory equivalent of the contentMetadata
    def inventory_from_cm(content_metadata, object_id, subset, version_id=nil)
      cm_inventory = FileInventory.new(:type=>"contentMetadata",:digital_object_id=>object_id, :version_id=>version_id)
      content_group = group_from_cm(content_metadata, subset)
      cm_inventory.groups << content_group
      cm_inventory
    end

    # @api external
    # @param content_metadata [String] The contentMetadata as a string
    # @param subset [String] Speciifes which subset of files to list (all|preserve|publish|shelve)
    # @return [FileGroup] The {FileGroup} object generated from a contentMetadata instance
    # @example {include:file:spec/features/stanford/content_metadata_read_spec.rb}
    def group_from_cm(content_metadata, subset)
      ng_doc = Nokogiri::XML(content_metadata)
      nodeset = case subset.to_s.downcase
        when 'preserve'
          ng_doc.xpath("//file[@preserve='yes']")
        when 'publish'
          ng_doc.xpath("//file[@publish='yes']")
        when 'shelve'
          ng_doc.xpath("//file[@shelve='yes']")
        when 'all'
          ng_doc.xpath("//file")
        else
            raise "Unknown disposition subset (#{subset})"
        end
      content_group = FileGroup.new(:group_id=>'content', :data_source => "contentMetadata-#{subset}")
      nodeset.each do |file_node|
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
    def generate_content_metadata(file_group, object_id, version_id)
      cm = Nokogiri::XML::Builder.new do |xml|
        xml.contentMetadata(:type=>"sample", :objectId=>object_id) {
          xml.resource(:type=>"version", :sequence=>"1", :id=>"version-#{version_id.to_s}") {
            file_group.files.each do |file_manifestation|
              signature = file_manifestation.signature
              file_manifestation.instances.each do |instance|
                xml.file(
                    :id=>instance.path,
                    :size=>signature.size,
                    :datetime=>instance.datetime,
                    :shelve=>'yes',
                    :publish=>'yes',
                    :preserve=>'yes') {
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