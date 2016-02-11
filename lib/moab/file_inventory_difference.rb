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
  class FileInventoryDifference < Serializer::Manifest

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
    # @return [String] The datetime at which the report was run
    attribute :report_datetime, String, :tag => 'reportDatetime'

    def report_datetime=(datetime)
      @report_datetime=Moab::UtcTime.input(datetime)
    end

    def report_datetime
      Moab::UtcTime.output(@report_datetime)
    end

    # @attribute
    # @return [Array<FileGroupDifference>] The set of data groups comprising the version
    has_many :group_differences, FileGroupDifference, :tag => 'fileGroupDifference'

    # @return [Array<String>] The data fields to include in summary reports
    def summary_fields
      %w{digital_object_id difference_count basis other report_datetime group_differences}
    end

    # @param [String] group_id The identifer of the group to be selected
    # @return [FileGroupDifference] The subset of this report for the specified group_id (or nil if not found)
    def group_difference(group_id)
      @group_differences.find{ |group_difference| group_difference.group_id == group_id}
    end

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
      # get a union list of all group_ids present in either inventory
      group_ids = basis_inventory.group_ids | other_inventory.group_ids
      group_ids.each do |group_id|
        # get a pair of groups to compare, creating a empty group if not present in the inventory
        basis_group = basis_inventory.group(group_id) || FileGroup.new(:group_id => group_id)
        other_group = other_inventory.group(group_id) || FileGroup.new(:group_id => group_id)
        @group_differences << FileGroupDifference.new.compare_file_groups(basis_group, other_group)
      end
      self
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

    # @return [Hash] Serializes the data and then filters it to report only the changes
    def differences_detail
      #return self.summary if difference_count == 0
      inv_diff = self.to_hash
      inv_diff["group_differences"].each_value do |group_diff|
        delete_subsets = []
        group_diff["subsets"].each do |change_type,subset|
          delete_subsets << change_type if change_type == "identical" or subset["count"] == 0
        end
        delete_subsets.each do |change_type|
          group_diff["subsets"].delete(change_type)
          group_diff.delete(change_type) if change_type != "identical"
        end
        group_diff.delete("subsets") if group_diff["subsets"].empty?
      end
      inv_diff
    end

  end

end
