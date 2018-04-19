module Moab
  # A file-level entry in a digital object's {SignatureCatalog}.
  # It has a child {FileSignature} element that identifies the file's contents (the bytestream)
  # along with data that specfies the SDR storage location that was used to preserve a single file instance.
  #
  # ====Data Model
  # * {SignatureCatalog} = lookup table containing a cumulative collection of all files ever ingested
  #   * <b>{SignatureCatalogEntry} [1..*] = an row in the lookup table containing storage information about a single file</b>
  #     * {FileSignature} [1] = file fixity information
  #
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class SignatureCatalogEntry < Serializer::Serializable
    include HappyMapper

    # The name of the XML element used to serialize this objects data
    tag 'entry'

    # (see Serializable#initialize)
    def initialize(opts = {})
      super(opts)
    end

    # @attribute
    # @return [Integer] The ordinal version number
    attribute :version_id, Integer, :tag => 'originalVersion', :key => true, :on_save => proc { |n| n.to_s }

    # @attribute
    # @return [String] The name of the file group
    attribute :group_id, String, :tag => 'groupId', :key => true

    # @attribute
    # @return [String] The id is the filename path, relative to the file group's base directory
    attribute :path, String, :key => true, :tag => 'storagePath'

    # @attribute
    # @return [FileSignature] The fixity data of the file instance
    element :signature, FileSignature, :tag => 'fileSignature'

    def signature
      # HappyMapper's parser tries to put an array of signatures in the signature field
      @signature.is_a?(Array) ? @signature[0] : @signature
    end

    def signature=(signature)
      @signature = signature.is_a?(Array) ? signature[0] : signature
    end

    # @api internal
    # @return [String] Returns the storage path to a file, relative to the object storage home directory
    def storage_path
      File.join(StorageObject.version_dirname(version_id), 'data', group_id, path)
    end
  end
end
