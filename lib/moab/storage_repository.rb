module Moab
  # A class to represent the SDR repository store
  #
  # ====Data Model
  # * <b>{StorageRepository} = represents the digital object repository storage areas</b>
  #   * {StorageServices} = supports application layer access to the repository's objects, data, and metadata
  #   * {StorageObject} = represents a digital object's repository storage location and ingest/dissemination methods
  #     * {StorageObjectVersion} [1..*] = represents a version subdirectory within an object's home directory
  #       * {Bagger} [1] = utility for creating bagit packages for ingest or dissemination
  #
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class StorageRepository
    # Note that Moab::Config is not initialized from environment config file until after
    #  this object is initialized by StorageServices
    #  (see sequence of requires in spec_helper.rb and in applications that use)

    # @return [Array<Pathname>] The list of filesystem root paths in which objects are stored
    def storage_roots
      unless defined?(@storage_roots)
        raise "Moab::Config.storage_roots not found in config file" if Moab::Config.storage_roots.nil?
        @storage_roots = [Moab::Config.storage_roots].flatten.collect { |filesystem| Pathname(filesystem) }
        raise "Moab::Config.storage_roots empty" if @storage_roots.empty?
        @storage_roots.each { |root| raise "Storage root #{root} not found on system" unless root.exist? }
      end
      @storage_roots
    end

    # @return [String] The trunk segment of the object storage path
    def storage_trunk
      unless defined?(@storage_trunk)
        raise "Moab::Config.storage_trunk not found in config file" if Moab::Config.storage_trunk.nil?
        @storage_trunk  = Moab::Config.storage_trunk
      end
      @storage_trunk
    end

   # @param object_id [String] The identifier of the digital object
    # @return [String] The branch segment of the object storage path
    def storage_branch(object_id)
      #todo This method should be customized, or overridden in a subclass
      # split a object ID into 2-character segments, followed by a copy of the object ID
      # for a more sophisticated pairtree implementation see https://github.com/microservices/pairtree
      path_segments = object_id.scan(/..?/) << object_id
      path_segments.join(File::SEPARATOR).tr(':', '_')
    end

    # @return [String] The trunk segment of the object deposit path
    def deposit_trunk
      unless defined?(@deposit_trunk)
        # do not raise error.  this parameter will be ignored if missing
        # raise "Moab::Config.deposit_trunk not found in config file" if Moab::Config.deposit_trunk.nil?
        @deposit_trunk  = Moab::Config.deposit_trunk
      end
      @deposit_trunk
    end

    # @param object_id [String] The identifier of the digital object
    # @return [String] The branch segment of the object deposit path
    # @note Override this method in a subclass
    def deposit_branch(object_id)
      object_id
    end

    # @param object_id [String] The identifier of the digital object whose version is desired
    # @param include_deposit [Boolean] specifies whether to look in deposit areas for objects in process of initial ingest
    # @return [Pathname] The location of the desired object's home directory (default=pairtree)
    def find_storage_root(object_id, include_deposit = false)
      # Search for the object's home directory in the storage areas
      branch = storage_branch(object_id)
      storage_roots.each do |root|
        root_trunk = root.join(storage_trunk)
        raise "Storage area not found at #{root_trunk}" unless root_trunk.exist?
        root_trunk_branch = root_trunk.join(branch)
        return root if root_trunk_branch.exist?
      end
      # Search for the object's directory in the deposit areas
      if include_deposit && deposit_trunk
        branch = deposit_branch(object_id)
        storage_roots.each do |root|
          root_trunk = root.join(deposit_trunk)
          raise "Deposit area not found at #{root_trunk}" unless root_trunk.exist?
          root_trunk_branch = root_trunk.join(branch)
          return root if root_trunk_branch.exist?
        end
      end
      # object not found, will store new objects in the newest (most empty) filesystem
      storage_roots.last
    end

    # @param object_id [String] The identifier of the digital object whose version is desired
    # @param include_deposit [Boolean] specifies whether to look in deposit areas for objects in process of initial ingest
    # @return [StorageObject] The representation of a digitial object's  storage directory, which might not exist yet.
    def find_storage_object(object_id, include_deposit = false)
      root = find_storage_root(object_id, include_deposit)
      storage_pathname = root.join(storage_trunk, storage_branch(object_id))
      storage_object = StorageObject.new(object_id, storage_pathname)
      storage_object.storage_root = root
      storage_object
    end

    # @param object_id [String] The identifier of the digital object whose size is desired
    # @param include_deposit [Boolean] specifies whether to look in deposit areas for objects in process of initial ingest
    # @return [Integer] the size occupied on disk by the storage object, in bytes.  this is the entire moab (all versions).
    def object_size(object_id, include_deposit = false)
      storage_pathname = find_storage_object(object_id, include_deposit).object_pathname
      size = 0
      Find.find(storage_pathname) do |path|
        size += FileTest.size(path) unless FileTest.directory?(path)
      end
      size
    end

    # @param object_id [String] The identifier of the digital object whose version is desired
    # @param create [Boolean] If true, the object home directory should be created if it does not exist
    # @return [StorageObject] The representation of a digitial object's storage directory, which must exist.
    def storage_object(object_id, create = false)
      storage_object = find_storage_object(object_id)
      unless storage_object.object_pathname.exist?
        raise Moab::ObjectNotFoundException, "No storage object found for #{object_id}" unless create
        storage_object.object_pathname.mkpath
      end
      storage_object
    end

    # @depricated Please use StorageObject#ingest_bag
    # @param druid [String] The object identifier
    # @return [void] transfer the object to the preservation repository
    def store_new_object_version(druid, bag_pathname)
      storage_object(druid, create = true).ingest_bag(bag_pathname)
    end
  end
end
