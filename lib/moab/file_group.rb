require 'moab'

module Moab

  # A container for a standard subset of a digital objects {FileManifestation} objects
  # Used to segregate depositor content from repository metadata files
  # This is a child element of {FileInventory}, which contains a full example
  #
  # ====Data Model
  # * {FileInventory} = container for recording information about a collection of related files
  #   * <b>{FileGroup} [1..*] = subset allow segregation of content and metadata files</b>
  #     * {FileManifestation} [1..*] = snapshot of a file's filesystem characteristics
  #       * {FileSignature} [1] = file fixity information
  #       * {FileInstance} [1..*] = filepath and timestamp of any physical file having that signature
  #
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class FileGroup < Serializable

    include HappyMapper

    # The name of the XML element used to serialize this objects data
    tag 'fileGroup'

    # (see Serializable#initialize)
    def initialize(opts={})
      @signature_hash = OrderedHash.new
      @data_source = ""
      super(opts)
    end

    # @attribute
    # @return [String] The name of the file group
    attribute :group_id, String, :tag => 'groupId', :key => true

    # @attribute
    # @return [String] The directory location or other source of this groups file data
    attribute :data_source, String, :tag => 'dataSource'

    # @attribute
    # @return [Integer] The total number of data files (dynamically calculated)
    attribute :file_count, Integer, :tag => 'fileCount', :on_save => Proc.new {|i| i.to_s}

    def file_count
      files.inject(0) { |sum, manifestation| sum + manifestation.file_count }
    end

    # @attribute
    # @return [Integer] The total size (in bytes) of all data files (dynamically calculated)
    attribute :byte_count, Integer, :tag => 'byteCount', :on_save => Proc.new {|i| i.to_s}

    def byte_count
      files.inject(0) { |sum, manifestation| sum + manifestation.byte_count }
    end

    # @attribute
    # @return [Integer] The total disk usage (in 1 kB blocks) of all data files (estimating du -k result) (dynamically calculated)
    attribute :block_count, Integer, :tag => 'blockCount', :on_save => Proc.new {|i| i.to_s}

    def block_count
      files.inject(0) { |sum, manifestation| sum + manifestation.block_count }
    end

    # @attribute
    # @return [Array<FileManifestation>] The set of files comprising the group
    has_many :files, FileManifestation, :tag => 'file'

    def files
      @signature_hash.values
    end

    # @return [OrderedHash<FileSignature, FileManifestation>] The actual in-memory store for the collection
    #   of {FileManifestation} objects that are contained in this file group.
    attr_accessor :signature_hash

    # @api internal
    # @return [OrderedHash<String,FileSignature>] An index of file paths,
    #   used to test for existence of a filename in this file group
    def path_hash
      path_hash = OrderedHash.new
      @signature_hash.each do |signature,manifestation|
        manifestation.instances.each do |instance|
          path_hash[instance.path] = signature
        end
      end
      path_hash
    end

    # @api internal
    # @param signature_subset [Array<FileSignature>] The signatures used to select the entries to return
    # @return [OrderedHash<String,FileSignature>] A pathname,signature hash containing a subset of the filenames in this file group
    def path_hash_subset(signature_subset)
      path_hash = OrderedHash.new
      signature_subset.each do |signature|
        manifestation = @signature_hash[signature]
        manifestation.instances.each do |instance|
          path_hash[instance.path] = signature
        end
      end
      path_hash
    end

    # @param manifestiation_array [Array<FileManifestation>] The collection of {FileManifestation} objects
    #    that are to be added to this file group.  Used by HappyMapper when deserializing a {FileInventory} file
    # Add the array of {FileManifestation} objects to this file group.
    def files=(manifestiation_array)
      manifestiation_array.each do |manifestiation|
        add_file(manifestiation)
     end
    end

    # @api internal
    # @param manifestation [FileManifestation] The file manifestation to be added
    # @return [void] Add a single {FileManifestation} object to this group
    def add_file(manifestation)
      manifestation.instances.each do |instance|
        add_file_instance(manifestation.signature, instance)
      end
    end

    # @api internal
    # @param signature [FileSignature] The signature of the file instance to be added
    # @param instance [FileInstance] The pathname and datetime of the file instance to be added
    # @return [void] Add a single {FileSignature},{FileInstance} key/value pair to this group.
    #   Data is actually stored in the {#signature_hash}
    def add_file_instance(signature,instance)
      if @signature_hash.has_key?(signature)
        manifestation = @signature_hash[signature]
      else
        manifestation = FileManifestation.new
        manifestation.signature = signature
        @signature_hash[signature] = manifestation
      end
      manifestation.instances << instance
    end

    # @return [Pathname] The full path used as the basis of the relative paths reported
    #   in {FileInstance} objects that are children of the {FileManifestation} objects contained in this file group
    attr_accessor :base_directory

    def base_directory=(basepath)
      @base_directory = Pathname.new(basepath).realpath
    end

    # @api internal
    # @param pathname [Pathname] The file path to be tested
    # @return [Boolean] Test whether the given path is contained within the {#base_directory}
    def is_descendent_of_base?(pathname)
      raise("base_directory has not been set") if @base_directory.nil?
      is_descendent = false
      pathname.realpath.ascend {|ancestor| is_descendent ||= (ancestor == @base_directory)}
      raise("#{pathname} is not a descendent of #{@base_directory}") unless is_descendent
      is_descendent
    end

    # @api internal
    # @param directory [Pathname,String] The location of the files to harvest
    # @param recursive [Boolean] if true, descend into child directories
    # @return [FileGroup] Harvest a directory and add all files to the file group
    def group_from_directory(directory, recursive=true)
      self.base_directory = directory
      @data_source = @base_directory.to_s
      harvest_directory(directory, recursive)
      self
    end

    # @api internal
    # @param path [Pathname,String] pathname of the directory to be harvested
    # @param recursive [Boolean] if true, also harvest subdirectories
    # @param validated [Boolean] if true, path is verified to be descendant of (#base_directory)
    # @return [void]  Traverse a directory tree and add all files to the file group
    #   Note that unlike Find.find and Dir.glob, Pathname passes through symbolic links
    # @see http://stackoverflow.com/questions/3974087/how-to-make-rubys-find-find-follow-symlinks
    # @see http://stackoverflow.com/questions/357754/can-i-traverse-symlinked-directories-in-ruby-with-a-glob
    def harvest_directory(path, recursive, validated=nil)
      pathname=Pathname.new(path).realpath
      validated ||= is_descendent_of_base?(pathname)
      pathname.children.sort.each do |child|
        if child.basename.to_s == ".DS_Store"
          next
        elsif child.directory?
          harvest_directory(child,recursive, validated) if recursive
        else
          add_physical_file(child, validated)
        end
      end
      nil
    end

    # @api internal
    # @param pathname [Pathname, String] The location of the file to be added
    # @param validated [Boolean] if true, path is verified to be descendant of (#base_directory)
    # @return [void] Add a single physical file's data to the array of files in this group
    def add_physical_file(pathname, validated=nil)
      pathname=Pathname.new(pathname).realpath
      validated ||= is_descendent_of_base?(pathname)
      instance = FileInstance.new.instance_from_file(pathname, @base_directory)
      signature = FileSignature.new.signature_from_file(pathname)
      add_file_instance(signature,instance)
    end

  end

end

