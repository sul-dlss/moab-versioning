# frozen_string_literal: true

module Moab
  # A class used to create a BagIt package from a version inventory and a set of source files.
  # The {#fill_bag} method is called with a package_mode parameter that specifies
  # whether the bag is being created for deposit into the repository or is to contain the output of a version reconstruction.
  # * In <b>:depositor</b> mode, the version inventory is filtered using the digital object's signature catalog so that only
  #  new files are included
  # * In <b>:reconstructor</b> mode, the version inventory and signature catalog are used together to regenerate the complete
  #  set of files for the version.
  #
  # ====Data Model
  # * {StorageRepository} = represents a digital object repository storage node
  #   * {StorageServices} = supports application layer access to the repository's objects, data, and metadata
  #   * {StorageObject} = represents a digital object's repository storage location and ingest/dissemination methods
  #     * {StorageObjectVersion} [1..*] = represents a version subdirectory within an object's home directory
  #       * <b>{Bagger} [1] = utility for creating bagit packages for ingest or dissemination</b>
  #
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class Bagger
    # @param version_inventory [FileInventory] The complete inventory of the files comprising a digital object version
    # @param signature_catalog [SignatureCatalog] The signature catalog, used to specify source paths (in :reconstructor mode),
    #   or to filter the version inventory (in :depositor mode)
    # @param bag_pathname [Pathname,String] The location of the Bagit bag to be created
    def initialize(version_inventory, signature_catalog, bag_pathname)
      @version_inventory = version_inventory
      @signature_catalog = signature_catalog
      @bag_pathname = Pathname.new(bag_pathname)
      create_bagit_txt
    end

    # @return [FileInventory] The complete inventory of the files comprising a digital object version
    attr_accessor :version_inventory

    # @return [SignatureCatalog] The signature catalog, used to specify source paths (in :reconstructor mode),
    #   or to filter the version inventory (in :depositor mode)
    attr_accessor :signature_catalog

    # @return [Pathname] The location of the Bagit bag to be created
    attr_accessor :bag_pathname

    # @return [FileInventory] The actual inventory of the files to be packaged (derived from @version_inventory in {#fill_bag})
    attr_accessor :bag_inventory

    # @return [Symbol] The operational mode controlling what gets bagged {#fill_bag}
    #   and the full path of source files {#fill_payload}
    attr_accessor :package_mode

    # @return [void] Delete any existing bag data and re-initialize the bag directory
    def reset_bag
      delete_bag
      delete_tarfile
      create_bagit_txt
    end

    # @api internal
    # @return [void] Generate the bagit.txt tag file
    def create_bagit_txt
      bag_pathname.mkpath
      bag_pathname.join('bagit.txt').open('w') do |f|
        f.puts 'Tag-File-Character-Encoding: UTF-8'
        f.puts 'BagIt-Version: 0.97'
      end
    end

    # @return [NilClass] Delete the bagit files
    def delete_bag
      # make sure this looks like a bag before deleting
      bag_pathname.rmtree if bag_pathname.join('bagit.txt').exist?
      nil
    end

    # @param tar_pathname [Pathname] The location of the tar file (default is based on bag location)
    def delete_tarfile
      bag_name = bag_pathname.basename
      bag_parent = bag_pathname.parent
      tar_pathname = bag_parent.join("#{bag_name}.tar")
      tar_pathname.delete if tar_pathname.exist?
    end

    # @api external
    # @param package_mode [Symbol] The operational mode controlling what gets bagged and the full path of
    #   source files (Bagger#fill_payload)
    # @param source_base_pathname [Pathname] The home location of the source files
    # @return [Bagger] Perform all the operations required to fill the bag payload, write the manifests and
    #   tagfiles, and checksum the tagfiles
    # @example {include:file:spec/features/storage/deposit_spec.rb}
    def fill_bag(package_mode, source_base_pathname)
      create_bag_inventory(package_mode)
      fill_payload(source_base_pathname)
      create_tagfiles
      self
    end

    # @api external
    # @param package_mode [Symbol] The operational mode controlling what gets bagged and the full path of
    #   source files (Bagger#fill_payload)
    # @return [FileInventory] Create, write, and return the inventory of the files that will become the payload
    def create_bag_inventory(package_mode)
      @package_mode = package_mode
      bag_pathname.mkpath
      case package_mode
      when :depositor
        version_inventory.write_xml_file(bag_pathname, 'version')
        @bag_inventory = signature_catalog.version_additions(version_inventory)
        bag_inventory.write_xml_file(bag_pathname, 'additions')
      when :reconstructor
        @bag_inventory = version_inventory
        bag_inventory.write_xml_file(bag_pathname, 'version')
      end
      bag_inventory
    end

    # @api internal
    # @param source_base_pathname [Pathname] The home location of the source files
    # @return [void] Fill in the bag's data folder with copies of all files to be packaged for delivery.
    # This method uses Unix hard links in order to greatly speed up the process.
    # Hard links, however, require that the target bag must be created within the same filesystem as the source files
    def fill_payload(source_base_pathname)
      bag_inventory.groups.each do |group|
        group_id = group.group_id
        case package_mode
        when :depositor
          deposit_group(group_id, source_base_pathname.join(group_id))
        when :reconstructor
          reconstuct_group(group_id, source_base_pathname)
        end
      end
    end

    # @param group_id [String] The name of the data group being copied to the bag
    # @param source_dir [Pathname] The location from which files should be copied
    # @return [Boolean] Copy all the files listed in the group inventory to the bag.
    #    Return true if successful or nil if the group was not found in the inventory
    def deposit_group(group_id, source_dir)
      group = bag_inventory.group(group_id)
      return nil? if group.nil? || group.files.empty?

      target_dir = bag_pathname.join('data', group_id)
      group.path_list.each do |relative_path|
        source = source_dir.join(relative_path)
        target = target_dir.join(relative_path)
        target.parent.mkpath
        FileUtils.symlink source, target
      end
      true
    end

    # @param group_id [String] The name of the data group being copied to the bag
    # @param storage_object_dir [Pathname] The home location of the object store from which files should be copied
    # @return [Boolean] Copy all the files listed in the group inventory to the bag.
    #    Return true if successful or nil if the group was not found in the inventory
    def reconstuct_group(group_id, storage_object_dir)
      group = bag_inventory.group(group_id)
      return nil? if group.nil? || group.files.empty?

      target_dir = bag_pathname.join('data', group_id)
      group.files.each do |file|
        catalog_entry = signature_catalog.signature_hash[file.signature]
        source = storage_object_dir.join(catalog_entry.storage_path)
        file.instances.each do |instance|
          target = target_dir.join(instance.path)
          target.parent.mkpath
          FileUtils.symlink source, target unless target.exist?
        end
      end
      true
    end

    # @return [Boolean] create BagIt manifests and tag files.  Return true if successful
    def create_tagfiles
      create_payload_manifests
      create_bag_info_txt
      create_bagit_txt
      create_tagfile_manifests
      true
    end

    # @api internal
    # @return [void] Using the checksum information from the inventory, create BagIt manifest files for the payload
    def create_payload_manifests
      manifest_pathname = {}
      manifest_file = {}
      DEFAULT_CHECKSUM_TYPES.each do |type|
        manifest_pathname[type] = bag_pathname.join("manifest-#{type}.txt")
        manifest_file[type] = manifest_pathname[type].open('w')
      end
      bag_inventory.groups.each do |group|
        group.files.each do |file|
          fixity = file.signature.fixity
          file.instances.each do |instance|
            data_path = File.join('data', group.group_id, instance.path)
            DEFAULT_CHECKSUM_TYPES.each do |type|
              manifest_file[type].puts("#{fixity[type]} #{data_path}") if fixity[type]
            end
          end
        end
      end
    ensure
      DEFAULT_CHECKSUM_TYPES.each do |type|
        if manifest_file[type]
          manifest_file[type].close
          manifest_pathname[type].delete if
              manifest_pathname[type].exist? && manifest_pathname[type].empty?
        end
      end
    end

    # @api internal
    # @return [void] Generate the bag-info.txt tag file
    def create_bag_info_txt
      bag_pathname.join('bag-info.txt').open('w') do |f|
        f.puts "External-Identifier: #{bag_inventory.package_id}"
        f.puts "Payload-Oxum: #{bag_inventory.byte_count}.#{bag_inventory.file_count}"
        f.puts "Bag-Size: #{bag_inventory.human_size}"
      end
    end

    # @api internal
    # @return [void] create BagIt tag manifest files containing checksums for all files in the bag's root directory
    def create_tagfile_manifests
      manifest_pathname = {}
      manifest_file = {}
      DEFAULT_CHECKSUM_TYPES.each do |type|
        manifest_pathname[type] = bag_pathname.join("tagmanifest-#{type}.txt")
        manifest_file[type] = manifest_pathname[type].open('w')
      end
      bag_pathname.children.each do |file|
        next unless include_in_tagfile_manifests?(file)

        signature = FileSignature.new.signature_from_file(file)
        fixity = signature.fixity
        DEFAULT_CHECKSUM_TYPES.each do |type|
          manifest_file[type].puts("#{fixity[type]} #{file.basename}") if fixity[type]
        end
      end
    ensure
      DEFAULT_CHECKSUM_TYPES.each do |type|
        if manifest_file[type]
          manifest_file[type].close
          manifest_pathname[type].delete if
              manifest_pathname[type].exist? && manifest_pathname[type].empty?
        end
      end
    end

    def include_in_tagfile_manifests?(file)
      basename = file.basename.to_s
      return false if file.directory? || basename.start_with?('tagmanifest') || basename.match?(/\A\.nfs\w+\z/)

      true
    end

    # @return [Boolean] Create a tar file containing the bag
    def create_tarfile(tar_pathname = nil)
      bag_name = bag_pathname.basename
      bag_parent = bag_pathname.parent
      tar_pathname ||= bag_parent.join("#{bag_name}.tar")
      tar_cmd = "cd '#{bag_parent}'; tar --dereference --force-local -cf  '#{tar_pathname}' '#{bag_name}'"
      begin
        shell_execute(tar_cmd)
      rescue
        shell_execute(tar_cmd.sub('--force-local', ''))
      end
      raise(MoabRuntimeError, "Unable to create tarfile #{tar_pathname}") unless tar_pathname.exist?

      true
    end

    # Executes a system command in a subprocess
    # if command isn't successful, grabs stdout and stderr and puts them in ruby exception message
    # @return stdout if execution was successful
    def shell_execute(command)
      require 'open3'
      stdout, stderr, status = Open3.capture3(command.chomp)
      if status.success? && status.exitstatus.zero?
        stdout
      else
        msg = "Shell command failed: [#{command}] caused by <STDERR = #{stderr}>"
        msg << " STDOUT = #{stdout}" if stdout&.length&.positive?
        raise(MoabStandardError, msg)
      end
    rescue SystemCallError => e
      msg = "Shell command failed: [#{command}] caused by #{e.inspect}"
      raise(MoabStandardError, msg)
    end
  end
end
