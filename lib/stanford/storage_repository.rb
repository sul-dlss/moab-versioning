require 'moab_stanford'

module Stanford

  # A class to represent the SDR repository store
  #
  # ====Data Model
  # * <b>{StorageRepository} = represents a digital object repository storage node</b>
  #
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class StorageRepository < Moab::StorageRepository

    # @param object_id [String] The identifier of the digital object
    # @return [String] The branch segment of the object storage path
    def storage_branch(object_id)
      case Moab::Config.path_method.to_s
        when 'druid_tree'
          druid_tree(object_id)
        when 'druid'
          object_id.split(/:/)[-1]
      end
    end

    # @param object_id [String] The identifier of the digital object
    # @return [Pathname] The branch segment of the object deposit path
    def deposit_branch(object_id)
      object_id.split(/:/)[-1]
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
