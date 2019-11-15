require 'druid-tools'

module Stanford
  # A class to represent the SDR repository store
  #
  # ====Data Model
  # * <b>{StorageRepository} = represents the digital object repository storage areas</b>
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
    # @return [String] The branch segment of the object deposit path
    def deposit_branch(object_id)
      object_id.split(/:/)[-1]
    end

    # @param object_id [String] The identifier of the digital object whose path is requested
    # @return [String] the druid tree directory path based on the given object identifier.
    def druid_tree(object_id)
      # Note: this seems an odd place to do druid validation, but leaving it here for now
      syntax_msg = "Identifier has invalid suri syntax: #{object_id}"
      raise(Moab::InvalidSuriSyntaxError, syntax_msg + " nil or empty") if object_id.to_s.empty?
      identifier = object_id.split(':')[-1]
      raise(Moab::InvalidSuriSyntaxError, syntax_msg) if identifier.to_s.empty?
      raise(Moab::InvalidSuriSyntaxError, syntax_msg) unless DruidTools::Druid.valid?(identifier, true)
      DruidTools::Druid.new(identifier, true).tree.join(File::SEPARATOR)
    end
  end
end
