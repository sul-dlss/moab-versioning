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
    attribute :difference_count, Integer, :tag=> 'differenceCount',:on_save => Proc.new {|i| i.to_s}

    def difference_count
      @renamed + @modified + @deleted +@added
    end

    # @attribute
    # @return [Integer] How many files were unchanged
    attribute :identical, Integer, :on_save => Proc.new {|n| n.to_s}

    # @attribute
    # @return [Integer] How many files were renamed
    attribute :renamed, Integer, :on_save => Proc.new {|n| n.to_s}

    # @attribute
    # @return [Integer] How many files were modified
    attribute :modified, Integer, :on_save => Proc.new {|n| n.to_s}

    # @attribute
    # @return [Integer] How many files were deleted
    attribute :deleted, Integer, :on_save => Proc.new {|n| n.to_s}

    # @attribute
    # @return [Integer] How many files were added
    attribute :added, Integer, :on_save => Proc.new {|n| n.to_s}

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
    def compare_matching_signatures(basis_group,other_group)
      @subsets << unchanged_subset = FileGroupDifferenceSubset.new(:change => 'identical')
      @subsets << renamed_subset = FileGroupDifferenceSubset.new(:change => 'renamed')
      matching_keys(basis_group.signature_hash, other_group.signature_hash).each do |signature|
        basis_paths = basis_group.signature_hash[signature].paths
        other_paths = other_group.signature_hash[signature].paths
        unchanged_subset.files.concat(tabulate_unchanged_files(signature,basis_paths, other_paths))
        renamed_subset.files.concat(tabulate_renamed_files(signature,basis_paths, other_paths))
      end
      @identical = unchanged_subset.count = unchanged_subset.files.size
      @renamed = renamed_subset.count = renamed_subset.files.size
    end

    # @api internal
    # @param (see #compare_file_groups)
    # @return [void] For signatures that are present in only one group,
    #   report which file instances are modified, deleted, or added
    def compare_non_matching_signatures(basis_group, other_group)
      @subsets << modified_subset = FileGroupDifferenceSubset.new(:change => 'modified')
      @subsets << deleted_subset = FileGroupDifferenceSubset.new(:change => 'deleted')
      @subsets << added_subset = FileGroupDifferenceSubset.new(:change => 'added')
      basis_only_keys(basis_group.signature_hash, other_group.signature_hash).each do |signature|
        basis_paths = basis_group.signature_hash[signature].paths
        other_path_hash = other_group.path_hash
        modified_subset.files.concat(tabulate_modified_files(signature,basis_paths, other_path_hash))
        deleted_subset.files.concat(tabulate_deleted_files(signature,basis_paths, other_path_hash))
      end
      other_only_keys(basis_group.signature_hash, other_group.signature_hash).each do |signature|
        other_paths = other_group.signature_hash[signature].paths
        added_subset.files.concat(tabulate_added_files(signature, other_paths, modified_subset))
      end
      @modified = modified_subset.count = modified_subset.files.size
      @deleted = deleted_subset.count = deleted_subset.files.size
      @added = added_subset.count = added_subset.files.size
    end

    # @api internal
    # @param signature [FileSignature] The file signature of the file manifestations being compared
    # @param basis_paths [Array] The file paths of the file manifestation for this signature in the basis group
    # @param other_paths [Array] The file paths of the file manifestation for this signature in the other group
    # @return [Array<FileInstanceDifference>] Detail comparison output for file manifestations
    #   having the same signature and identical filenames in both groups
    def tabulate_unchanged_files(signature, basis_paths, other_paths)
      unchanged_files = Array.new
      matching_paths = basis_paths & other_paths
      matching_paths.each do |path|
        fid = FileInstanceDifference.new(:change => 'identical')
        fid.basis_path = path
        fid.other_path = "same"
        fid.signatures << signature
        unchanged_files << fid
      end
      unchanged_files
    end

    # @api internal
    # @param (see #tabulate_unchanged_files)
    # @return [Array<FileInstanceDifference>] Detail comparison output for file manifestations
    #   having the same signature, but different filenames in the two groups
    def tabulate_renamed_files(signature, basis_paths, other_paths)
      renamed_files = Array.new
      basis_only_paths = basis_paths - other_paths
      other_only_paths = other_paths - basis_paths
      maxsize = [basis_only_paths.size,other_only_paths.size].max
      (0..maxsize-1).each do |n|
        fid = FileInstanceDifference.new(:change => 'renamed')
        fid.basis_path = basis_only_paths[n]
        fid.other_path = other_only_paths[n]
        fid.signatures << signature
        renamed_files << fid
      end
      renamed_files
    end

    # @api internal
    # @param signature (see #tabulate_unchanged_files)
    # @param basis_paths (see #tabulate_unchanged_files)
    # @param other_path_hash [OrderedHash<String,FileSignature>] An index of file paths,
    #   used to test for existence of a filename in the otner file group
    # @return [Array<FileInstanceDifference>] Detail comparison output for file manifestations
    #   having the same filename, but different signatures in the two groups
    def tabulate_modified_files(signature, basis_paths, other_path_hash)
      modified_files = Array.new
      basis_paths.each do |path|
        if other_path_hash.has_key?(path)
          fid = FileInstanceDifference.new(:change => 'modified')
          fid.basis_path = path
          fid.other_path = "same"
          fid.signatures << signature
          fid.signatures << other_path_hash[path]
          modified_files << fid
        end
      end
      modified_files
    end

    # @api internal
    # @param signature (see #tabulate_unchanged_files)
    # @param basis_paths (see #tabulate_unchanged_files)
    # @param other_path_hash [OrderedHash<String,FileSignature>] An index of file paths,
    #   used to test for existence of a filename in the otner file group
    # @return [Array<FileInstanceDifference>] Detail comparison output for file manifestations
    #   having a filename and signature that only appears in the basis group
    def tabulate_deleted_files(signature, basis_paths, other_path_hash)
      deleted_files = Array.new
      basis_paths.each do |path|
        unless other_path_hash.has_key?(path)
          fid = FileInstanceDifference.new(:change => 'deleted')
          fid.basis_path = path
          fid.other_path = ""
          fid.signatures << signature
          deleted_files << fid
        end
      end
      deleted_files
    end

    # @api internal
    # @param signature (see #tabulate_unchanged_files)
    # @param other_paths (see #tabulate_unchanged_files)
    # @param modified_subset [FileGroupDifferenceSubset] The set of files that are reported as modified
    # @return [Array<FileInstanceDifference>] Detail comparison output for file manifestations
    #   having a signature that only appears in the other group,
    #   unless the filename was already tallied as modified
    def tabulate_added_files(signature, other_paths, modified_subset)
      added_files = Array.new
      other_paths.each do |path|
        unless subset_contains_path?(modified_subset,path)
          fid = FileInstanceDifference.new(:change => 'added')
          fid.basis_path = ""
          fid.other_path = path
          fid.signatures << signature
          added_files << fid
        end
      end
      added_files
    end

    # @api internal
    # @param subset [FileGroupDifferenceSubset] The subset of changes to examine
    # @param path [String] The path to look for
    # @return [Boolean] true if the path is found in the subset's file array
    def subset_contains_path?(subset, path)
      (subset.files.collect{ |file| file.basis_path }).include?(path)
    end

  end

end
