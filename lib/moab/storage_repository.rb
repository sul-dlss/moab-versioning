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
    # @return [StorageObject] The representation of the desired object storage directory
    def storage_object(object_id, create=false)
      object_pathname = storage_object_pathname(object_id)
      if object_pathname.exist?
        StorageObject.new(object_id, object_pathname)
      elsif create
        object_pathname.mkpath
        StorageObject.new(object_id, object_pathname)
      else
        raise Moab::ObjectNotFoundException, "No object found for #{object_id} at #{object_pathname}"
      end
    end

    # @param object_id [String] The identifier of the digital object whose version is desired
    # @return [Pathname] The location of the desired object's home directory (default=pairtree)
    def storage_object_pathname(object_id)
      #todo This method should be customized, or overridden in a subclass
      # for a more sophisticated pairtree implementation see https://github.com/microservices/pairtree
      path_segments = object_id.scan(/..?/) << object_id
      object_path = path_segments.join(File::SEPARATOR).gsub(/:/,'_')
      repository_home.join(object_path)
    end

    # @param druid [String] The object identifier
    # @return [void] transfer the object to the preservation repository
    def store_new_object_version(druid, bag_pathname )
      storage_object = self.storage_object(druid, create=true)
      storage_object.ingest_bag(bag_pathname)
    end

    # @param [String] druid The object identifier
    # @param [Integer] version_id the version to be verified, if nil, latest current version will be assumed
    # @return [Boolean] return true if data files on disk are consistent with inventory files
    def verify_version_storage(druid, version_id=nil)
      storage_object = self.storage_object(druid)
      version_id ||= storage_object.current_version_id
      version = StorageObjectVersion.new(storage_object,version_id )
      version.verify_version_additions &&
      version.verify_version_inventory
    end

  end

end
