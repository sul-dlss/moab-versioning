require 'moab'

module Moab

  # A digital object's Signature Catalog is derived from an filtered aggregation of the file inventories
  # of a digital object's set of versions.  (see {#update})
  # It has an entry for every file (identified by {FileSignature}) found in any of the versions,
  # along with a record of the SDR storage location that was used to preserve a single file instance.
  # Once this catalog has been populated, it has multiple uses:
  # * The signature index is used to determine which files of a newly submitted object version
  #   are new additions and which are duplicates of files previously ingested.  (See {#version_additions})
  #   (When a new version contains a mixture of added files and files carried over from the previous version
  #   we only need to store the files from the new version that have unique file signatures.)
  # * Reconstruction of an object version (see {StorageObject#reconstruct_version}) requires a combination
  #   of a full version's {FileInventory} and the SignatureCatalog.
  # * The catalog can also be used for performing consistency checks between manifest files and storage
  #
  # ====Data Model
  # * <b>{SignatureCatalog} = lookup table containing a cumulative collection of all files ever ingested</b>
  #   * {SignatureCatalogEntry} [1..*] = an row in the lookup table containing storage information about a single file
  #     * {FileSignature} [1] = file fixity information
  #
  # @example {include:file:spec/fixtures/derivatives/manifests/v3/signatureCatalog.xml}
  # @see StorageObject
  # @see Bagger
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class SignatureCatalog < Manifest
    include HappyMapper

    # The name of the XML element used to serialize this objects data
    tag 'signatureCatalog'

    # (see Serializable#initialize)
    def initialize(opts={})
      @entries = Array.new
      @signature_hash = OrderedHash.new
      super(opts)
    end

    # @attribute
    # @return [String] The object ID (druid)
    attribute :digital_object_id, String, :tag => 'objectId'

    # @attribute
    # @return [Integer] The ordinal version number
    attribute :version_id, Integer, :tag => 'versionId', :key => true, :on_save => Proc.new {|n| n.to_s}

    # @attribute
    # @return [Time] The datetime at which the catalog was updated
    attribute :catalog_datetime, Time, :tag => 'catalogDatetime', :on_save => Proc.new {|t| t.to_s}

    def catalog_datetime=(datetime)
      @catalog_datetime=Time.input(datetime)
    end

    def catalog_datetime
      Time.output(@catalog_datetime)
    end

    # @attribute
    # @return [Integer] The total number of data files (dynamically calculated)
    attribute :file_count, Integer, :tag => 'fileCount', :on_save => Proc.new {|t| t.to_s}

    def file_count
      entries.size
    end

    # @attribute
    # @return [Integer] The total size (in bytes) of all data files (dynamically calculated)
    attribute :byte_count, Integer, :tag => 'byteCount', :on_save => Proc.new {|t| t.to_s}

    def byte_count
      entries.inject(0) { |sum, entry| sum + entry.signature.size.to_i }
    end

    # @attribute
    # @return [Integer] The total disk usage (in 1 kB blocks) of all data files (estimating du -k result) (dynamically calculated)
    attribute :block_count, Integer, :tag => 'blockCount', :on_save => Proc.new {|t| t.to_s}

    def block_count
      block_size=1024
      entries.inject(0) { |sum, entry| sum + (entry.signature.size.to_i + block_size - 1)/block_size }
    end

    # @attribute
    # @return [Array<SignatureCatalogEntry>] The set of data groups comprising the version
    has_many :entries, SignatureCatalogEntry, :tag => 'entry'

    def entries=(entry_array)
      entry_array.each do |entry|
        add_entry(entry)
      end
    end

    # @return [OrderedHash] An index having {FileSignature} objects as keys and {SignatureCatalogEntry} objects as values
    attr_accessor :signature_hash

    # @api internal
    # @param entry [SignatureCatalogEntry] The new catalog entry
    # @return [void] Add a new entry to the catalog and to the {#signature_hash} index
    def add_entry(entry)
      @signature_hash[entry.signature] = entry
      entries << entry
    end

    # @param [FileSignature] file_signature The signature of the file whose path is sought
    # @return [String] The object-relative path of the file having the specified signature
    def catalog_filepath(file_signature)
      catalog_entry = @signature_hash[file_signature]
      raise "catalog entry not found for #{file_signature.fixity.inspect} in #{@digital_object_id} - #{@version_id}" if catalog_entry.nil?
      catalog_entry.storage_path
    end

    # @param group [FileGroup] A group of the files from a file inventory
    # @param group_pathname [Pathname] The location of the directory containing the group's files
    # @return [void] Inspect and upgrade the group's signature data to include all desired checksums
    def normalize_group_signatures(group, group_pathname=nil)
      unless  group_pathname.nil?
        group_pathname = Pathname(group_pathname)
        raise "Could not locate #{group_pathname}" unless group_pathname.exist?
      end
      group.files.each do |file|
        unless file.signature.complete?
          if @signature_hash.has_key?(file.signature)
            file.signature = @signature_hash.find {|k,v| k == file.signature}[0]
          elsif group_pathname
            file_pathname = group_pathname.join(file.instances[0].path)
            file.signature = file.signature.normalized_signature(file_pathname)
          end
        end
      end
    end

    # @api external
    # @param version_inventory [FileInventory] The complete inventory of the files comprising a digital object version
    # @param data_pathname [Pathname] The location of the object's data directory
    # @return [void] Compares the {FileSignature} entries in the new versions {FileInventory} against the signatures
    #   in this catalog and create new {SignatureCatalogEntry} addtions to the catalog
    # @example {include:file:spec/features/catalog/catalog_update_spec.rb}
    def update(version_inventory, data_pathname)
      version_inventory.groups.each do |group|
        group.files.each do |file|
          unless @signature_hash.has_key?(file.signature)
            entry = SignatureCatalogEntry.new
            entry.version_id = version_inventory.version_id
            entry.group_id = group.group_id
            entry.path = file.instances[0].path
            if file.signature.complete?
              entry.signature = file.signature
            else
              file_pathname = data_pathname.join(group.group_id,entry.path)
              entry.signature = file.signature.normalized_signature(file_pathname)
            end
            add_entry(entry)
          end
        end
      end
      @version_id = version_inventory.version_id
      @catalog_datetime = Time.now
    end

    # @api external
    # @param version_inventory (see #update)
    # @return [FileInventory] Retrurns a filtered copy of the input inventory
    #   containing only those files that were added in this version
    # @example {include:file:spec/features/catalog/version_additions_spec.rb}
    def version_additions(version_inventory)
      version_additions = FileInventory.new(:type=>'additions')
      version_additions.copy_ids(version_inventory)
      version_inventory.groups.each do |group|
        group_addtions = FileGroup.new(:group_id => group.group_id)
        group.files.each do |file|
          unless @signature_hash.has_key?(file.signature)
            group_addtions.add_file_instance(file.signature,file.instances[0])
          end
        end
        version_additions.groups << group_addtions if group_addtions.files.size > 0
      end
      version_additions
    end

  end

end