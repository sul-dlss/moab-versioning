# frozen_string_literal: true

module Moab
  # A container for a file signature and all the physical file instances that have that signature
  # This element has one child {FileSignature} element, and one or more {FileInstance} elements
  # Regarding the class name, see
  # * {http://en.wikipedia.org/wiki/Functional_Requirements_for_Bibliographic_Records}
  # * {http://planets-project.eu/events/copenhagen-2009/pre-reading/docs/Modelling%20Organizational%20Preservation%20Goals_Angela%20Dappert.pdf}
  #
  # ====Data Model
  # * {FileInventory} = container for recording information about a collection of related files
  #   * {FileGroup} [1..*] = subset allow segregation of content and metadata files.
  #     * <b>{FileManifestation} [1..*] = snapshot of a file's filesystem characteristics</b>
  #       * {FileSignature} [1] = file fixity information
  #       * {FileInstance} [1..*] = filepath and timestamp of any physical file having that signature
  #
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class FileManifestation < Serializer::Serializable
    include HappyMapper

    # The name of the XML element used to serialize this objects data
    tag 'file'

    # (see Serializable#initialize)
    def initialize(opts = {})
      @instances = []
      super(opts)
    end

    # @attribute
    # @return [FileSignature] The fixity data of the file instance
    element :signature, FileSignature, :tag => 'fileSignature'

    def signature
      @signature.is_a?(Array) ? @signature[0] : @signature
    end

    def signature=(signature)
      @signature = signature.is_a?(Array) ? signature[0] : signature
    end

    # @attribute
    # @return [Array<FileInstance>] The location(s) of the file manifestation's file instances
    has_many :instances, FileInstance, :tag => 'fileInstance'

    # @api internal
    # @return [Array<String>] Create an array from all the file paths of the child {FileInstance} objects
    def paths
      instances.collect(&:path)
    end

    # @api internal
    # @return [Integer] The total number of {FileInstance} objects in this manifestation.
    #   (Number of files that share this manifestation's signature)
    def file_count
      instances.size
    end

    # @api internal
    # @return [Integer] The total size (in bytes) of all files that share this manifestation's signature
    def byte_count
      file_count.to_i * signature.size.to_i
    end

    # @api internal
    # @return [Integer] The total disk usage (in 1 kB blocks) of all files that share this manifestation's signature
    #   (estimating du -k result)
    def block_count
      block_size = 1024
      instance_blocks = (signature.size.to_i + block_size - 1) / block_size
      file_count * instance_blocks
    end

    # @api internal
    # @param other [FileManifestation] The {FileManifestation} object to compare with self
    # @return [Boolean] True if {FileManifestation} objects have same content
    def ==(other)
      return false unless other.respond_to?(:signature) && other.respond_to?(:instances) # Cannot equal an incomparable type!

      (signature == other.signature) && (instances == other.instances)
    end
  end
end
