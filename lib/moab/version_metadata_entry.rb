require 'moab'

module Moab

  # The descriptive attributes of a digital object version.
  #
  # ====Data Model
  # * {VersionMetadata} = descriptive information about a digital object's versions
  #   * <b>{VersionMetadataEntry} [1..*] = attributes of a digital object version</b>
  #     * {VersionMetadataEvent} [1..*] = object version lifecycle events with timestamps
  #
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class VersionMetadataEntry < Serializer::Serializable

    include HappyMapper

    # The name of the XML element used to serialize this objects data
    tag 'version'

    # (see Serializable#initialize)
    def initialize(opts={})
      @events = Array.new
      super(opts)
    end

    # @attribute
    # @return [Integer] The object version number (A sequential integer)
    attribute :version_id, Integer, :tag => 'versionId', :key => true, :on_save => Proc.new {|n| n.to_s}

    # @attribute
    # @return [String] "an external version label that increments the most significant digit for major revisions,
    # second digit for minor revisions, and third for admin? e.g., 1.0, 1.1, 2.0, 2.0.1 etc.
    # This should be dynamically derivable across the set of versions
    attribute :label, String

    # @attribute
    # @return [String] "major|minor|admin"
    attribute :significance, String

    # @attribute
    # @return [String] A free text external description of why the version was created
    element :description, String

    # @attribute
    # @return [String] An internal annotation summarizing the changes (optional)
    element :note, String

    # @attribute
    # @return [FileGroupDifference] Summary of content file differences since previous version
    element :content_changes, FileGroupDifference, :tag => 'fileGroupDifference'

    # @attribute
    # @return [FileGroupDifference]   Summary of metadata file differences since previous version
    element :metadata_changes, FileGroupDifference, :tag => 'fileGroupDifference'

    # @attribute
    # @return [Array<VersionMetadataEvent>] Array of events with timestamps that track lifecycle stages
    has_many :events, VersionMetadataEvent, :tag => 'event'

  end

end
