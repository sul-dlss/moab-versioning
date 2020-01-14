# frozen_string_literal: true

module Stanford
  # Utility Class for extracting content or other information from a Fedora Instance
  #
  # ====Data Model
  # * {DorMetadata} = utility methods for interfacing with Stanford metadata files (esp contentMetadata)
  #   * {ContentInventory} [1..1] = utilities for transforming contentMetadata to versionInventory and doing comparisons
  #   * <b>{ActiveFedoraObject} [1..*] = utility for extracting content or other information from a Fedora Instance</b>
  #
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class ActiveFedoraObject
    # @param fedora_object [Object]  The Active Fedora representation of the Fedora Object
    # @return [Stanford::ActiveFedoraObject] Create a u
    def initialize(fedora_object)
      @fedora_object = fedora_object
    end

    # @return [Object]  The Active Fedora representation of the Fedora Object
    attr_accessor :fedora_object

    # @api external
    # @param ds_id [String] The datastream identifier
    # @return [String] The content of the specified datastream
    def get_datastream_content(ds_id)
      @fedora_object.datastreams[ds_id].content
    end
  end
end
