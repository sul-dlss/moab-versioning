module Stanford
  # Stanford-specific utility methods for transforming contentMetadata to versionInventory and doing comparisons
  #
  # ====Data Model
  # * {DorMetadata} = utility methods for interfacing with Stanford metadata files (esp contentMetadata)
  #   * <b>{ContentInventory} [1..1] = utilities for transforming contentMetadata to versionInventory and doing comparisons</b>
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
    #   if the supplied content_metadata is blank or empty, then a skeletal FileInventory will be returned
    def inventory_from_cm(content_metadata, object_id, subset, version_id = nil)
      # The contentMetadata datastream is not required for ingest, since some object types, such as collection
      #   or APO do not require one.
      # Many of these objects have contentMetadata with no child elements, such as this:
      #    <contentMetadata objectId="bd608mj3166" type="file"/>
      # but there are also objects that have no datasteam of this name at all
      cm_inventory = Moab::FileInventory.new(:type => "version", :digital_object_id => object_id, :version_id => version_id)
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
      validate_content_metadata(ng_doc)
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
                  raise(Moab::MoabRuntimeError, "Unknown disposition subset (#{subset})")
                end
      content_group = Moab::FileGroup.new(:group_id => 'content', :data_source => "contentMetadata-#{subset}")
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
      signature = Moab::FileSignature.new
      signature.size = node.attributes['size'].content
      checksum_nodes = node.xpath('checksum')
      checksum_nodes.each do |checksum_node|
        case checksum_node.attributes['type'].content.upcase
        when 'MD5'
          signature.md5 = checksum_node.text
        when 'SHA1', 'SHA-1'
          signature.sha1 = checksum_node.text
        when 'SHA256', 'SHA-256'
          signature.sha256 = checksum_node.text
        end
      end
      signature
    end

    # @api internal
    # @param node (see #generate_signature)
    # @return [FileInstance] The {FileInstance} object generated from the XML data
    def generate_instance(node)
      instance = Moab::FileInstance.new
      instance.path = node.attributes['id'].content
      instance.datetime = begin
                            node.attributes['datetime'].content
                          rescue
                            nil
                          end
      instance
    end

    # @api external
    # @param file_group [FileGroup] The {FileGroup} object used as the data source
    # @return [String] The contentMetadata instance generated from the FileGroup
    # @example {include:file:spec/features/stanford/content_metadata_write_spec.rb}
    def generate_content_metadata(file_group, object_id, version_id)
      cm = Nokogiri::XML::Builder.new do |xml|
        xml.contentMetadata(:type => "sample", :objectId => object_id) do
          xml.resource(:type => "version", :sequence => "1", :id => "version-#{version_id}") do
            file_group.files.each do |file_manifestation|
              signature = file_manifestation.signature
              file_manifestation.instances.each do |instance|
                xml.file(
                  :id => instance.path,
                  :size => signature.size,
                  :datetime => instance.datetime,
                  :shelve => 'yes',
                  :publish => 'yes',
                  :preserve => 'yes'
                ) do
                  fixity = signature.fixity
                  xml.checksum(:type => "MD5") { xml.text signature.md5 } if fixity[:md5]
                  xml.checksum(:type => "SHA-1") { xml.text signature.sha1 } if fixity[:sha1]
                  xml.checksum(:type => "SHA-256") { xml.text signature.sha256 } if fixity[:sha256]
                end
              end
            end
          end
        end
      end
      cm.to_xml
    end

    # @param content_metadata [String,Nokogiri::XML::Document] The contentMetadata as a string or XML doc
    # @return [Boolean] True if contentMetadata has essential file attributes, else raise exception
    def validate_content_metadata(content_metadata)
      result = validate_content_metadata_details(content_metadata)
      raise Moab::InvalidMetadataException, result[0] + " ..." unless result.empty?
      true
    end

    # @param content_metadata [String, Nokogiri::XML::Document] The contentMetadata as a string or XML doc
    # @return [Array<String>] List of problems found
    def validate_content_metadata_details(content_metadata)
      result = []
      content_metadata_doc =
        case content_metadata.class.name
        when "String"
          Nokogiri::XML(content_metadata)
        when "Pathname"
          Nokogiri::XML(content_metadata.read)
        when "Nokogiri::XML::Document"
          content_metadata
        else
          raise Moab::InvalidMetadataException, "Content Metadata is in unrecognized format"
        end
      nodeset = content_metadata_doc.xpath("//file")
      nodeset.each do |file_node|
        missing = %w[id size md5 sha1]
        missing.delete('id') if file_node.has_attribute?('id')
        missing.delete('size') if file_node.has_attribute?('size')
        checksum_nodes = file_node.xpath('checksum')
        checksum_nodes.each do |checksum_node|
          case checksum_node.attributes['type'].content.upcase
          when 'MD5'
            missing.delete('md5')
          when 'SHA1', 'SHA-1'
            missing.delete('sha1')
          end
        end
        if missing.include?('id')
          result << "File node #{nodeset.index(file_node)} is missing #{missing.join(',')}"
        elsif !missing.empty?
          id = file_node['id']
          result << "File node having id='#{id}' is missing #{missing.join(',')}"
        end
      end
      result
    end

    # @param content_metadata [String] The contentMetadata as a string
    # @param content_group [FileGroup] The {FileGroup} object used as the fixity data source
    # @return [String] Returns a remediated copy of the contentMetadata with fixity data filled in
    # @see http://blog.slashpoundbang.com/post/1454850669/how-to-pretty-print-xml-with-nokogiri
    def remediate_content_metadata(content_metadata, content_group)
      return nil if content_metadata.nil?
      return content_metadata if content_group.nil? || content_group.files.empty?
      signature_for_path = content_group.path_hash
      @type_for_name = Moab::FileSignature.checksum_type_for_name
      @names_for_type = Moab::FileSignature.checksum_names_for_type
      ng_doc = Nokogiri::XML(content_metadata, &:noblanks)
      nodeset = ng_doc.xpath("//file")
      nodeset.each do |file_node|
        filepath = file_node['id']
        signature = signature_for_path[filepath]
        remediate_file_size(file_node, signature)
        remediate_checksum_nodes(file_node, signature)
      end
      ng_doc.to_xml(:indent => 2)
    end

    # @param [Nokogiri::XML::Element] file_node the File stanza being remediated
    # @param [FileSignature] signature the fixity data for the file from the FileGroup
    # @return [void] update the file size attribute if missing, raise exception if inconsistent
    def remediate_file_size(file_node, signature)
      file_size = file_node['size']
      if file_size.nil? || file_size.empty?
        file_node['size'] = signature.size.to_s
      elsif file_size != signature.size.to_s
        raise(Moab::MoabRuntimeError, "Inconsistent size for #{file_node['id']}: #{file_size} != #{signature.size}")
      end
    end

    # @param [Nokogiri::XML::Element] file_node the File stanza being remediated
    # @param [FileSignature] signature the fixity data for the file from the FileGroup
    # @return [void] update the file's checksum elements if data missing, raise exception if inconsistent
    def remediate_checksum_nodes(file_node, signature)
      # collect <checksum> elements for checksum types that are already present
      checksum_nodes = {}
      file_node.xpath('checksum').each do |checksum_node|
        type = @type_for_name[checksum_node['type']]
        checksum_nodes[type] = checksum_node
      end
      # add new <checksum> elements for the other checksum types that were missing
      @names_for_type.each do |type, names|
        unless checksum_nodes.key?(type)
          checksum_node = Nokogiri::XML::Element.new('checksum', file_node.document)
          checksum_node['type'] = names[0]
          file_node << checksum_node
          checksum_nodes[type] = checksum_node
        end
      end
      # make sure the <checksum> element has a content value
      checksum_nodes.each do |type, checksum_node|
        cm_checksum = checksum_node.content
        sig_checksum = signature.checksums[type]
        if cm_checksum.nil? || cm_checksum.empty?
          checksum_node.content = sig_checksum
        elsif cm_checksum != sig_checksum
          raise(Moab::MoabRuntimeError, "Inconsistent #{type} for #{file_node['id']}: #{cm_checksum} != #{sig_checksum}")
        end
      end
    end
  end
end
