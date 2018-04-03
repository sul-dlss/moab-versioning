require 'moab/stanford'

module Stanford
  # Stanford-specific utility methods for interfacing with DOR metadata files
  #
  # ====Data Model
  # * <b>{DorMetadata} = utility methods for interfacing with Stanford metadata files (esp contentMetadata)</b>
  #   * {ContentInventory} [1..1] = utilities for transforming contentMetadata to versionInventory and doing comparisons
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
    def initialize(digital_object_id, version_id = nil)
      @digital_object_id = digital_object_id
      @version_id = version_id
    end

    # @api internal
    # @param directory [String] The location of the directory to be inventoried
    # @param version_id (see #initialize)
    # @return [FileInventory]  Inventory of the files under the specified directory
    def inventory_from_directory(directory, version_id = nil)
      version_id ||= @version_id
      version_inventory = Moab::FileInventory.new(type: 'version', digital_object_id: @digital_object_id, version_id: version_id)
      content_metadata = IO.read(File.join(directory, 'contentMetadata.xml'))
      content_group = Stanford::ContentInventory.new.group_from_cm(content_metadata, 'preserve')
      version_inventory.groups << content_group
      metadata_group = Moab::FileGroup.new(:group_id => 'metadata').group_from_directory(directory)
      version_inventory.groups << metadata_group
      version_inventory
    end
  end
end
