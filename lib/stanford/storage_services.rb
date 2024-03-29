# frozen_string_literal: true

module Stanford
  # An interface class to support access to SDR storage via a RESTful server
  class StorageServices < Moab::StorageServices
    # @note After some discussion, consensus was that this is a thread safe use of a
    # class variable, as 1) it's never mutated after the class is initialized, and 2) the
    # value of the StorageRepository instance is determined from configuration that
    # rarely changes and is loaded once at app start time (at least in Stanford's
    # consumers; see Moab::Config.configure calls in preservation_robots, preservation_catalog,
    # and technical-metadata-service).
    # Sidekiq requires thread safe code, so please preserve thread safety for multiple
    # concurrent callers of this service if refactoring, so Sidekiq remains an option for
    # ActiveJob backend for moab-versioning consumers.
    @@repository = Stanford::StorageRepository.new

    # @return [StorageRepository] an instance of the interface to SDR storage
    def self.repository
      @@repository
    end

    # NOTE: `ShelvingService.content_diff` in dor-services-app implements similar logic, but in a way that
    # uses XML retrieved via preservation-client instead of reading the XML from disk.  This allows DSA to
    # perform the potentially time expensive diff without requiring access to preservation disk mounts.
    # See https://github.com/sul-dlss/dor-services-app/pull/4492 and https://github.com/sul-dlss/dor-services-app/issues/4359
    # @param new_content_metadata [String] The content metadata to be compared to the base
    # @param object_id [String] The digital object identifier of the object whose version inventory is the basis of the
    #  comparison
    # @param subset [String] Speciifes which subset of files to list in the inventories extracted from the
    #  contentMetadata (all|preserve|publish|shelve)
    # @param base_version [Integer] The ID of the version whose inventory is the basis of, if nil use latest version
    # @return [FileInventoryDifference] The report of differences between the content metadata and the specified version
    def self.compare_cm_to_version(new_content_metadata, object_id, subset, base_version = nil)
      new_inventory = Stanford::ContentInventory.new.inventory_from_cm(new_content_metadata, object_id, subset)
      begin
        # ObjectNotFoundException is raised if the object does not exist in storage
        base_version ||= current_version(object_id)
        # FileNotFoundException is raised if object exists but has no contentMetadata file
        base_cm_pathname = retrieve_file('metadata', 'contentMetadata.xml', object_id, base_version)
        base_inventory = Stanford::ContentInventory.new.inventory_from_cm(base_cm_pathname.read, object_id, subset, base_version)
      rescue Moab::ObjectNotFoundException, Moab::FileNotFoundException
        # Create a skeletal FileInventory object, containing no file entries
        storage_object = Moab::StorageObject.new(object_id, 'dummy')
        base_version = Moab::StorageObjectVersion.new(storage_object, 0)
        base_inventory = base_version.file_inventory('version')
      end
      diff = Moab::FileInventoryDifference.new.compare(base_inventory, new_inventory)
      metadata_diff = diff.group_difference('metadata')
      diff.group_differences.delete(metadata_diff) if metadata_diff
      diff
    end

    # @param new_content_metadata [String] The content metadata to be compared to the current signtature catalog
    # @param object_id [String] The digital object identifier of the object whose signature catalog is to be used
    # @param version_id [Integer] The ID of the version whose signature catalog is to be used, if nil use latest version
    # @return [FileInventory] The versionAddtions report showing which files are new or modified in the content metadata
    def self.cm_version_additions(new_content_metadata, object_id, version_id = nil)
      new_inventory = Stanford::ContentInventory.new.inventory_from_cm(new_content_metadata, object_id, 'preserve')
      begin
        # ObjectNotFoundException is raised if the object does not exist in storage
        version_id ||= current_version(object_id)
        storage_object_version = repository.storage_object(object_id).find_object_version(version_id)
        signature_catalog = storage_object_version.signature_catalog
      rescue Moab::ObjectNotFoundException
        storage_object = Moab::StorageObject.new(object_id, 'dummy')
        base_version = Moab::StorageObjectVersion.new(storage_object, 0)
        signature_catalog = base_version.signature_catalog
      end
      signature_catalog.version_additions(new_inventory)
    end

    # @param object_id [String] The digital object identifier of the object whose contentMetadata is to be remediated
    # @param version_id [Integer] The ID of the version whose file data is to be used, if nil use latest version
    # @return [String] Returns a remediated copy of the contentMetadata with fixity data filled in
    def self.cm_remediate(object_id, version_id = nil)
      cm = retrieve_file('metadata', 'contentMetadata.xml', object_id, version_id)
      group = retrieve_file_group('content', object_id, version_id)
      Stanford::ContentInventory.new.remediate_content_metadata(cm, group)
    end
  end
end
