require 'moab'

module Moab

  # Performs analysis and reports the differences between two matching {FileGroup} objects.
  # The descending elements of the report hold a detailed breakdown of file-level differences, organized by change type.
  # This stanza is a child element of {FileInventoryDifference}, the documentation of which contains a full example.
  #
  # In order to determine the detailed nature of the differences that are present between the two manifests,
  # this algorithm first compares the sets of file signatures present in the groups being compared,
  # then uses the result of that operation for subsequent analysis of filename correspondences.
  #
  # For the first step, a Ruby Hash is extracted from each of the of the two groups, with an array of
  # {FileSignature} object used as hash keys, and the corresponding {FileInstance} arrays as the hash values.
  # The set of keys from the basis hash can be compared against the keys from the other hash using {Array} operators:
  # * <i>matching</i>  = basis_array & other_array
  # * <i>basis_only</i> = basis_array - other_array
  # * <i>other_only</i> = other_array - basis_array
  #
  # For the second step of the comparison, the matching and non-matching sets of hash entries
  # are further categorized as follows:
  # * <i>identical</i> = signature and file path is the same in both basis and other file group
  # * <i>renamed</i> = signature is unchanged, but the path has moved
  # * <i>modified</i> = path is present in both groups, but the signature has changed
  # * <i>deleted</i> = signature and path are only in the basis inventory
  # * <i>added</i> = signature and path are only in the other inventor
  #
  # ====Data Model
  # * {FileInventoryDifference} = compares two {FileInventory} instances based on file signatures and pathnames
  #   * <b>{FileGroupDifference} [1..*] = performs analysis and reports differences between two matching {FileGroup} objects</b>
  #     * {FileGroupDifferenceSubset} [1..5] = collects a set of file-level differences of a give change type
  #       * {FileInstanceDifference} [1..*] = contains difference information at the file level
  #         * {FileSignature} [1..2] = contains the file signature(s) of two file instances being compared
  #
  # @note Copyright (c) 2012 by The Board of Trustees of the Leland Stanford Junior University.
  #   All rights reserved.  See {file:LICENSE.rdoc} for details.
  class FileGroupDifference < Serializable
    include HappyMapper

    # The name of the XML element used to serialize this objects data
    tag 'fileGroupDifference'

    # (see Serializable#initialize)
    def initialize(opts={})
      @subsets = Array.new
      super(opts)
    end

    # @attribute
    # @return [String] The name of the file group
    attribute :group_id, String, :tag => 'groupId', :key => true

    # @attribute
    # @return [Integer] the total number of differences found between the two inventories that were compared  (dynamically calculated)
    attribute :difference_count, Integer, :tag => 'differenceCount', :on_save => Proc.new { |i| i.to_s }

    def difference_count
      @renamed + @modified + @deleted +@added
    end

    # @attribute
    # @return [Integer] How many files were unchanged
    attribute :identical, Integer, :on_save => Proc.new { |n| n.to_s }

    # @attribute
    # @return [Integer] How many files were renamed
    attribute :renamed, Integer, :on_save => Proc.new { |n| n.to_s }

    # @attribute
    # @return [Integer] How many files were modified
    attribute :modified, Integer, :on_save => Proc.new { |n| n.to_s }

    # @attribute
    # @return [Integer] How many files were deleted
    attribute :deleted, Integer, :on_save => Proc.new { |n| n.to_s }

    # @attribute
    # @return [Integer] How many files were added
    attribute :added, Integer, :on_save => Proc.new { |n| n.to_s }

    # @attribute
    # @return [Array<FileGroupDifferenceSubset>] A set of Arrays (one for each change type),
    #    each of which contains an collection of file-level differences having that change type.
    has_many :subsets, FileGroupDifferenceSubset, :tag => 'subset'

    # @api internal
    # @return [FileGroupDifference] Clone just this element for inclusion in a versionMetadata structure
    def summary()
      FileGroupDifference.new(
          :group_id => @group_id,
          :identical => @identical,
          :renamed => @renamed,
          :modified => @modified,
          :deleted => @deleted,
          :added => @added
      )
    end

    # @api internal
    # @param basis_hash [Hash] The first hash being compared
    # @param other_hash [Hash] The second hash being compared
    # @return [Array] Compare the keys of two hashes and return the intersection
    def matching_keys(basis_hash, other_hash)
      basis_hash.keys & other_hash.keys
    end

    # @api internal
    # @param (see #matching_keys)
    # @return [Array] Compare the keys of two hashes and return the keys unique to the first hash
    def basis_only_keys(basis_hash, other_hash)
      basis_hash.keys - other_hash.keys
    end

    # @api internal
    # @param (see #matching_keys)
    # @return [Array] Compare the keys of two hashes and return the keys unique to the second hash
    def other_only_keys(basis_hash, other_hash)
      other_hash.keys - basis_hash.keys
    end

    # @api internal
    # @param basis_group [FileGroup] The file group that is the basis of the comparison
    # @param other_group [FileGroup] The file group that is compared against the basis group
    # @return [FileGroupDifference] Compare two file groups and return a differences report
    def compare_file_groups(basis_group, other_group)
      @group_id = basis_group.group_id
      compare_matching_signatures(basis_group, other_group)
      compare_non_matching_signatures(basis_group, other_group)
      self
    end

    # @api internal
    # @param (see #compare_file_groups)
    # @return [void] For signatures that are present in both groups,
    #   report which file instances are identical or renamed
    def compare_matching_signatures(basis_group, other_group)
      matching_signatures = matching_keys(basis_group.signature_hash, other_group.signature_hash)
      tabulate_unchanged_files(matching_signatures, basis_group.signature_hash, other_group.signature_hash)
      tabulate_renamed_files(matching_signatures, basis_group.signature_hash, other_group.signature_hash)
    end

    # @api internal
    # @param (see #compare_file_groups)
    # @return [void] For signatures that are present in only one or the other group,
    #   report which file instances are modified, deleted, or added
    def compare_non_matching_signatures(basis_group, other_group)
      basis_only_signatures = basis_only_keys(basis_group.signature_hash, other_group.signature_hash)
      other_only_signatures = other_only_keys(basis_group.signature_hash, other_group.signature_hash)
      basis_path_hash = basis_group.path_hash_subset(basis_only_signatures)
      other_path_hash = other_group.path_hash_subset(other_only_signatures)
      tabulate_modified_files(basis_path_hash, other_path_hash)
      tabulate_deleted_files(basis_path_hash, other_path_hash)
      tabulate_added_files(basis_path_hash, other_path_hash)
    end

    # @api internal
    # @param matching_signatures [Array<FileSignature>] The file signature of the file manifestations being compared
    # @param basis_signature_hash [OrderedHash<FileSignature, FileManifestation>]
    #   Signature to file path mapping from the file group that is the basis of the comparison
    # @param other_signature_hash [OrderedHash<FileSignature, FileManifestation>]
    #   Signature to file path mapping from the file group that is the being compared to the basis group
    # @return [FileGroupDifferenceSubset]
    #   Container for reporting the set of file-level differences of type 'identical'
    def tabulate_unchanged_files(matching_signatures, basis_signature_hash, other_signature_hash)
      unchanged_files = Array.new
      matching_signatures.each do |signature|
        basis_paths = basis_signature_hash[signature].paths
        other_paths = other_signature_hash[signature].paths
        matching_paths = basis_paths & other_paths
        matching_paths.each do |path|
          fid = FileInstanceDifference.new(:change => 'identical')
          fid.basis_path = path
          fid.other_path = "same"
          fid.signatures << signature
          unchanged_files << fid
        end
      end
      unchanged_subset = FileGroupDifferenceSubset.new(:change => 'identical')
      unchanged_subset.files = unchanged_files
      @subsets << unchanged_subset
      @identical = unchanged_subset.count
      unchanged_subset
    end


    # @api internal
    # @param matching_signatures [Array<FileSignature>] The file signature of the file manifestations being compared
    # @param basis_signature_hash [OrderedHash<FileSignature, FileManifestation>]
    #   Signature to file path mapping from the file group that is the basis of the comparison
    # @param other_signature_hash [OrderedHash<FileSignature, FileManifestation>]
    #   Signature to file path mapping from the file group that is the being compared to the basis group
    # @return [FileGroupDifferenceSubset]
    #   Container for reporting the set of file-level differences of type 'renamed'
    def tabulate_renamed_files(matching_signatures, basis_signature_hash, other_signature_hash)
      renamed_files = Array.new
      matching_signatures.each do |signature|
        basis_paths = basis_signature_hash[signature].paths
        other_paths = other_signature_hash[signature].paths
        basis_only_paths = basis_paths - other_paths
        other_only_paths = other_paths - basis_paths
        maxsize = [basis_only_paths.size, other_only_paths.size].max
        (0..maxsize-1).each do |n|
          fid = FileInstanceDifference.new(:change => 'renamed')
          fid.basis_path = basis_only_paths[n]
          fid.other_path = other_only_paths[n]
          fid.signatures << signature
          renamed_files << fid
        end
      end
      renamed_subset = FileGroupDifferenceSubset.new(:change => 'renamed')
      renamed_subset.files = renamed_files
      @subsets << renamed_subset
      @renamed = renamed_subset.count
      renamed_subset
    end


    # @api internal
    # @param basis_path_hash [OrderedHash<String,FileSignature>]
    #   The file paths and associated signatures for manifestations appearing only in the basis group
    # @param other_path_hash [OrderedHash<String,FileSignature>]
    #   The file paths and associated signatures for manifestations appearing only in the other group
    # @return [FileGroupDifferenceSubset]
    #   Container for reporting the set of file-level differences of type 'modified'
    def tabulate_modified_files(basis_path_hash, other_path_hash)
      modified_files = Array.new
      matching_keys(basis_path_hash, other_path_hash).each do |path|
        fid = FileInstanceDifference.new(:change => 'modified')
        fid.basis_path = path
        fid.other_path = "same"
        fid.signatures << basis_path_hash[path]
        fid.signatures << other_path_hash[path]
        modified_files << fid
      end
      modified_subset = FileGroupDifferenceSubset.new(:change => 'modified')
      modified_subset.files = modified_files
      @subsets << modified_subset
      @modified = modified_subset.count
      modified_subset
    end

    # @api internal
    # @param basis_path_hash [OrderedHash<String,FileSignature>]
    #   The file paths and associated signatures for manifestations appearing only in the basis group
    # @param other_path_hash [OrderedHash<String,FileSignature>]
    #   The file paths and associated signatures for manifestations appearing only in the other group
    # @return [FileGroupDifferenceSubset]
    #   Container for reporting the set of file-level differences of type 'deleted'
    def tabulate_deleted_files(basis_path_hash, other_path_hash)
      deleted_files = Array.new
      basis_only_keys(basis_path_hash, other_path_hash).each do |path|
        fid = FileInstanceDifference.new(:change => 'deleted')
        fid.basis_path = path
        fid.other_path = ""
        fid.signatures << basis_path_hash[path]
        deleted_files << fid
      end
      deleted_subset = FileGroupDifferenceSubset.new(:change => 'deleted')
      deleted_subset.files = deleted_files
      @subsets << deleted_subset
      @deleted = deleted_subset.count
      deleted_subset
    end

    # @api internal
    # @param basis_path_hash [OrderedHash<String,FileSignature>]
    #   The file paths and associated signatures for manifestations appearing only in the basis group
    # @param other_path_hash [OrderedHash<String,FileSignature>]
    #   The file paths and associated signatures for manifestations appearing only in the other group
    # @return [FileGroupDifferenceSubset]
    #   Container for reporting the set of file-level differences of type 'added'
    def tabulate_added_files(basis_path_hash, other_path_hash)
      added_files = Array.new
      other_only_keys(basis_path_hash, other_path_hash).each do |path|
        fid = FileInstanceDifference.new(:change => 'added')
        fid.basis_path = ""
        fid.other_path = path
        fid.signatures << other_path_hash[path]
        added_files << fid
      end
      added_subset = FileGroupDifferenceSubset.new(:change => 'added')
      added_subset.files = added_files
      @subsets << added_subset
      @added = added_subset.count
      added_subset
    end

  end

end
