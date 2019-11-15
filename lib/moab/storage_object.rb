module Moab
  # A class to represent a digital object's repository storage location
  # and methods for
  # * packaging a bag for ingest of a new object version to the repository
  # * ingesting a bag
  # * disseminating a bag containing a reconstructed object version
  #
  # ====Data Model
  # * {StorageRepository} = represents a digital object repository storage node
  #   * {StorageServices} = supports application layer access to the repository's objects, data, and metadata
  #   * <b>{StorageObject} = represents a digital object's repository storage location and ingest/dissemination methods</b>
  #     * {StorageObjectVersion} [1..*] = represents a version subdirectory within an object's home directory
  #       * {Bagger} [1] = utility for creating bagit packages for ingest or dissemination
  #
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class StorageObject
    # @return [String] The digital object ID (druid)
    attr_accessor :digital_object_id

    # @return [Pathname] The location of the object's storage home directory
    attr_accessor :object_pathname

    # @return [Pathname] The location of the storage filesystem that contains (or will contain) the object
    attr_accessor :storage_root

    # @param object_id [String] The digital object identifier
    # @param object_dir [Pathname,String] The location of the object's storage home directory
    def initialize(object_id, object_dir, mkpath = false)
      @digital_object_id = object_id
      @object_pathname = Pathname.new(object_dir)
      initialize_storage if mkpath
    end

    # @return [Boolean] true if the object's storage directory exists
    def exist?
      @object_pathname.exist?
    end

    # @api external
    # @return [void] Create the directory for the digital object home unless it already exists
    def initialize_storage
      @object_pathname.mkpath
    end

    # @return [Pathname] The absolute location of the area in which bags are deposited
    def deposit_home
      storage_root.join(StorageServices.deposit_trunk)
    end

    # @return [Pathname] The absolute location of this object's deposit bag
    def deposit_bag_pathname
      deposit_home.join(StorageServices.deposit_branch(digital_object_id))
    end

    # @api external
    # @param bag_dir [Pathname,String] The location of the bag to be ingested
    # @return [void] Ingest a new object version contained in a bag into this objects storage area
    # @example {include:file:spec/features/storage/ingest_spec.rb}
    def ingest_bag(bag_dir = deposit_bag_pathname)
      bag_dir = Pathname(bag_dir)
      current_version = StorageObjectVersion.new(self, current_version_id)
      current_inventory = current_version.file_inventory('version')
      new_version = StorageObjectVersion.new(self, current_version_id + 1)
      if FileInventory.xml_pathname_exist?(bag_dir, 'version')
        new_inventory = FileInventory.read_xml_file(bag_dir, 'version')
      elsif current_version.version_id == 0
        new_inventory = versionize_bag(bag_dir, current_version, new_version)
      end
      validate_new_inventory(new_inventory)
      new_version.ingest_bag_data(bag_dir)
      new_version.update_catalog(current_version.signature_catalog, new_inventory)
      new_version.generate_differences_report(current_inventory, new_inventory)
      new_version.generate_manifest_inventory
      new_version
    end

    # @api internal
    # @param bag_dir [Pathname] The location of the bag to be ingested
    # @param current_version[StorageObjectVersion] The current latest version of the object
    # @param new_version [StorageObjectVersion] The version to be added
    # @return [FileInventory] The file inventory of the specified type for this version
    def versionize_bag(bag_dir, current_version, new_version)
      new_inventory = FileInventory.new(
        :type => 'version',
        :digital_object_id => @digital_object_id,
        :version_id => new_version.version_id,
        :inventory_datetime => Time.now
      )
      new_inventory.inventory_from_bagit_bag(bag_dir)
      new_inventory.write_xml_file(bag_dir)
      version_additions = current_version.signature_catalog.version_additions(new_inventory)
      version_additions.write_xml_file(bag_dir)
      new_inventory
    end

    # @api external
    # @param version_id [Integer] The version identifier of the object version to be disseminated
    # @param bag_dir [Pathname,String] The location of the bag to be created
    # @return [void] Reconstruct an object version and package it in a bag for dissemination
    # @example {include:file:spec/features/storage/reconstruct_spec.rb}
    def reconstruct_version(version_id, bag_dir)
      storage_version = StorageObjectVersion.new(self, version_id)
      version_inventory = storage_version.file_inventory('version')
      signature_catalog = storage_version.signature_catalog
      bagger = Bagger.new(version_inventory, signature_catalog, bag_dir)
      bagger.fill_bag(:reconstructor, @object_pathname)
    end

    # @param [String] catalog_filepath The object-relative path of the file
    # @return [Pathname] The absolute storage path of the file, including the object's home directory
    def storage_filepath(catalog_filepath)
      storage_filepath = @object_pathname.join(catalog_filepath)
      errmsg = "#{catalog_filepath} missing from storage location #{storage_filepath}"
      raise FileNotFoundException, errmsg unless storage_filepath.exist?
      storage_filepath
    end

    # @api external
    # @param version_id [Integer] The version identifier of an object version
    # @return [String] The directory name of the version, relative to the digital object home directory (e.g v0002)
    def self.version_dirname(version_id)
      format("v%04d", version_id)
    end

    # @return [Array<Integer>] The list of all version ids for this object
    def version_id_list
      list = []
      return list unless @object_pathname.exist?
      @object_pathname.children.each do |dirname|
        vnum = dirname.basename.to_s
        list << vnum[1..-1].to_i if vnum =~ /^v(\d+)$/
      end
      list.sort
    end

    # @return [Array<StorageObjectVersion>] The list of all versions in this storage object
    def version_list
      version_id_list.collect { |id| storage_object_version(id) }
    end
    alias versions version_list

    # @return [Boolean] true if there are no versions yet in this object
    def empty?
      version_id_list.empty?
    end

    # @api external
    # @return [Integer] The identifier of the latest version of this object, or 0 if no versions exist
    def current_version_id
      @current_version_id ||= version_id_list.last || 0
    end

    # @return [StorageObjectVersion] The most recent version in the storage object
    def current_version
      storage_object_version(current_version_id)
    end

    # @api internal
    # @param version_inventory [FileInventory] The inventory of the object version to be ingested
    # @return [Boolean] Tests whether the new version number is one higher than the current version number
    def validate_new_inventory(version_inventory)
      if version_inventory.version_id != (current_version_id + 1)
        raise(MoabRuntimeError, "version mismatch - current: #{current_version_id} new: #{version_inventory.version_id}")
      end
      true
    end

    # @api external
    # @param version_id [Integer] The existing version to return.  If nil, return latest version
    # @return [StorageObjectVersion] The representation of an existing version's storage area
    def find_object_version(version_id = nil)
      current = current_version_id
      case version_id
      when nil
        StorageObjectVersion.new(self, current)
      when 1..current
        StorageObjectVersion.new(self, version_id)
      else
        raise(MoabRuntimeError, "Version ID #{version_id} does not exist")
      end
    end

    # @api external
    # @param version_id [Integer] The version to return. OK if version does not exist
    # @return [StorageObjectVersion] The representation of a specified version.
    # * Version 0 is a special case used to generate empty manifests
    # * Current version + 1 is used for creation of a new version
    def storage_object_version(version_id)
      raise(MoabRuntimeError, "Version ID not specified") unless version_id
      StorageObjectVersion.new(self, version_id)
    end

    # @return [VerificationResult] Return result of storage verification
    def verify_object_storage
      result = VerificationResult.new(digital_object_id)
      version_list.each do |version|
        result.subentities << version.verify_version_storage
      end
      result.subentities << current_version.verify_signature_catalog
      result.verified = result.subentities.all?(&:verified)
      result
    end

    # @param recovery_path [Pathname, String] The location of the recovered object versions
    # @return [Boolean] Restore all recovered versions to online storage and verify results
    def restore_object(recovery_path)
      timestamp = Time.now
      recovery_object = StorageObject.new(@digital_object_id, recovery_path, false)
      recovery_object.versions.each do |recovery_version|
        version_id = recovery_version.version_id
        storage_version = storage_object_version(version_id)
        # rename/save the original
        storage_version.deactivate(timestamp)
        # copy the recovered version into place
        FileUtils.cp_r(recovery_version.version_pathname.to_s, storage_version.version_pathname.to_s)
      end
      self
    end

    # @return [Integer] the size occupied on disk by the storage object, in bytes.  this is the entire moab (all versions).
    def size
      size = 0
      Find.find(object_pathname) do |path|
        size += FileTest.size(path) unless FileTest.directory?(path)
      end
      size
    end
  end
end
