# frozen_string_literal: true

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

    def self.repository
      @@repository
    end

    # @return [Array<Pathname>] A list of the filesystems currently used for storage
    def self.storage_roots
      @@repository.storage_roots
    end

    # @return [String] The trunk segment of the object deposit path
    def self.deposit_trunk
      @@repository.deposit_trunk
    end

    # @param object_id [String] The identifier of the digital object
    # @return [Pathname] The branch segment of the object deposit path
    def self.deposit_branch(object_id)
      @@repository.deposit_branch(object_id)
    end

    # @param object_id [String] The identifier of the digital object
    # @param [Object] include_deposit
    # @return [StorageObject] The representation of a digitial object's  storage directory, which might not exist yet.
    def self.find_storage_object(object_id, include_deposit = false)
      @@repository.find_storage_object(object_id, include_deposit)
    end

    # @param object_id [String] The identifier of the digital object
    # @param [Object] include_deposit
    # @return [Array<StorageObject>] Representations of a digitial object's storage directories, or an empty array if none found.
    def self.search_storage_objects(object_id, include_deposit = false)
      @@repository.search_storage_objects(object_id, include_deposit)
    end

    # @param object_id [String] The identifier of the digital object whose size is desired
    # @param include_deposit [Boolean] specifies whether to look in deposit areas for objects in process of initial ingest
    # @return [Integer] the size occupied on disk by the storage object, in bytes.  this is the entire moab (all versions).
    def self.object_size(object_id, include_deposit = false)
      @@repository.object_size(object_id, include_deposit)
    end

    # @param object_id [String] The identifier of the digital object whose version is desired
    # @param create [Boolean] If true, the object home directory should be created if it does not exist
    # @return [StorageObject] The representation of a digitial object's storage directory, which must exist.
    def self.storage_object(object_id, create = false)
      @@repository.storage_object(object_id, create)
    end

    # @param object_id [String] The digital object identifier of the object
    # @return [String] the location of the storage object
    def self.object_path(object_id)
      @@repository.storage_object(object_id).object_pathname.to_s
    end

    # @param object_id [String] The digital object identifier of the object
    # @param [Integer] version_id The ID of the version, if nil use latest version
    # @return [String] the location of the storage object version
    def self.object_version_path(object_id, version_id = nil)
      @@repository.storage_object(object_id).find_object_version(version_id).version_pathname.to_s
    end

    # @param object_id [String] The digital object identifier
    # @return [Integer] The version number of the currently highest version
    def self.current_version(object_id)
      @@repository.storage_object(object_id).current_version_id
    end

    # @param [String] object_id The digital object identifier of the object
    # @return [Pathname] Pathname object containing the full path for the specified file
    def self.version_metadata(object_id)
      retrieve_file('metadata', 'versionMetadata.xml', object_id)
    end

    # @param [String] object_id The digital object identifier of the object
    # @param [Integer] version_id The ID of the version, if nil use latest version
    # @return [FileInventory] the file inventory for the specified object version
    def self.retrieve_file_group(file_category, object_id, version_id = nil)
      storage_object_version = @@repository.storage_object(object_id).find_object_version(version_id)
      inventory_type = if file_category =~ /manifest/
                         file_category = 'manifests'
                       else
                         'version'
                       end
      inventory = storage_object_version.file_inventory(inventory_type)
      inventory.group(file_category)
    end

    # @param [String] file_category The category of file ('content', 'metdata', or 'manifest')
    # @param [String] file_id The name of the file (path relative to base directory)
    # @param [String] object_id The digital object identifier of the object
    # @param [Integer] version_id The ID of the version, if nil use latest version
    # @return [Pathname] Pathname object containing the full path for the specified file
    def self.retrieve_file(file_category, file_id, object_id, version_id = nil)
      storage_object_version = @@repository.storage_object(object_id).find_object_version(version_id)
      file_pathname = storage_object_version.find_filepath(file_category, file_id)
    end

    # @param [String] file_category The category of file ('content', 'metdata', or 'manifest')
    # @param [FileSignature] file_signature The signature of the file
    # @param [String] object_id The digital object identifier of the object
    # @param [Integer] version_id The ID of the version, if nil use latest version
    # @return [Pathname] Pathname object containing the full path for the specified file
    def self.retrieve_file_using_signature(file_category, file_signature, object_id, version_id = nil)
      storage_object_version = @@repository.storage_object(object_id).find_object_version(version_id)
      file_pathname = storage_object_version.find_filepath_using_signature(file_category, file_signature)
    end

    # @param [String] file_category The category of file ('content', 'metdata', or 'manifest')
    # @param [String] file_id The name of the file (path relative to base directory)
    # @param [String] object_id The digital object identifier of the object
    # @param [Integer] version_id The ID of the version, if nil use latest version
    # @return [FileSignature] The signature of the file
    def self.retrieve_file_signature(file_category, file_id, object_id, version_id = nil)
      storage_object_version = @@repository.storage_object(object_id).find_object_version(version_id)
      file_pathname = storage_object_version.find_signature(file_category, file_id)
    end

    # @param [String] object_id The digital object identifier of the object
    # @param [Object] base_version_id The identifier of the base version to be compared
    # @param [Object] compare_version_id The identifier of the version to be compared to the base version
    # @return [FileInventoryDifference] The report of the version differences
    def self.version_differences(object_id, base_version_id, compare_version_id)
      base_version = @@repository.storage_object(object_id).storage_object_version(base_version_id)
      compare_version = @@repository.storage_object(object_id).storage_object_version(compare_version_id)
      base_inventory = base_version.file_inventory('version')
      compare_inventory = compare_version.file_inventory('version')
      FileInventoryDifference.new.compare(base_inventory, compare_inventory)
    end
  end
end
