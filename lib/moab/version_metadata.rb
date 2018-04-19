module Moab
  # The descriptive information about a digital object's collection of versions
  #
  # ====Data Model
  # * <b>{VersionMetadata} = descriptive information about a digital object's versions</b>
  #   * {VersionMetadataEntry} [1..*] = attributes of a digital object version
  #     * {VersionMetadataEvent} [1..*] = object version lifecycle events with timestamps
  #
  # @example {include:file:spec/fixtures/data/jq937jp0017/v3/metadata/versionMetadata.xml}
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class VersionMetadata < Serializer::Manifest
    include HappyMapper

    # The name of the XML element used to serialize this objects data
    tag 'versionMetadata'

    # (see Serializable#initialize)
    def initialize(opts = {})
      @versions = []
      super(opts)
    end

    # @attribute
    # @return [String] The digital object identifier
    attribute :digital_object_id, String, :tag => 'objectId'

    # @attribute
    # @return [Array<VersionMetadataEntry>] An array of version metadata entries, one per version
    has_many :versions, VersionMetadataEntry, :tag => 'version'
  end
end
