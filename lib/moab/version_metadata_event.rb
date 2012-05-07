require 'moab'

module Moab

  # A container element to record object version lifecycle events with timestamps
  #
  # ====Data Model
  # * {VersionMetadata} = descriptive information about a digital object's versions
  #   * {VersionMetadataEntry} [1..*] = attributes of a digital object version
  #     * <b>{VersionMetadataEvent} [1..*] = object version lifecycle events with timestamps</b>
  #
  # @see VersionMetadata
  # @see VersionMetadataEntry
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class VersionMetadataEvent < Serializable

    include HappyMapper

    # The name of the XML element used to serialize this objects data
    tag 'event'

    # (see Serializable#initialize)
    def initialize(opts={})
      super(opts)
    end

    # @attribute
    # @return [String] The type of event
    attribute :type, String


    # @attribute
    # @return [Time] The date and time of an event
    attribute :datetime, Time, :on_save => Proc.new {|t| t.to_s}

    def datetime=(event_datetime)
      @datetime=Time.input(event_datetime)
    end

    def datetime
      Time.output(@datetime)
    end

  end

end
