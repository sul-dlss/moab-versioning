require 'moab'

module Moab

  # A class to represent the SDR repository store
  #
  # ====Data Model
  # * <b>{StorageRepository} = represents a digital object repository storage node</b>
  #   * {StorageServices} = supports application layer access to the repository's objects, data, and metadata
  #   * {StorageObject} = represents a digital object's repository storage location and ingest/dissemination methods
  #     * {StorageObjectVersion} [1..*] = represents a version subdirectory within an object's home directory
  #       * {Bagger} [1] = utility for creating bagit packages for ingest or dissemination
  #
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class StorageRepository

   # @return [Pathname] The location of the root directory of the repository storage node
    def repository_home
      Pathname.new(Moab::Config.repository_home)
    end

    # @param object_id [String] The identifier of the digital object whose version is desired
    # @param version_id [Integer] The desired version
    # @return [StorageObjectVersion] The representation of the desired object version's storage directory
    def storage_object_version(object_id, version_id=nil)
      storage_object(object_id).storage_object_version(version_id)
    end

    # @param object_id [String] The identifier of the digital object whose version is desired
    # @return [StorageObject] The representation of the desired object storage directory
    def storage_object(object_id)
      StorageObject.new(object_id, storage_object_pathname(object_id))
    end

    # @param object_id [String] The identifier of the digital object whose version is desired
    # @return [Pathname] The location of the desired object's home directory
    def storage_object_pathname(object_id)
      #todo This method must be customized, or overrided in a superclass
    end

  end

end
