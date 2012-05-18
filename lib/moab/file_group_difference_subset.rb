require 'moab'

module Moab

  # A container for reporting a set of file-level differences of the type specified by the change attribute
  #
  # ====Data Model
  # * {FileInventoryDifference} = compares two {FileInventory} instances based on file signatures and pathnames
  #   * {FileGroupDifference} [1..*] = performs analysis and reports differences between two matching {FileGroup} objects
  #     * <b>{FileGroupDifferenceSubset} [1..5] = collects a set of file-level differences of a give change type</b>
  #       * {FileInstanceDifference} [1..*] = contains difference information at the file level
  #         * {FileSignature} [1..2] = contains the file signature(s) of two file instances being compared
  #
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class FileGroupDifferenceSubset < Serializable
    include HappyMapper

    # The name of the XML element used to serialize this objects data
    tag 'subset'

    # (see Serializable#initialize)
    def initialize(opts={})
      @files = Array.new
      super(opts)
    end

    # @attribute
    # @return [String] The type of change (identical|renamed|modified|deleted|added)
    attribute :change, String, :key => true

    # @attribute
    # @return [Integer] How many files were changed
    attribute :count, Integer, :on_save => Proc.new { |n| n.to_s }

    def count
      files.size
    end

    # @attribute
    # @return [Array<FileInstanceDifference>] The set of file instances having this type of change
    has_many :files, FileInstanceDifference, :tag=>'file'

  end
end