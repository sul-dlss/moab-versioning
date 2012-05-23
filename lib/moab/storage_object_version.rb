require 'moab'

module Moab

  # A class to represent a version subdirectory within an object's home directory in preservation storage
  #
  # ====Data Model
  # * {StorageRepository} = represents a digital object repository storage node
  #   * {StorageServices} = supports application layer access to the repository's objects, data, and metadata
  #   * {StorageObject} = represents a digital object's repository storage location and ingest/dissemination methods
  #     * <b>{StorageObjectVersion} [1..*] = represents a version subdirectory within an object's home directory</b>
  #       * {Bagger} [1] = utility for creating bagit packages for ingest or dissemination
  #
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class StorageObjectVersion

    # @return [Integer] The ordinal version number
    attr_accessor :version_id

    # @return [String] The "v0001" directory name derived from the version id
    attr_accessor :version_name

    # @return [Pathname] The location of the version inside the home directory
    attr_accessor :version_pathname

    # @return [Pathname] The location of the object's home directory
    attr_accessor :storage_object

  # @param storage_object [StorageObject] The object representing the digital object's storage location
  # @param version_id [Integer] The ordinal version number
    def initialize(storage_object, version_id)
      @version_id = version_id
      @version_name = StorageObject.version_dirname(version_id)
      @version_pathname = storage_object.object_pathname.join(@version_name)
      @storage_object=storage_object
    end

  # @param [String] file_category The category of file (:content, :metdata, or :manifest)
  # @param [String] file_id The relative path of the file (relative to the appropriate home directory)
  # @return [Pathname] Pathname object containing the full path for the specified file
    def find_filepath(file_category, file_id)
      this_version_filepath = file_pathname(file_category, file_id)
      return this_version_filepath if this_version_filepath.exist?
      raise "manifest file #{file_id} not found for #{@storage_object.digital_object_id} - #{@version_id}" if file_category == :manifest
      file_signature = file_inventory('version').file_signature(file_category, file_id)
      catalog_filepath = signature_catalog.catalog_filepath(file_signature)
      @storage_object.storage_filepath(catalog_filepath)
    end

  # @param [String] file_category The category of file ('content', 'metdata', or 's')
  # @param [String] file_id The relative path of the file (relative to the appropriate home directory)
  # @return [Pathname] Pathname object containing this version's storage path for the specified file
    def file_pathname(file_category, file_id)
      case file_category
        when 'manifest'
          @version_pathname.join(file_id)
        else
          @version_pathname.join('data',file_category, file_id)
      end
    end


    # @api external
    # @param type [String] The type of inventory to return (version|additions|manifests)
    # @return [FileInventory] The file inventory of the specified type for this version
    # @see FileInventory#read_xml_file
    def file_inventory(type)
      if version_id > 0
        FileInventory.read_xml_file(@version_pathname, type)
      else
        groups = ['content','metadata'].collect { |id| FileGroup.new(:group_id=>id)}
        FileInventory.new(
            :type=>'version',
            :digital_object_id => @storage_object.digital_object_id,
            :version_id => @version_id,
            :groups => groups
        )
      end
    end

    # @api external
    # @return [SignatureCatalog] The signature catalog of the digital object as of this version
    def signature_catalog
      if version_id > 0
        SignatureCatalog.read_xml_file(@version_pathname)
      else
        SignatureCatalog.new(:digital_object_id => @storage_object.digital_object_id)
      end
    end

    # @api internal
    # @param bag_dir [Pathname,String] The location of the bag to be ingested
    # @return [void] Create the version subdirectory and move files into it
    def ingest_bag_data(bag_dir)
      raise "Version already exists: #{@version_pathname.to_s}" if @version_pathname.exist?
      @version_pathname.mkpath
      bag_dir=Pathname(bag_dir)
      ingest_dir(bag_dir.join('data'),@version_pathname.join('data'))
      ingest_file(bag_dir.join(FileInventory.xml_filename('version')),@version_pathname)
      ingest_file(bag_dir.join(FileInventory.xml_filename('additions')),@version_pathname)
    end

    # @api internal
    # @param source_dir [Pathname] The source location of the directory whose contents are to be ingested
    # @param target_dir [Pathname] The target location of the directory into which files are ingested
    # @param use_links [Boolean] If true, use hard links; if false, make copies
    # @return [void] recursively link or copy the source directory contents to the target directory
    def ingest_dir(source_dir, target_dir, use_links=true)
      raise "cannot copy - target already exists: #{target_dir.realpath}" if target_dir.exist?
      target_dir.mkpath
      source_dir.children.each do |child|
        if child.directory?
          ingest_dir(child, target_dir.join(child.basename), use_links)
        else
          ingest_file(child, target_dir, use_links)
        end
      end
    end

    # @api internal
    # @param source_file [Pathname] The source location of the file to be ingested
    # @param target_dir [Pathname] The location of the directory in which to place the file
    # @param use_links [Boolean] If true, use hard links; if false, make copies
    # @return [void] link or copy the specified file from source location to the version directory
    def ingest_file(source_file, target_dir, use_links=true)
      if use_links
        FileUtils.link(source_file.to_s, target_dir.to_s) #, :force => true)
      else
        FileUtils.copy(source_file.to_s, target_dir.to_s)
      end
    end

    # @api internal
    # @param signature_catalog [SignatureCatalog] The current version's catalog
    # @param new_inventory [FileInventory] The new version's inventory
    # @return [void] Updates the catalog to include newly added files, then saves it to disk
    # @see SignatureCatalog#update
    def update_catalog(signature_catalog,new_inventory)
      signature_catalog.update(new_inventory)
      signature_catalog.write_xml_file(@version_pathname)
    end

    # @api internal
    # @param old_inventory [FileInventory] The old version's inventory
    # @param new_inventory [FileInventory] The new version's inventory
    # @return [void] generate a file inventory differences report and save to disk
    def generate_differences_report(old_inventory,new_inventory)
      differences = FileInventoryDifference.new.compare(old_inventory, new_inventory)
      differences.write_xml_file(@version_pathname)
    end

    # @api internal
    # @return [void] examine the version's directory and create/serialize a {FileInventory} containing the manifest files
    def inventory_manifests
      manifest_inventory = FileInventory.new(
          :type=>'manifests',
          :digital_object_id=>@storage_object.digital_object_id,
          :version_id=>@version_id)
      manifest_inventory.groups << FileGroup.new(:group_id=>'manifests').group_from_directory(@version_pathname, recursive=false)
      manifest_inventory.write_xml_file(@version_pathname)
    end

  end

end
