require 'moab'

module Moab

  # An interface class to support access to SDR storage via a RESTful server
  #
  # ====Data Model
  # * {StorageRepository} = represents a digital object repository storage node
  #   * <b>{StorageServices} = supports application layer access to the repository's objects, data, and metadata</b>
  #   * {StorageObject} = represents a digital object's repository storage location and ingest/dissemination methods
  #     * {StorageObjectVersion} [1..*] = represents a version subdirectory within an object's home directory
  #       * {Bagger} [1] = utility for creating bagit packages for ingest or dissemination
  #
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class StorageServices

    # @return [StorageRepository] an instance of the interface to SDR storage
    @@repository = Moab::StorageRepository.new

    # @param object_id [String] The digital object identifier
    # @return [Integer] The version number of the currently highest version
    def self.current_version(object_id)
      @@repository.storage_object(object_id).current_version_id
    end

    # @param [String] object_id The digital object identifier of the object
    # @return [Pathname] Pathname object containing the full path for the specified file
    def self.version_metadata(object_id)
      self.retrieve_file('metadata', 'versionMetadata.xml', object_id)
    end

    # @param [String] file_category The category of file ('content', 'metdata', or 'manifest')
    # @param [String] file_id The name of the file (path relative to base directory)
    # @param [String] object_id The digital object identifier of the object
    # @param [Integer] version_id The ID of the version, if nil use latest version
    # @return [Pathname] Pathname object containing the full path for the specified file
    def self.retrieve_file(file_category, file_id, object_id, version_id=nil)
      storage_object_version = @@repository.storage_object(object_id).find_object_version(version_id)
      file_pathname = storage_object_version.find_filepath(file_category, file_id)
    end

    # @param [String] file_category The category of file ('content', 'metdata', or 'manifest')
    # @param [String] file_id The name of the file (path relative to base directory)
    # @param [String] object_id The digital object identifier of the object
    # @param [Integer] version_id The ID of the version, if nil use latest version
    # @return [Pathname] Pathname object containing the full path for the specified file
    def self.retrieve_file_signature(file_category, file_id, object_id, version_id=nil)
      storage_object_version = @@repository.storage_object(object_id).find_object_version(version_id)
      file_pathname = storage_object_version.find_signature(file_category, file_id)
    end

    # @param [String] object_id The digital object identifier of the object
    # @param [Object] base_version_id The identifier of the base version to be compared
    # @param [Object] compare_version_id The identifier of the version to be compared to the base version
    # @return [FileInventoryDifference] The report of the version differences
    def self.version_differences(object_id, base_version_id,compare_version_id)
      base_version = @@repository.storage_object(object_id).storage_object_version(base_version_id)
      compare_version = @@repository.storage_object(object_id).storage_object_version(compare_version_id)
      base_inventory=base_version.file_inventory('version')
      compare_inventory=compare_version.file_inventory('version')
      FileInventoryDifference.new.compare(base_inventory,compare_inventory)
    end

  end

end