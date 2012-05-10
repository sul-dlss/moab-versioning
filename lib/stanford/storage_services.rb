require 'moab_stanford'

module Stanford

  # An interface class to support access to SDR storage via a RESTful server
  class StorageServices

  # @return [StorageRepository] an instance of the interface to SDR storage
  @@repository = StorageRepository.new

  # @param content_metadata [String] The content metadata to be compared
  # @param object_id [String] The digital object identifier of the object whose version inventory is the basis of the comparison
  # @param version_id [Integer] The ID of the version whose inventory is to be compared, if nil use latest version
  # @return [FileInventoryDifference] The report of differences between the content metadata and the specified version
  def self.compare_cm_to_version_inventory(content_metadata, object_id, version_id=nil)
    cm_inventory = ContentInventory.new.inventory_from_cm(content_metadata, object_id)
    storage_object_version = @@repository.storage_object_version(object_id,version_id)
    version_inventory = storage_object_version.file_inventory('version')
    FileInventoryDifference.new.compare(version_inventory,cm_inventory)
  end

  # @param content_metadata [String] The content metadata to be evaluated
  # @param object_id [String] The digital object identifier of the object whose signature catalog is to be used
  # @param version_id [Integer] The ID of the version whose signature catalog is to be used, if nil use latest version
  # @return [FileInventory] The versionAddtions report showing which files are new or modified in the content metadata
  def self.cm_version_additions(content_metadata, object_id, version_id=nil)
    cm_inventory = ContentInventory.new.inventory_from_cm(content_metadata, object_id)
    storage_object_version = @@repository.storage_object_version(object_id,version_id)
    signature_catalog = storage_object_version.signature_catalog
    signature_catalog.version_additions(cm_inventory)
  end

  end

end