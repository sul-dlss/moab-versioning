require 'moab'

module Moab

  # Compares two {FileInventory} instances based primarily on file signatures and secondarily on file pathnames.
  # Although the usual use will be to compare the content of 2 different temporal versions of the same object,
  # it can also be used to verify an inventory document against an inventory harvested from a directory.
  # The report is subdivided into sections for each of the file groups that compose the inventories being compared.
  #
  # ====Data Model
  # * <b>{FileInventoryDifference} = compares two {FileInventory} instances based on file signatures and pathnames</b>
  #   * {FileGroupDifference} [1..*] = performs analysis and reports differences between two matching {FileGroup} objects
  #     * {FileGroupDifferenceSubset} [1..5] = collects a set of file-level differences of a give change type
  #       * {FileInstanceDifference} [1..*] = contains difference information at the file level
  #         * {FileSignature} [1..2] = contains the file signature(s) of two file instances being compared
  #
  # @example {include:file:spec/fixtures/derivatives/manifests/all/fileInventoryDifference.xml}
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class FileInventoryDifference < Manifest

    include HappyMapper

    # The name of the XML element used to serialize this objects data
    tag 'fileInventoryDifference'

    # (see Serializable#initialize)
    def initialize(opts={})
      @group_differences = Array.new
      super(opts)
    end

    # @attribute
    # @return [String] The digital object ID (druid)
    attribute :digital_object_id, String, :tag => 'objectId'

    # @attribute
    # @return [Integer] the number of differences found between the two inventories that were compared (dynamically calculated)
    attribute :difference_count, Integer, :tag=> 'differenceCount',:on_save => Proc.new {|i| i.to_s}

    def difference_count
      @group_differences.inject(0) { |sum, group| sum + group.difference_count }
    end

    # @attribute
    # @return [String] Id information from the version inventory used as the basis for comparison
    attribute :basis, String

    # @attribute
    # @return [String] Id information about the version inventory compared to the basis
    attribute :other, String

    # @attribute
    # @return [Time] The datetime at which the report was run
    attribute :report_datetime, Time, :tag => 'reportDatetime', :on_save => Proc.new {|t| t.to_s}

    def report_datetime=(datetime)
      @report_datetime=Time.input(datetime)
    end

    def report_datetime
      Time.output(@report_datetime)
    end

    # @attribute
    # @return [Array<FileGroupDifference>] The set of data groups comprising the version
    has_many :group_differences, FileGroupDifference, :tag => 'fileGroupDifference'

    # @api external
    # @param basis_inventory [FileInventory] The inventory that is the basis of the comparison
    # @param other_inventory [FileInventory] The inventory that is compared against the basis inventory
    # @return [FileInventoryDifference] Returns a report showing the differences, if any, between two inventories
    # @example {include:file:spec/features/differences/version_compare_spec.rb}
    def compare(basis_inventory, other_inventory)
      @digital_object_id ||= common_object_id(basis_inventory, other_inventory)
      @basis ||= basis_inventory.data_source
      @other ||= other_inventory.data_source
      @report_datetime = Time.now
      group_ids = basis_inventory.groups.keys | other_inventory.groups.keys
      group_ids.each do |group_id|
        basis_group = basis_inventory.groups.keyfind(group_id)
        other_group = other_inventory.groups.keyfind(group_id)
        unless (basis_group.nil? || other_group.nil?)
         @group_differences << FileGroupDifference.new.compare_file_groups(basis_group, other_group)
        end
      end
      self
    end

    # @api external
    # @param basis_inventory [FileInventory] The inventory that is the basis of the comparison
    # @param data_directory [Pathname,String] location of the directory to compare against the inventory
    # @param group_id (see FileInventory#inventory_from_directory)
    # @return [FileInventoryDifference] Returns a report showing the differences, if any, between the manifest file and the contents of the data directory
    # @example {include:file:spec/features/differences/directory_compare_spec.rb}
    def compare_with_directory(basis_inventory, data_directory, group_id=nil)
      directory_inventory = FileInventory.new(:type=>'directory').inventory_from_directory(data_directory,group_id)
      compare(basis_inventory, directory_inventory)
      self
    end

    # @api external
    # @param (see #compare_with_directory)
    # @return [Boolean] Returns true if the manifest file accurately represents the contents of the data directory
    # @example {include:file:spec/features/differences/inventory_validate_spec.rb}
    def verify_against_directory(basis_inventory, data_directory, group_id=nil)
      compare_with_directory(basis_inventory, data_directory, group_id)
      difference_count == 0
    end

    # @api internal
    # @param (see #compare)
    # @return [String] Returns either the common digitial object ID, or a concatenation of both inventory's IDs
    def common_object_id(basis_inventory, other_inventory)
      if basis_inventory.digital_object_id != other_inventory.digital_object_id
        "#{basis_inventory.digital_object_id.to_s}|#{other_inventory.digital_object_id.to_s}"
      else
        basis_inventory.digital_object_id.to_s
      end
    end

  end

end
