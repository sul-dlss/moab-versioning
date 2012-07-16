require 'moab'

module Moab

  # A class used to create a BagIt package from a version inventory and a set of source files.
  # The {#fill_bag} method is called with a package_mode parameter that specifies
  # whether the bag is being created for deposit into the repository or is to contain the output of a version reconstruction.
  # * In <b>:depositor</b> mode, the version inventory is filtered using the digital object's signature catalog so that only new files are included
  # * In <b>:reconstructor</b> mode, the version inventory and signature catalog are used together to regenerate the complete set of files for the version.
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
    # @param source_base_pathname [Pathname,String] The home location of the source files
    # @param bag_pathname [Pathname,String] The location of the Bagit bag to be created
    def initialize(version_inventory, signature_catalog, source_base_pathname, bag_pathname)
      @version_inventory = version_inventory
      @signature_catalog = signature_catalog
      @source_base_pathname = Pathname.new(source_base_pathname).realpath
      @bag_pathname = Pathname.new(bag_pathname)
    end

    # @return [FileInventory] The complete inventory of the files comprising a digital object version
    attr_accessor :version_inventory

    # @return [SignatureCatalog] The signature catalog, used to specify source paths (in :reconstructor mode),
    #   or to filter the version inventory (in :depositor mode)
    attr_accessor :signature_catalog

    # @return [Pathname] The home location of the source files
    attr_accessor :source_base_pathname

    # @return [Pathname] The location of the Bagit bag to be created
    attr_accessor :bag_pathname

    # @return [FileInventory] The actual inventory of the files to be packaged (derived from @version_inventory in {#fill_bag})
    attr_accessor :bag_inventory

    # @return [Symbol] The operational mode controlling what gets bagged {#fill_bag}
    #   and the full path of source files {#fill_payload}
    attr_accessor :package_mode

    # @api external
    # @param package_mode [Symbol] The operational mode controlling what gets bagged and the full path of source files (Bagger#fill_payload)
    # @return [Bagger] Perform all the operations required to fill the bag payload, write the manifests and tagfiles, and checksum the tagfiles
    # @example {include:file:spec/features/storage/deposit_spec.rb}
    def fill_bag(package_mode)
      @package_mode = package_mode
      case package_mode
        when :depositor
          @bag_inventory = @signature_catalog.version_additions(@version_inventory)
        when :reconstructor
          @bag_inventory = @version_inventory
      end
      @bag_pathname.mkpath
      write_inventory_file
      fill_payload
      create_payload_manifests
      create_bag_info_txt
      create_bagit_txt
      create_tagfile_manifests
      self
    end

    # @api internal
    # @return [void] Create a copy of version inventory file in the bag's root directory
    # In :depositor mode, serialize the in-memory versionInventory and the versionAddtions
    # In :reconstructor mode, copy the existing inventory file to the bag's' root
    def write_inventory_file
      case @package_mode
        when :depositor
          @version_inventory.write_xml_file(@bag_pathname, 'version')
          @bag_inventory.write_xml_file(@bag_pathname, 'additions')
        when :reconstructor
          version_dirname = StorageObject.version_dirname(@version_inventory.version_id)
          source_file=FileInventory.xml_pathname(@source_base_pathname.join(version_dirname), 'version')
          FileUtils.link(source_file.to_s, @bag_pathname.to_s, :force=>true)
      end
    end

    # @api internal
    # @return [void] Fill in the bag's data folder with copies of all files to be packaged for delivery.
    # This method uses Unix hard links in order to greatly speed up the process.
    # Hard links, however, require that the target bag must be created within the same filesystem as the source files
    def fill_payload
      payload_pathname = @bag_pathname.join('data')
      payload_pathname.mkpath
      @bag_inventory.groups.each do |group|
        group.files.each do |file|
          file.instances.each do |instance|
            relative_path = File.join(group.group_id, instance.path)
            case @package_mode
              when :depositor
                source = @source_base_pathname.join(relative_path)
              when :reconstructor
                catalog_entry = @signature_catalog.signature_hash[file.signature]
                source = @source_base_pathname.join(catalog_entry.storage_path)
            end
            target = payload_pathname.join(relative_path)
            target.parent.mkpath
            FileUtils.link source.to_s, target.to_s, :force=>true
            if instance.datetime
              datetime = Time.parse(instance.datetime)
              target.utime(datetime, datetime)
            end
          end
        end
      end
      nil
    end

    # @api internal
    # @return [void] Using the checksum information from the inventory, create md5 and sha1 manifest files for the payload
    def create_payload_manifests
      md5 = @bag_pathname.join('manifest-md5.txt').open('w')
      sha1 = @bag_pathname.join('manifest-sha1.txt').open('w')
      @bag_inventory.groups.each do |group|
        group.files.each do |file|
          file.instances.each do |instance|
            signature = file.signature
            data_path = File.join('data', group.group_id, instance.path)
            md5.puts("#{signature.md5} #{data_path}")
            sha1.puts("#{signature.sha1} #{data_path}")
          end
        end
      end
    ensure
      md5.close if md5
      sha1.close if sha1
    end

    # @api internal
    # @return [void] Generate the bag-info.txt tag file
    def create_bag_info_txt
      @bag_pathname.join("bag-info.txt").open('w') do |f|
        f.puts "External-Identifier: #{@bag_inventory.package_id}"
        f.puts "Payload-Oxum: #{@bag_inventory.byte_count}.#{@bag_inventory.file_count}"
        f.puts "Bag-Size: #{@bag_inventory.human_size}"
      end
    end

    # @api internal
    # @return [void] Generate the bagit.txt tag file
    def create_bagit_txt()
      @bag_pathname.join("bagit.txt").open('w') do |f|
        f.puts "Tag-File-Character-Encoding: UTF-8"
        f.puts "BagIt-Version: 0.97"
      end
    end

    # @api internal
    # @return [void] create md5 and sha1 manifest files containing checksums for all files in the bag's root directory
    def create_tagfile_manifests()
      md5 = @bag_pathname.join('tagmanifest-md5.txt').open('w')
      sha1 = @bag_pathname.join('tagmanifest-sha1.txt').open('w')
      @bag_pathname.children.each do |file|
        unless file.directory? || file.basename.to_s[0, 11] == 'tagmanifest'
          signature = FileSignature.new.signature_from_file(file.realpath)
          md5.puts("#{signature.md5} #{file.basename}")
          sha1.puts("#{signature.sha1} #{file.basename}")
        end
      end
    ensure
      md5.close if md5
      sha1.close if sha1
    end

  end

end
