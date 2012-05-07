require 'spec_helper'

# Unit tests for class {Moab::FileGroupDifference}
describe 'Moab::FileGroupDifference' do
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Moab::FileGroupDifference#initialize}
    # Which returns an instance of: [Moab::FileGroupDifference]
    # For input parameters:
    # * opts [Hash<Symbol,Object>] = a hash containing any number of symbol => value pairs. The symbols should correspond to attributes declared using HappyMapper syntax 
    specify 'Moab::FileGroupDifference#initialize' do
       
      # test initialization with required parameters (if any)
      opts = {}
      file_group_difference = FileGroupDifference.new(opts)
      file_group_difference.should be_instance_of(FileGroupDifference)
       
      # test initialization of arrays and hashes
      file_group_difference.subsets.should be_kind_of(Array)
      file_group_difference.subsets.size.should == 0

      # test initialization with options hash
      opts = OrderedHash.new
      opts[:group_id] = 'Test group_id'
      file_group_difference = FileGroupDifference.new(opts)
      file_group_difference.group_id.should == opts[:group_id]

      # def initialize(opts={})
      #   @subsets = Array.new
      #   super(opts)
      # end
    end
  
  end
  
  describe '=========================== INSTANCE ATTRIBUTES ===========================' do
    
    before(:all) do
      @v1_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/versionInventory.xml')
      @v1_inventory = FileInventory.parse(@v1_inventory_pathname.read)

      @v3_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0003/versionInventory.xml')
      @v3_inventory = FileInventory.parse(@v3_inventory_pathname.read)

      opts = {}
      @file_inventory_difference = FileInventoryDifference.new(opts)
      @file_inventory_difference.compare(@v1_inventory,@v3_inventory)

      @file_group_difference = @file_inventory_difference.group_differences[0]
      end
    
    # Unit test for attribute: {Moab::FileGroupDifference#group_id}
    # Which stores: [String] \@groupId = The name of the file group
    specify 'Moab::FileGroupDifference#group_id' do
      @file_group_difference.group_id.should == "content"
       
      # attribute :group_id, String, :tag => 'groupId', :key => true
    end
    
    # Unit test for attribute: {Moab::FileGroupDifference#difference_count}
    # Which stores: [Integer] \@differenceCount = the total number of differences found between the two inventories that were compared
    specify 'Moab::FileGroupDifference#difference_count' do
      @file_group_difference.difference_count.should == 6
       
      # attribute :difference_count, Integer, :tag=> 'differenceCount',:on_save => Proc.new {|i| i.to_s}
       
      # def difference_count
      #   @renamed + @modified + @deleted +@added
      # end
    end
    
    # Unit test for attribute: {Moab::FileGroupDifference#identical}
    # Which stores: [Integer] \@identical = How many files were unchanged
    specify 'Moab::FileGroupDifference#identical' do
      @file_group_difference.identical.should == 1

      # attribute :identical, Integer, :on_save => Proc.new {|n| n.to_s}
    end
    
    # Unit test for attribute: {Moab::FileGroupDifference#renamed}
    # Which stores: [Integer] \@renamed = How many files were renamed
    specify 'Moab::FileGroupDifference#renamed' do
      @file_group_difference.renamed.should == 2

      # attribute :renamed, Integer, :on_save => Proc.new {|n| n.to_s}
    end
    
    # Unit test for attribute: {Moab::FileGroupDifference#modified}
    # Which stores: [Integer] \@modified = How many files were modified
    specify 'Moab::FileGroupDifference#modified' do
      @file_group_difference.modified.should == 1

      # attribute :modified, Integer, :on_save => Proc.new {|n| n.to_s}
    end
    
    # Unit test for attribute: {Moab::FileGroupDifference#deleted}
    # Which stores: [Integer] \@deleted = How many files were deleted
    specify 'Moab::FileGroupDifference#deleted' do
      @file_group_difference.deleted.should == 2

      # attribute :deleted, Integer, :on_save => Proc.new {|n| n.to_s}
    end
    
    # Unit test for attribute: {Moab::FileGroupDifference#added}
    # Which stores: [Integer] \@added = How many files were added
    specify 'Moab::FileGroupDifference#added' do
      @file_group_difference.added.should == 1
       
      # attribute :added, Integer, :on_save => Proc.new {|n| n.to_s}
    end
    
    # Unit test for attribute: {Moab::FileGroupDifference#subsets}
    # Which stores: [Array<FileGroupDifferenceSubset>] \[<FileGroupDifferenceSubset>] = A set of Arrays (one for each change type), each of which contains an collection of file-level differences having that change type.
    specify 'Moab::FileGroupDifference#subsets' do
      @file_group_difference.subsets.size.should == 5
       
      # has_many :subsets, FileGroupDifferenceSubset
    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do
    
    before(:all) do
      @v1_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/versionInventory.xml')
      @v1_inventory = FileInventory.parse(@v1_inventory_pathname.read)
      @v1_content = @v1_inventory.groups[0]

      @v3_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0003/versionInventory.xml')
      @v3_inventory = FileInventory.parse(@v3_inventory_pathname.read)
      @v3_content = @v3_inventory.groups[0]
    end

    before(:each) do
      @diff = FileGroupDifference.new
    end

    # Unit test for method: {Moab::FileGroupDifference#summary}
    # Which returns: [FileGroupDifference] Clone just this element for inclusion in a versionMetadata structure
    # For input parameters: (None)
    specify 'Moab::FileGroupDifference#summary' do
      basis_group = @v1_content
      other_group = @v3_content
      @diff.compare_file_groups(basis_group, other_group)
      summary = @diff.summary()
      summary.should be_instance_of(FileGroupDifference)
      summary.group_id = ''
      summary.difference_count = 1
      summary.identical = 1
      summary.renamed = 1
      summary.modified = 1
      summary.deleted = 1
      summary.added = 1
      summary.subsets.size.should == 0
      
       
      # def summary()
      #   FileGroupDifference.new(
      #       :group_id => @group_id,
      #       :identical => @identical,
      #       :renamed => @renamed,
      #       :modified => @modified,
      #       :deleted => @deleted,
      #       :added => @added
      #   )
      # end
    end
    
    # Unit test for method: {Moab::FileGroupDifference#matching_keys}
    # Which returns: [Array] Compare the keys of two hashes and return the intersection
    # For input parameters:
    # * basis_hash [Hash] = The first hash being compared 
    # * other_hash [Hash] = The second hash being compared 
    specify 'Moab::FileGroupDifference#matching_keys' do
      basis_hash = @v1_content.path_hash
      other_hash = @v3_content.path_hash
      basis_hash.keys. should == ["intro-1.jpg", "intro-2.jpg", "page-1.jpg", "page-2.jpg", "page-3.jpg", "title.jpg"]
      other_hash.keys. should == ["page-1.jpg", "page-2.jpg", "page-3.jpg", "page-4.jpg", "title.jpg"]
      matching_keys = @diff.matching_keys(basis_hash, other_hash)
      matching_keys.size.should == 4
      matching_keys.should == ["page-1.jpg", "page-2.jpg", "page-3.jpg", "title.jpg"]

      # def matching_keys(basis_hash, other_hash)
      #   basis_hash.keys & other_hash.keys
      # end
    end
    
    # Unit test for method: {Moab::FileGroupDifference#basis_only_keys}
    # Which returns: [Array] Compare the keys of two hashes and return the keys unique to the first hash
    # For input parameters:
    # * basis_hash [Hash] = The first hash being compared 
    # * other_hash [Hash] = The second hash being compared 
    specify 'Moab::FileGroupDifference#basis_only_keys' do
      basis_hash = @v1_content.path_hash
      other_hash = @v3_content.path_hash
      basis_hash.keys. should == ["intro-1.jpg", "intro-2.jpg", "page-1.jpg", "page-2.jpg", "page-3.jpg", "title.jpg"]
      other_hash.keys. should == ["page-1.jpg", "page-2.jpg", "page-3.jpg", "page-4.jpg", "title.jpg"]
      basis_only_keys = @diff.basis_only_keys(basis_hash, other_hash)
      basis_only_keys.size.should == 2
      basis_only_keys.should == ["intro-1.jpg", "intro-2.jpg"]

      # def basis_only_keys(basis_hash, other_hash)
      #   basis_hash.keys - other_hash.keys
      # end
    end
    
    # Unit test for method: {Moab::FileGroupDifference#other_only_keys}
    # Which returns: [Array] Compare the keys of two hashes and return the keys unique to the second hash
    # For input parameters:
    # * basis_hash [Hash] = The first hash being compared 
    # * other_hash [Hash] = The second hash being compared 
    specify 'Moab::FileGroupDifference#other_only_keys' do
      basis_hash = @v1_content.path_hash
      other_hash = @v3_content.path_hash
      basis_hash.keys. should == ["intro-1.jpg", "intro-2.jpg", "page-1.jpg", "page-2.jpg", "page-3.jpg", "title.jpg"]
      other_hash.keys. should == ["page-1.jpg", "page-2.jpg", "page-3.jpg", "page-4.jpg", "title.jpg"]
      other_only_keys = @diff.other_only_keys(basis_hash, other_hash)
      other_only_keys.size.should == 1
      other_only_keys.should == ["page-4.jpg"]

      # def other_only_keys(basis_hash, other_hash)
      #   other_hash.keys - basis_hash.keys
      # end
    end
    
    # Unit test for method: {Moab::FileGroupDifference#compare_file_groups}
    # Which returns: [FileGroupDifference] Compare two file groups and return a differences report
    # For input parameters:
    # * basis_group [FileGroup] = The file group that is the basis of the comparison 
    # * other_group [FileGroup] = The file group that is compared against the basis group 
    specify 'Moab::FileGroupDifference#compare_file_groups' do
      basis_group = @v1_content
      other_group = @v3_content
      basis_group.group_id.should == "content"
      basis_group.data_source.should include("data/jq937jp0017/v1/content")
      other_group.data_source.should include("data/jq937jp0017/v3/content")
      @diff.should_receive(:compare_matching_signatures).with(basis_group, other_group)
      @diff.should_receive(:compare_non_matching_signatures).with(basis_group, other_group)
      return_value = @diff.compare_file_groups(basis_group, other_group)
      return_value.should == @diff
      @diff.group_id.should == basis_group.group_id

      # def compare_file_groups(basis_group, other_group)
      #   @group_id = basis_group.group_id
      #   compare_matching_signatures(basis_group, other_group)
      #   compare_non_matching_signatures(basis_group, other_group)
      #   self
      # end
    end
    
    # Unit test for method: {Moab::FileGroupDifference#compare_matching_signatures}
    # Which returns: [void] For signatures that are present in both groups, report which file instances are identical or renamed
    # For input parameters:
    # * basis_group [FileGroup] = The file group that is the basis of the comparison 
    # * other_group [FileGroup] = The file group that is compared against the basis group 
    specify 'Moab::FileGroupDifference#compare_matching_signatures' do
      basis_group = @v1_content
      other_group = @v3_content
      @diff.compare_matching_signatures(basis_group, other_group)
      @diff.subsets.size.should == 2
      (@diff.subsets.collect {|s| s.change}).should == ["identical", "renamed"]
      (@diff.subsets.collect {|s| s.files.size}).should == [1, 2]
      @diff.identical.should == 1
      @diff.renamed.should == 2

      # def compare_matching_signatures(basis_group,other_group)
      #   @subsets << unchanged_subset = FileGroupDifferenceSubset.new(:change => 'identical')
      #   @subsets << renamed_subset = FileGroupDifferenceSubset.new(:change => 'renamed')
      #   matching_keys(basis_group.signature_hash, other_group.signature_hash).each do |signature|
      #     basis_paths = basis_group.signature_hash[signature].paths
      #     other_paths = other_group.signature_hash[signature].paths
      #     unchanged_subset.files.concat(tabulate_unchanged_files(signature,basis_paths, other_paths))
      #     renamed_subset.files.concat(tabulate_renamed_files(signature,basis_paths, other_paths))
      #   end
      #   @identical = unchanged_subset.count = unchanged_subset.files.size
      #   @renamed = renamed_subset.count = renamed_subset.files.size
      # end
    end
    
    # Unit test for method: {Moab::FileGroupDifference#compare_non_matching_signatures}
    # Which returns: [void] For signatures that are present in only one group, report which file instances are modified, deleted, or added
    # For input parameters:
    # * basis_group [FileGroup] = The file group that is the basis of the comparison 
    # * other_group [FileGroup] = The file group that is compared against the basis group 
    specify 'Moab::FileGroupDifference#compare_non_matching_signatures' do
      basis_group = @v1_content
      other_group = @v3_content
      @diff.compare_non_matching_signatures(basis_group, other_group)
      @diff.subsets.size.should == 3
      (@diff.subsets.collect {|s| s.change}).should == ["modified", "deleted", "added"]
      (@diff.subsets.collect {|s| s.files.size}).should == [1, 2, 1]
      @diff.modified.should == 1
      @diff.deleted.should == 2
      @diff.added.should == 1

      # def compare_non_matching_signatures(basis_group, other_group)
      #   @subsets << modified_subset = FileGroupDifferenceSubset.new(:change => 'modified')
      #   @subsets << deleted_subset = FileGroupDifferenceSubset.new(:change => 'deleted')
      #   @subsets << added_subset = FileGroupDifferenceSubset.new(:change => 'added')
      #   basis_only_keys(basis_group.signature_hash, other_group.signature_hash).each do |signature|
      #     basis_paths = basis_group.signature_hash[signature].paths
      #     other_path_hash = other_group.path_hash
      #     modified_subset.files.concat(tabulate_modified_files(signature,basis_paths, other_path_hash))
      #     deleted_subset.files.concat(tabulate_deleted_files(signature,basis_paths, other_path_hash))
      #   end
      #   other_only_keys(basis_group.signature_hash, other_group.signature_hash).each do |signature|
      #     other_paths = other_group.signature_hash[signature].paths
      #     added_subset.files.concat(tabulate_added_files(signature, other_paths, modified_subset))
      #   end
      #   @modified = modified_subset.count = modified_subset.files.size
      #   @deleted = deleted_subset.count = deleted_subset.files.size
      #   @added = added_subset.count = added_subset.files.size
      # end
    end
    
    # Unit test for method: {Moab::FileGroupDifference#tabulate_unchanged_files}
    # Which returns: [Array<FileInstanceDifference>] Detail comparison output for file manifestations having the same signature and identical filenames in both groups
    # For input parameters:
    # * signature [FileSignature] = The file signature of the file manifestations being compared 
    # * basis_paths [Array] = The file paths of the file manifestation for this signature in the basis group 
    # * other_paths [Array] = The file paths of the file manifestation for this signature in the other group 
    specify 'Moab::FileGroupDifference#tabulate_unchanged_files' do
      basis_group = @v1_content
      other_group = @v3_content
      signatures =  @diff.matching_keys(basis_group.signature_hash, other_group.signature_hash)
      (signatures.collect { |s| s.fixity}).should == [
          ["39450", "82fc107c88446a3119a51a8663d1e955", "d0857baa307a2e9efff42467b5abd4e1cf40fcd5"],
          ["19125", "a5099878de7e2e064432d6df44ca8827", "c0ccac433cf02a6cee89c14f9ba6072a184447a2"],
          ["40873", "1a726cd7963bd6d3ceb10a8c353ec166", "583220e0572640abcd3ddd97393d224e8053a6ad"]]
      signatures.each do |signature|
        basis_paths = basis_group.signature_hash[signature].paths
        other_paths = other_group.signature_hash[signature].paths
        unchanged_files = @diff.tabulate_unchanged_files(signature, basis_paths, other_paths)
        case signature.fixity
          when ["39450", "82fc107c88446a3119a51a8663d1e955", "d0857baa307a2e9efff42467b5abd4e1cf40fcd5"]
            basis_paths.should == ["page-2.jpg"]
            other_paths.should == ["page-3.jpg"]
            unchanged_files.size.should == 0
          when ["19125", "a5099878de7e2e064432d6df44ca8827", "c0ccac433cf02a6cee89c14f9ba6072a184447a2"]
            basis_paths.should == ["page-3.jpg"]
            other_paths.should == ["page-4.jpg"]
            unchanged_files.size.should == 0
          when ["40873", "1a726cd7963bd6d3ceb10a8c353ec166", "583220e0572640abcd3ddd97393d224e8053a6ad"]
            basis_paths.should == ["title.jpg"]
            other_paths.should == ["title.jpg"]
            unchanged_files.size.should == 1
            (file_instance_diff = unchanged_files[0]).should be_instance_of(FileInstanceDifference)
            file_instance_diff.change.should == "identical"
            file_instance_diff.basis_path.should == "title.jpg"
            file_instance_diff.other_path.should == "same"
            file_instance_diff.signatures[0].fixity.should ==
                ["40873", "1a726cd7963bd6d3ceb10a8c353ec166", "583220e0572640abcd3ddd97393d224e8053a6ad"]
        end
      end

      # def tabulate_unchanged_files(signature, basis_paths, other_paths)
      #   unchanged_files = Array.new
      #   matching_paths = basis_paths & other_paths
      #   matching_paths.each do |path|
      #     fid = FileInstanceDifference.new(:change => 'identical')
      #     fid.basis_path = path
      #     fid.other_path = "same"
      #     fid.signatures << signature
      #     unchanged_files << fid
      #   end
      #   unchanged_files
      # end
    end
    
    # Unit test for method: {Moab::FileGroupDifference#tabulate_renamed_files}
    # Which returns: [Array<FileInstanceDifference>] Detail comparison output for file manifestations having the same signature, but different filenames in the two groups
    # For input parameters:
    # * signature [FileSignature] = The file signature of the file manifestations being compared 
    # * basis_paths [Array] = The file paths of the file manifestation for this signature in the basis group 
    # * other_paths [Array] = The file paths of the file manifestation for this signature in the other group 
    specify 'Moab::FileGroupDifference#tabulate_renamed_files' do
      basis_group = @v1_content
      other_group = @v3_content
      signatures =  @diff.matching_keys(basis_group.signature_hash, other_group.signature_hash)
      (signatures.collect { |s| s.fixity}).should == [
          ["39450", "82fc107c88446a3119a51a8663d1e955", "d0857baa307a2e9efff42467b5abd4e1cf40fcd5"],
          ["19125", "a5099878de7e2e064432d6df44ca8827", "c0ccac433cf02a6cee89c14f9ba6072a184447a2"],
          ["40873", "1a726cd7963bd6d3ceb10a8c353ec166", "583220e0572640abcd3ddd97393d224e8053a6ad"]]
      signatures.each do |signature|
        basis_paths = basis_group.signature_hash[signature].paths
        other_paths = other_group.signature_hash[signature].paths
        renamed_files = @diff.tabulate_renamed_files(signature, basis_paths, other_paths)
        case signature.fixity
          when ["39450", "82fc107c88446a3119a51a8663d1e955", "d0857baa307a2e9efff42467b5abd4e1cf40fcd5"]
            basis_paths.should == ["page-2.jpg"]
            other_paths.should == ["page-3.jpg"]
            renamed_files.size.should == 1
            (file_instance_diff = renamed_files[0]).should be_instance_of(FileInstanceDifference)
            file_instance_diff.change.should == "renamed"
            file_instance_diff.basis_path.should == "page-2.jpg"
            file_instance_diff.other_path.should == "page-3.jpg"
            file_instance_diff.signatures[0].fixity.should ==
                ["39450", "82fc107c88446a3119a51a8663d1e955", "d0857baa307a2e9efff42467b5abd4e1cf40fcd5"]
          when ["19125", "a5099878de7e2e064432d6df44ca8827", "c0ccac433cf02a6cee89c14f9ba6072a184447a2"]
            basis_paths.should == ["page-3.jpg"]
            other_paths.should == ["page-4.jpg"]
            renamed_files.size.should == 1
            (file_instance_diff = renamed_files[0]).should be_instance_of(FileInstanceDifference)
            file_instance_diff.change.should == "renamed"
            file_instance_diff.basis_path.should == "page-3.jpg"
            file_instance_diff.other_path.should == "page-4.jpg"
            file_instance_diff.signatures[0].fixity.should ==
                ["19125", "a5099878de7e2e064432d6df44ca8827", "c0ccac433cf02a6cee89c14f9ba6072a184447a2"]
          when ["40873", "1a726cd7963bd6d3ceb10a8c353ec166", "583220e0572640abcd3ddd97393d224e8053a6ad"]
            basis_paths.should == ["title.jpg"]
            other_paths.should == ["title.jpg"]
            renamed_files.size.should == 0
        end
      end

      # def tabulate_renamed_files(signature, basis_paths, other_paths)
      #   renamed_files = Array.new
      #   basis_only_paths = basis_paths - other_paths
      #   other_only_paths = other_paths - basis_paths
      #   maxsize = [basis_only_paths.size,other_only_paths.size].max
      #   (0..maxsize-1).each do |n|
      #     fid = FileInstanceDifference.new(:change => 'renamed')
      #     fid.basis_path = basis_only_paths[n]
      #     fid.other_path = other_only_paths[n]
      #     fid.signatures << signature
      #     renamed_files << fid
      #   end
      #   renamed_files
      # end
    end
    
    # Unit test for method: {Moab::FileGroupDifference#tabulate_modified_files}
    # Which returns: [Array<FileInstanceDifference>] Detail comparison output for file manifestations having the same filename, but different signatures in the two groups
    # For input parameters:
    # * signature [FileSignature] = The file signature of the file manifestations being compared 
    # * basis_paths [Array] = The file paths of the file manifestation for this signature in the basis group 
    # * other_path_hash [OrderedHash<String,FileSignature>] An index of file paths,
    #     used to test for existence of a filename in the otner file group

    specify 'Moab::FileGroupDifference#tabulate_modified_files' do
      basis_group = @v1_content
      other_group = @v3_content
      (other_path_hash = other_group.path_hash).keys.should ==
          ["page-1.jpg", "page-2.jpg", "page-3.jpg", "page-4.jpg", "title.jpg"]
      signatures =  @diff.basis_only_keys(basis_group.signature_hash, other_group.signature_hash)
      (signatures.collect { |s| s.fixity}).should == [
          ["41981", "915c0305bf50c55143f1506295dc122c", "60448956fbe069979fce6a6e55dba4ce1f915178"],
          ["39850", "77f1a4efdcea6a476505df9b9fba82a7", "a49ae3f3771d99ceea13ec825c9c2b73fc1a9915"],
          ["25153", "3dee12fb4f1c28351c7482b76ff76ae4", "906c1314f3ab344563acbbbe2c7930f08429e35b"]]
      signatures.each do |signature|
        basis_paths = basis_group.signature_hash[signature].paths
        modified_files = @diff.tabulate_modified_files(signature, basis_paths, other_path_hash)
        case signature.fixity
          when ["41981", "915c0305bf50c55143f1506295dc122c", "60448956fbe069979fce6a6e55dba4ce1f915178"]
            basis_paths.should == ["intro-1.jpg"]
            other_path_hash.has_key?(basis_paths[0]).should == false
            modified_files.size.should == 0
          when ["39850", "77f1a4efdcea6a476505df9b9fba82a7", "a49ae3f3771d99ceea13ec825c9c2b73fc1a9915"]
            basis_paths.should == ["intro-2.jpg"]
            other_path_hash.has_key?(basis_paths[0]).should == false
            modified_files.size.should == 0
          when ["25153", "3dee12fb4f1c28351c7482b76ff76ae4", "906c1314f3ab344563acbbbe2c7930f08429e35b"]
            basis_paths.should == ["page-1.jpg"]
            other_path_hash.has_key?(basis_paths[0]).should == true
            modified_files.size.should == 1
            (file_instance_diff = modified_files[0]).should be_instance_of(FileInstanceDifference)
            file_instance_diff.change.should == "modified"
            file_instance_diff.basis_path.should == "page-1.jpg"
            file_instance_diff.other_path.should == "same"
            file_instance_diff.signatures[0].fixity.should ==
                ["25153", "3dee12fb4f1c28351c7482b76ff76ae4", "906c1314f3ab344563acbbbe2c7930f08429e35b"]
        end
      end

      # def tabulate_modified_files(signature, basis_paths, other_path_hash)
      #   modified_files = Array.new
      #   basis_paths.each do |path|
      #     if other_path_hash.has_key?(path)
      #       fid = FileInstanceDifference.new(:change => 'modified')
      #       fid.basis_path = path
      #       fid.other_path = "same"
      #       fid.signatures << signature
      #       fid.signatures << other_path_hash[path]
      #       modified_files << fid
      #     end
      #   end
      #   modified_files
      # end
    end
    
    # Unit test for method: {Moab::FileGroupDifference#tabulate_deleted_files}
    # Which returns: [Array<FileInstanceDifference>] Detail comparison output for file manifestations having a filename and signature that only appears in the basis group
    # For input parameters:
    # * signature [FileSignature] = The file signature of the file manifestations being compared 
    # * basis_paths [Array] = The file paths of the file manifestation for this signature in the basis group 
    # * other_path_hash [OrderedHash<String,FileSignature>] An index of file paths,
    #     used to test for existence of a filename in the otner file group
    specify 'Moab::FileGroupDifference#tabulate_deleted_files' do
      basis_group = @v1_content
      other_group = @v3_content
      (other_path_hash = other_group.path_hash).keys.should ==
          ["page-1.jpg", "page-2.jpg", "page-3.jpg", "page-4.jpg", "title.jpg"]
      signatures =  @diff.basis_only_keys(basis_group.signature_hash, other_group.signature_hash)
      (signatures.collect { |s| s.fixity}).should == [
          ["41981", "915c0305bf50c55143f1506295dc122c", "60448956fbe069979fce6a6e55dba4ce1f915178"],
          ["39850", "77f1a4efdcea6a476505df9b9fba82a7", "a49ae3f3771d99ceea13ec825c9c2b73fc1a9915"],
          ["25153", "3dee12fb4f1c28351c7482b76ff76ae4", "906c1314f3ab344563acbbbe2c7930f08429e35b"]]
      signatures.each do |signature|
        basis_paths = basis_group.signature_hash[signature].paths
        deleted_files = @diff.tabulate_deleted_files(signature, basis_paths, other_path_hash)
        case signature.fixity
          when ["41981", "915c0305bf50c55143f1506295dc122c", "60448956fbe069979fce6a6e55dba4ce1f915178"]
            basis_paths.should == ["intro-1.jpg"]
            other_path_hash.has_key?(basis_paths[0]).should == false
            deleted_files.size.should == 1
            (file_instance_diff = deleted_files[0]).should be_instance_of(FileInstanceDifference)
            file_instance_diff.change.should == "deleted"
            file_instance_diff.basis_path.should == "intro-1.jpg"
            file_instance_diff.other_path.should == ""
            file_instance_diff.signatures[0].fixity.should ==
                ["41981", "915c0305bf50c55143f1506295dc122c", "60448956fbe069979fce6a6e55dba4ce1f915178"]
          when ["39850", "77f1a4efdcea6a476505df9b9fba82a7", "a49ae3f3771d99ceea13ec825c9c2b73fc1a9915"]
            basis_paths.should == ["intro-2.jpg"]
            other_path_hash.has_key?(basis_paths[0]).should == false
            deleted_files.size.should == 1
            (file_instance_diff = deleted_files[0]).should be_instance_of(FileInstanceDifference)
            file_instance_diff.change.should == "deleted"
            file_instance_diff.basis_path.should == "intro-2.jpg"
            file_instance_diff.other_path.should == ""
            file_instance_diff.signatures[0].fixity.should ==
                ["39850", "77f1a4efdcea6a476505df9b9fba82a7", "a49ae3f3771d99ceea13ec825c9c2b73fc1a9915"]
          when ["25153", "3dee12fb4f1c28351c7482b76ff76ae4", "906c1314f3ab344563acbbbe2c7930f08429e35b"]
            basis_paths.should == ["page-1.jpg"]
            other_path_hash.has_key?(basis_paths[0]).should == true
            deleted_files.size.should == 0
        end
      end

      # def tabulate_deleted_files(signature, basis_paths, other_path_hash)
      #   deleted_files = Array.new
      #   basis_paths.each do |path|
      #     unless other_path_hash.has_key?(path)
      #       fid = FileInstanceDifference.new(:change => 'deleted')
      #       fid.basis_path = path
      #       fid.other_path = ""
      #       fid.signatures << signature
      #       deleted_files << fid
      #     end
      #   end
      #   deleted_files
      # end
    end
    
    # Unit test for method: {Moab::FileGroupDifference#tabulate_added_files}
    # Which returns: [Array<FileInstanceDifference>] Detail comparison output for file manifestations having a signature that only appears in the other group, unless the filename was already tallied as modified
    # For input parameters:
    # * signature [FileSignature] = The file signature of the file manifestations being compared
    # * other_paths [Array] = The file paths of the file manifestation for this signature in the other group 
    # * modified_subset [FileGroupDifferenceSubset] = The set of files that are reported as modified
    specify 'Moab::FileGroupDifference#tabulate_added_files' do
      basis_group = @v1_content
      other_group = @v3_content
      signatures =  @diff.other_only_keys(basis_group.signature_hash, other_group.signature_hash)
      (signatures.collect { |s| s.fixity}).should == [
          ["32915", "c1c34634e2f18a354cd3e3e1574c3194", "0616a0bd7927328c364b2ea0b4a79c507ce915ed"],
          ["39539", "fe6e3ffa1b02ced189db640f68da0cc2", "43ced73681687bc8e6f483618f0dcff7665e0ba7"]]
      modified_subset = FileGroupDifferenceSubset.new(:change => 'modified')
      modified_subset.files << FileInstanceDifference.new(:basis_path=>"page-1.jpg")
      signatures.each do |signature|
        other_paths = other_group.signature_hash[signature].paths
        added_files = @diff.tabulate_added_files(signature, other_paths, modified_subset)
        case signature.fixity
          when["32915", "c1c34634e2f18a354cd3e3e1574c3194", "0616a0bd7927328c364b2ea0b4a79c507ce915ed"]
            other_paths.should == ["page-1.jpg"]
            added_files.size.should == 0
          when  ["39539", "fe6e3ffa1b02ced189db640f68da0cc2", "43ced73681687bc8e6f483618f0dcff7665e0ba7"]
            other_paths.should == ["page-2.jpg"]
            added_files.size.should == 1
            (file_instance_diff = added_files[0]).should be_instance_of(FileInstanceDifference)
            file_instance_diff.change.should == "added"
            file_instance_diff.basis_path.should == ""
            file_instance_diff.other_path.should == "page-2.jpg"
            file_instance_diff.signatures[0].fixity.should ==
                ["39539", "fe6e3ffa1b02ced189db640f68da0cc2", "43ced73681687bc8e6f483618f0dcff7665e0ba7"]
        end
      end

      # def tabulate_added_files(signature, other_paths, modified_subset)
      #   added_files = Array.new
      #   other_paths.each do |path|
      #     unless subset_contains_path?(modified_subset,path)
      #       fid = FileInstanceDifference.new(:change => 'added')
      #       fid.basis_path = ""
      #       fid.other_path = path
      #       fid.signatures << signature
      #       added_files << fid
      #     end
      #   end
      #   added_files
      # end
    end
    
    # Unit test for method: {Moab::FileGroupDifference#subset_contains_path?}
    # Which returns: [Boolean] true if the path is found in the subset's file array
    # For input parameters:
    # * subset [FileGroupDifferenceSubset] = The subset of changes to examine 
    # * path [String] = The path to look for 
    specify 'Moab::FileGroupDifference#subset_contains_path?' do
      subset = FileGroupDifferenceSubset.new(:change => 'modified')
      subset.files << FileInstanceDifference.new(:basis_path=>"page-2.jpg")
      @diff.subset_contains_path?(subset, "page-2.jpg").should == true
      @diff.subset_contains_path?(subset, "page-1.jpg").should == false

      # def subset_contains_path?(subset, path)
      #   (subset.files.collect{ |file| file.basis_path }).include?(path)
      # end
    end
  
  end

end
