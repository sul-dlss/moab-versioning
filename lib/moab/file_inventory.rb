require 'moab'

module Moab

  # A structured container for recording information about a collection of related files.
  #
  # The <b>scope</b> of the file collection depends on inventory type:
  # * <i>version</i> = full set of data files comprising a digital object's version
  # * <i>additions</i> = subset of data files that were newly added in the specified version
  # * <i>manifests</i> = the fixity data for manifest files in the version's root folder
  # * <i>directory</i> = set of files that were harvested from a filesystem directory
  #
  # The inventory contains one or more {FileGroup} subsets, which are most commonly used
  # to provide segregation of digital object version's <i>content</i> and <i>metadata</i> files.
  # Each group contains one or more {FileManifestation} entities,
  # each of which represents a point-in-time snapshot of a given file's filesystem characteristics.
  # The fixity data for a file is stored in a {FileSignature} element,
  # while the filename and modification data are stored in one or more {FileInstance} elements.
  # (Copies of a given file may be present in multiple locations in a collection)
  #
  # ====Data Model
  # * <b>{FileInventory} = container for recording information about a collection of related files</b>
  #   * {FileGroup} [1..*] = subset allow segregation of content and metadata files
  #     * {FileManifestation} [1..*] = snapshot of a file's filesystem characteristics
  #       * {FileSignature} [1] = file fixity information
  #       * {FileInstance} [1..*] = filepath and timestamp of any physical file having that signature
  #
  # @example {include:file:spec/fixtures/derivatives/manifests/v3/versionInventory.xml}
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class FileInventory < Manifest

    include HappyMapper

    # The name of the XML element used to serialize this object's data
    tag 'fileInventory'

    # (see Serializable#initialize)
    def initialize(opts={})
      @groups = Array.new
      @inventory_datetime = Time.now
      super(opts)
    end

    # @attribute
    # @return [String] The type of inventory (version|additions|manifests|directory)
    attribute :type, String

    # @attribute
    # @return [String] The digital object identifier (druid)
    attribute :digital_object_id, String, :tag => 'objectId'

    # @attribute
    # @return [Integer] The ordinal version number
    attribute :version_id, Integer, :tag => 'versionId', :key => true, :on_save => Proc.new {|n| n.to_s}

    # @return [String] The unique identifier concatenating digital object id with version id
    def composite_key
      @digital_object_id + '-' + StorageObject.version_dirname(@version_id)
    end

    # @attribute
    # @return [String] The datetime at which the inventory was created
    attribute :inventory_datetime, String, :tag => 'inventoryDatetime'

    def inventory_datetime=(datetime)
      @inventory_datetime=UtcTime.input(datetime)
    end

    def inventory_datetime
      UtcTime.output(@inventory_datetime)
    end

    # @attribute
    # @return [Integer] The total number of data files in the inventory (dynamically calculated)
    attribute :file_count, Integer, :tag => 'fileCount', :on_save => Proc.new {|t| t.to_s}

    def file_count
      groups.inject(0) { |sum, group| sum + group.file_count }
    end

     # @attribute
    # @return [Integer] The total size (in bytes) in all files of all files in the inventory (dynamically calculated)
    attribute :byte_count, Integer, :tag => 'byteCount', :on_save => Proc.new {|t| t.to_s}

    def byte_count
      groups.inject(0) { |sum, group| sum + group.byte_count }
    end

    # @attribute
    # @return [Integer] The total disk usage (in 1 kB blocks) of all data files (estimating du -k result) (dynamically calculated)
    attribute :block_count, Integer, :tag => 'blockCount', :on_save => Proc.new {|t| t.to_s}

    def block_count
      groups.inject(0) { |sum, group| sum + group.block_count }
    end

    # @attribute
    # @return [Array<FileGroup>] The set of data groups comprising the version
    has_many :groups, FileGroup, :tag => 'fileGroup'

    # @return [Array<FileGroup] The set of data groups that contain files
    def non_empty_groups
      @groups.select{|group| !group.files.empty?}
    end

    # @param non_empty [Boolean] if true, return group_id's only for groups having files
    # @return [Array<String>] group identifiers contained in this file inventory
    def group_ids(non_empty=nil)
      groups = non_empty ? self.non_empty_groups : @groups
      groups.map{|group| group.group_id}
    end

    # @param [String] group_id The identifer of the group to be selected
    # @return [FileGroup] The file group in this inventory for the specified group_id
    def group(group_id)
      @groups.find{ |group| group.group_id == group_id}
    end

    # @param group_id [String] File group identifer (e.g. data, metadata, manifests)
    # @return [Boolean] true if the group is missing or empty
    def group_empty?(group_id)
      group = self.group(group_id)
      group.nil? or group.files.empty?
    end

    # @return [Array<String>] The data fields to include in summary reports
    def summary_fields
      %w{type digital_object_id version_id inventory_datetime file_count byte_count block_count groups}
    end

    # @param [String] group_id The identifer of the group to be selected
    # @param [String] file_id The group-relative path of the file (relative to the appropriate home directory)
    # @return [FileSignature] The signature of the specified file
    def file_signature(group_id, file_id)
      file_group = group(group_id)
      raise FileNotFoundException, "group #{group_id} not found for #{@digital_object_id} - #{@version_id}" if file_group.nil?
      file_signature = file_group.path_hash[file_id]
      raise FileNotFoundException, "#{group_id} file #{file_id} not found for #{@digital_object_id} - #{@version_id}" if file_signature.nil?
      file_signature
    end

    # @api internal
    # @param other [FileInventory] another instance of this class from which to clone identity values
    # @return [void] Copy objectId and versionId values from another class instance into this instance
    def copy_ids(other)
      @digital_object_id = other.digital_object_id
      @version_id = other.version_id
      @inventory_datetime = other.inventory_datetime
    end

    # @api internal
    # @return [String] Concatenation of the objectId and versionId values
    def package_id
      "#{@digital_object_id}-v#{@version_id}"
    end

    # @api internal
    # @return [String] Returns either the version ID (if inventory is a version manifest) or the name of the directory that was harvested to create the inventory
    def data_source
      data_source = (groups.collect { |g| g.data_source.to_s }).join('|')
      if data_source.start_with?('contentMetadata')
        if version_id
          "v#{version_id.to_s}-#{data_source}"
        else
          "new-#{data_source}"
        end
      else
        if version_id
          "v#{version_id.to_s}"
        else
          data_source
        end

      end
    end

    # @api external
    # @param data_dir [Pathname,String] The location of files to be inventoried
    # @param group_id [String] if specified, is used to set the group ID of the FileGroup created from the directory
    #   if nil, then the directory is assumed to contain both content and metadata subdirectories
    # @return [FileInventory] Traverse a directory and return an inventory of the files it contains
    # @example {include:file:spec/features/inventory/harvest_inventory_spec.rb}
    def inventory_from_directory(data_dir,group_id=nil)
      if group_id
        @groups << FileGroup.new(:group_id=>group_id).group_from_directory(data_dir)
      else
        ['content','metadata'].each do |group_id|
          @groups << FileGroup.new(:group_id=>group_id).group_from_directory(Pathname(data_dir).join(group_id))
        end
      end
      self
    end

    # @param  bag_dir [Pathname,String] The location of the BagIt bag to be inventoried
    # @return [FileInventory] Traverse a BagIt bag's payload and return an inventory of the files it contains (using fixity from bag manifest files)
    def inventory_from_bagit_bag(bag_dir)
      bag_pathname = Pathname(bag_dir)
      signatures_from_bag = signatures_from_bagit_manifests(bag_pathname)
      bag_data_subdirs = bag_pathname.join('data').children
      bag_data_subdirs.each do |subdir|
        @groups << FileGroup.new(:group_id=>subdir.basename.to_s).group_from_bagit_subdir(subdir, signatures_from_bag)
      end
      self
    end

    # @param  bag_pathname [Pathname] The location of the BagIt bag to be inventoried
    # @return [Hash<Pathname,FileSignature>] The fixity data present in the bag's manifest files
    def signatures_from_bagit_manifests(bag_pathname)
      manifest_pathname = Hash.new
      checksum_types =  [:md5, :sha1, :sha256]
      checksum_types.each do |type|
        manifest_pathname[type] = bag_pathname.join("manifest-#{type.to_s}.txt")
      end
      signatures = Hash.new { |hash,path| hash[path] = FileSignature.new }
      checksum_types.each do |type|
        if manifest_pathname[type].exist?
          manifest_pathname[type].each_line do |line|
            line.chomp!
            checksum,data_path = line.split(/\s+\**/,2)
            if checksum && data_path
              file_pathname = bag_pathname.join(data_path)
              signature = signatures[file_pathname]
              signature.set_checksum(type, checksum)
            end
          end
        end
      end
      signatures.each {|file_pathname,signature| signature.size = file_pathname.size}
      signatures
    end

    # @api internal
    # @return [String] The total size of the inventory expressed in KB, MB, GB or TB, depending on the magnitutde of the value
    def human_size
      count = 0
      size = byte_count
      while size >= 1024 and count < 4
        size /= 1024.0
        count += 1
      end
      if count == 0
        sprintf("%d B", size)
      else
        sprintf("%.2f %s", size, %w[B KB MB GB TB][count])
      end
    end

    # @api internal
    # @param type [String] Specifies the type of inventory, and thus the filename used for storage
    # @return [String] The standard name for the serialized inventory file of the given type
    def self.xml_filename(type=nil)
      case type
        when "version"
          'versionInventory.xml'
        when "additions"
          'versionAdditions.xml'
        when "manifests"
          'manifestInventory.xml'
        when "directory"
          'directoryInventory.xml'
        else
          raise "unknown inventory type: #{type.to_s}"
      end
    end

    # @api external
    # @param parent_dir [Pathname,String] The parent directory in which the xml file is to be stored
    # @param type [String] The inventory type, which governs the filename used for serialization
    # @return [void] write the {FileInventory} instance to a file
    # @example {include:file:spec/features/inventory/write_inventory_xml_spec.rb}
    def write_xml_file(parent_dir, type=nil)
      type = @type if type.nil?
      self.class.write_xml_file(self, parent_dir, type)
    end

  end

end
