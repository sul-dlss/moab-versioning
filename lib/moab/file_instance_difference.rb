# frozen_string_literal: true

module Moab
  # A container for recording difference information at the file level
  # * If there was no change, the change type is set to <i>identical</i>
  # * If the signature is unchanged, but the path has moved, the change type is set to <i>renamed</i>
  # * If path is unchanged, but the signature has changed, the change type is set to <i>modified</i> and
  #  both signatures are reported
  # * If the signature and path are only in the basis inventory, the change type is set to <i>deleted</i>
  # * If the signature and path are only in the other inventory, the change type is set to <i>added</i>
  # This is a child element of {FileGroupDifferenceSubset}, which is in turn a descendent of {FileInventoryDifference},
  # the documentation of which contains a full example
  #
  # ====Data Model
  # * {FileInventoryDifference} = compares two {FileInventory} instances based on file signatures and pathnames
  #   * {FileGroupDifference} [1..*] = performs analysis and reports differences between two matching {FileGroup} objects
  #     * {FileGroupDifferenceSubset} [1..5] = collects a set of file-level differences of a give change type
  #       * <b>{FileInstanceDifference} [1..*] = contains difference information at the file level</b>
  #         * {FileSignature} [1..2] = contains the file signature(s) of two file instances being compared
  #
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class FileInstanceDifference < Serializer::Serializable
    include HappyMapper

    # The name of the XML element used to serialize this objects data
    tag 'file'

    # (see Serializable#initialize)
    def initialize(opts = {})
      @signatures = []
      super(opts)
    end

    # @attribute
    # @return [String] The type of file change
    attribute :change, String

    # @attribute
    # @return [String] The file's path in the basis inventory (usually for an old version)
    attribute :basis_path, String, tag: 'basisPath', on_save: proc(&:to_s)

    # @attribute
    # @return [String] The file's path in the other inventory (usually for an new version) compared against the basis
    attribute :other_path, String, tag: 'otherPath', on_save: proc(&:to_s)

    # @attribute
    # @return [Array<FileSignature>] The fixity data of the file manifestation(s) (plural if change was a content modification)
    has_many :signatures, FileSignature, tag: 'fileSignature'
  end
end
