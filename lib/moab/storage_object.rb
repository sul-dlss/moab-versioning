require 'moab'

module Moab

  # A class to represent a digital object's repository storage location
  # and methods for
  # * packaging a bag for ingest of a new object version to the repository
  # * ingesting a bag
  # * disseminating a bag containing a reconstructed object version
  #
  # ====Data Model
  # * <b>{StorageObject} = represents a digital object's repository storage location and ingest/dissemination methods</b>
  #   * {StorageObjectVersion} [1..*] = represents a version subdirectory within an object's home directory
  #     * {Bagger} [1] = utility for creating bagit packages for ingest or dissemination
  #
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class StorageObject

    # @param object_id [String] The digital object identifier
    # @param object_dir [Pathname,String] The location of the object's storage home directory
    def initialize(object_id, object_dir, mkpath=false)
      @digital_object_id = object_id
      @object_pathname = Pathname.new(object_dir)
      initialize_storage if mkpath
    end

    # @return [String] The digital object ID (druid)
    attr_accessor :digital_object_id

    # @return [Pathname] The location of the object's storage home directory
    attr_accessor :object_pathname

    # @api external
    # @return [void] Create the directory for the digital object home unless it already exists
    def initialize_storage
      @object_pathname.mkpath
    end

    # @api external
    # @param bag_dir [Pathname,String] The location of the bag to be ingested
    # @return [void] Ingest a new object version contained in a bag into this objects storage area
    # @example {include:file:spec/features/storage/ingest_spec.rb}
    def ingest_bag(bag_dir)
      current_version = StorageObjectVersion.new(self,current_version_id)
      current_inventory = current_version.file_inventory('version')
      new_version = StorageObjectVersion.new(self,current_version_id + 1)
      if FileInventory.xml_pathname_exist?(bag_dir,'version')
        new_inventory = FileInventory.read_xml_file(bag_dir,'version')
      elsif current_version.version_id == 0
        new_inventory = versionize_bag(bag_dir,current_version,new_version)
      end
      validate_new_inventory(new_inventory)
      new_version.ingest_bag_data(bag_dir)
      new_version.update_catalog(current_version.signature_catalog,new_inventory)
      new_version.generate_differences_report(current_inventory,new_inventory)
      new_version.inventory_manifests
      #update_tagmanifests(new_catalog_pathname)
    end

    # @api internal
    # @param bag_dir [Pathname] The location of the bag to be ingested
    # @param current_version[StorageObjectVersion] The current latest version of the object
    # @param new_version [StorageObjectVersion] The version to be added
    # @return [FileInventory] The file inventory of the specified type for this version
    def versionize_bag(bag_dir,current_version,new_version)
      new_inventory = FileInventory.new(
          :type=>'version',
          :digital_object_id=>@digital_object_id,
          :version_id=>new_version.version_id,
          :inventory_datetime => Time.now
      )
      new_inventory.inventory_from_directory(bag_dir.join('data'))
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
      storage_version = StorageObjectVersion.new(self,version_id)
      version_inventory = storage_version.file_inventory('version')
      signature_catalog = storage_version.signature_catalog
      bagger = Bagger.new(version_inventory, signature_catalog, @object_pathname, bag_dir)
      bagger.fill_bag(:reconstructor)
    end

    # @api external
    # @param version_id [Integer] The version identifier of an object version
    # @return [String] The directory name of the version, relative to the digital object home directory (e.g v0002)
    def self.version_dirname(version_id)
      ("v%04d" % version_id)
    end

    # @api external
    # @return [Integer] The identifier of the latest version of this object
    def current_version_id
      return @current_version_id unless @current_version_id.nil?
      version_id = 0
      @object_pathname.children.each do |dirname|
        vnum = dirname.basename.to_s
        if vnum.match /^v(\d+)$/
          v = vnum[1..-1].to_i
          version_id = v > version_id ? v : version_id
        end
      end
      @current_version_id = version_id
    end

    # @api internal
    # @param version_inventory [FileInventory] The inventory of the object version to be ingested
    # @return [Boolean] Tests whether the new version number is one higher than the current version number
    def validate_new_inventory(version_inventory)
      if version_inventory.version_id != (current_version_id + 1)
        raise "version mismatch - current: #{current_version_id} new: #{version_inventory.version_id}"
      end
      true
    end

    # @api external
    # @param version_id [Integer] The version to return.  If nil, return latest version
    # @return [StorageObjectVersion] The representation of the subdirectory for the specified version
    def storage_object_version(version_id=nil)
      if version_id
        StorageObjectVersion.new(self,version_id)
      else
        StorageObjectVersion.new(self,current_version_id)
      end
    end


  end

end
