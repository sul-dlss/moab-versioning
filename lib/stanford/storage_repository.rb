require 'moab_stanford'

module Stanford

  # A class to represent the SDR repository store
  #
  # ====Data Model
  # * <b>{StorageRepository} = represents a digital object repository storage node</b>
  #
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class StorageRepository

   # @return [Pathname] The location of the root directory of the repository storage node
    def repository_home
      Pathname.new(Moab::Config.repository_home)
    end

    # @param object_id [String] The identifier of the digital object whose version is desired
    # @param version_id [Integer] The desired version
    # @return [StorageObjectVersion] The representation of the desired object version's storage directory
    def storage_object_version(object_id, version_id=nil)
      storage_object(object_id).storage_object_version(version_id)
    end

    # @param object_id [String] The identifier of the digital object whose version is desired
    # @return [StorageObject] The representation of the desired object storage directory
    def storage_object(object_id)
      StorageObject.new(object_id, storage_object_pathname(object_id))
    end

    # @param object_id [String] The identifier of the digital object whose version is desired
    # @return [Pathname] The location of the desired object's home directory
    def storage_object_pathname(object_id)
      case Moab::Config.path_method
        when :druid_tree
          repository_home.join(druid_tree(object_id))
        when :druid
          repository_home.join(object_id.split(/:/)[-1])
      end
    end

    # @param object_id [String] The identifier of the digital object whose path is requested
    # @return [String] the druid tree directory path based on the given object identifier.
    def druid_tree(object_id)
      syntax_msg = "Identifier has invalid suri syntax: #{object_id}"
      raise syntax_msg + "nil or empty" if object_id.to_s.empty?
      identifier = object_id.split(':')[-1]
      raise syntax_msg if  identifier.to_s.empty?
      # The object identifier must be in the SURI format, otherwise an exception is raised:
      # e.g. druid:aannnaannnn or aannnaannnn
      # where 'a' is an alphabetic character
      # where 'n' is a numeric character
      if identifier =~ /^([a-z]{2})(\d{3})([a-z]{2})(\d{4})$/
        return File.join( $1, $2, $3, $4, identifier)
      else
        raise syntax_msg
      end
    end


  end

end
