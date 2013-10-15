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
      @v1_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/manifests/versionInventory.xml')
      @v1_inventory = FileInventory.parse(@v1_inventory_pathname.read)

      @v3_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0003/manifests/versionInventory.xml')
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
    # Which stores: [Integer] the total number of differences found between the two inventories that were compared  (dynamically calculated)
    specify 'Moab::FileGroupDifference#difference_count' do
      @file_group_difference.difference_count.should == 6
       
      # attribute :difference_count, Integer, :tag=> 'differenceCount',:on_save => Proc.new {|i| i.to_s}
       
      # def difference_count
      #   @renamed + @modified + @deleted +@added
      # end
    end
    
    # Unit test for attribute: {Moab::FileGroupDifference#identical}
    # Which stores: [Integer] How many files were unchanged
    specify 'Moab::FileGroupDifference#identical' do
      @file_group_difference.identical.should == 1

      # attribute :identical, Integer, :on_save => Proc.new {|n| n.to_s}
    end
    
    # Unit test for attribute: {Moab::FileGroupDifference#renamed}
    # Which stores: [Integer] How many files were renamed
    specify 'Moab::FileGroupDifference#renamed' do
      @file_group_difference.renamed.should == 2

      # attribute :renamed, Integer, :on_save => Proc.new {|n| n.to_s}
    end
    
    # Unit test for attribute: {Moab::FileGroupDifference#modified}
    # Which stores: [Integer] How many files were modified
    specify 'Moab::FileGroupDifference#modified' do
      @file_group_difference.modified.should == 1

      # attribute :modified, Integer, :on_save => Proc.new {|n| n.to_s}
    end
    
    # Unit test for attribute: {Moab::FileGroupDifference#deleted}
    # Which stores: [Integer] How many files were deleted
    specify 'Moab::FileGroupDifference#deleted' do
      @file_group_difference.deleted.should == 2

      # attribute :deleted, Integer, :on_save => Proc.new {|n| n.to_s}
    end
    
    # Unit test for attribute: {Moab::FileGroupDifference#added}
    # Which stores: [Integer] How many files were added
    specify 'Moab::FileGroupDifference#added' do
      @file_group_difference.added.should == 1
       
      # attribute :added, Integer, :on_save => Proc.new {|n| n.to_s}
    end
    
    # Unit test for attribute: {Moab::FileGroupDifference#subsets}
    # Which stores: [Array<FileGroupDifferenceSubset>] A set of Arrays (one for each change type), each of which contains an collection of file-level differences having that change type.
    specify 'Moab::FileGroupDifference#subsets' do
      @file_group_difference.subsets.size.should == 5
       
      # has_many :subsets, FileGroupDifferenceSubset
    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do
    
    before(:all) do
      @v1_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/manifests/versionInventory.xml')
      @v1_inventory = FileInventory.parse(@v1_inventory_pathname.read)
      @v1_content = @v1_inventory.groups[0]

      @v3_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0003/manifests/versionInventory.xml')
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

    # @return [Hash<Symbol,Array>] Sets of filenames grouped by change type for use in performing file or metadata operations
    specify 'Moab::FileGroupDifference#file_deltas' do
      @diff.compare_file_groups(@v1_content, @v3_content)
      deltas = @diff.file_deltas
      deltas[:added].should ==  ["page-2.jpg"]
      deltas[:deleted].should == ["intro-1.jpg", "intro-2.jpg"]
      deltas[:modified].should == ["page-1.jpg"]
      deltas[:copied].should match_array [
          {:basis=>["page-2.jpg"], :other=>["page-3.jpg"]},
          {:basis=>["page-3.jpg"], :other=>["page-4.jpg"]},
          {:basis=>["title.jpg"], :other=>["title.jpg"]}
      ]
      v1 = FileGroup.new.group_from_directory(@fixtures.join('data/duplicates/v0001'))
      v2 = FileGroup.new.group_from_directory(@fixtures.join('data/duplicates/v0002'))
      @diff = FileGroupDifference.new
      @diff.compare_file_groups(v1,v2)
      deltas = @diff.file_deltas
      deltas[:added].should ==  []
      deltas[:deleted].should == []
      deltas[:modified].should == []
      deltas[:copied].should match_array [
          {:basis=>["a1.txt", "a2.txt", "a3.txt"], :other=>["a1.txt", "a4.txt", "a5.txt", "a6.txt"]},
          {:basis=>["b1.txt", "b2.txt"], :other=>["b1.txt"]}
      ]
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
      basis_group.data_source.should include("data/jq937jp0017/v0001/content")
      other_group.data_source.should include("data/jq937jp0017/v0003/content")
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

    specify 'Moab::FileGroupDifference#compare_file_groups with empty group' do
      basis_group = @v1_content
      other_group = FileGroup.new(:group_id => "content")
      diff = @diff.compare_file_groups(basis_group, other_group)
      diff.difference_count.should == 6
      diff.deleted.should == 6
      diff.subset('deleted').count.should == 6
      #puts JSON.pretty_generate(diff.to_hash)
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
      #   matching_signatures = matching_keys(basis_group.signature_hash, other_group.signature_hash)
      #   tabulate_unchanged_files(matching_signatures, basis_group.signature_hash, other_group.signature_hash)
      #   tabulate_renamed_files(matching_signatures, basis_group.signature_hash, other_group.signature_hash)
      # end
    end
    
    # Unit test for method: {Moab::FileGroupDifference#compare_non_matching_signatures}
    # Which returns: [void] For signatures that are present in only one or the other group, report which file instances are modified, deleted, or added
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
      #   basis_only_signatures = basis_only_keys(basis_group.signature_hash, other_group.signature_hash)
      #   other_only_signatures = other_only_keys(basis_group.signature_hash, other_group.signature_hash)
      #   basis_path_hash = basis_group.path_hash_subset(basis_only_signatures)
      #   other_path_hash = other_group.path_hash_subset(other_only_signatures)
      #   tabulate_modified_files(basis_path_hash, other_path_hash)
      #   tabulate_deleted_files(basis_path_hash, other_path_hash)
      #   tabulate_added_files(basis_path_hash, other_path_hash)
      # end
    end
    
    # Unit test for method: {Moab::FileGroupDifference#tabulate_unchanged_files}
    # Which returns: [FileGroupDifferenceSubset] Container for reporting the set of file-level differences of type 'identical'
    # For input parameters:
    # * matching_signatures [Array<FileSignature>] = The file signature of the file manifestations being compared
    # * basis_signature_hash [OrderedHash<FileSignature, FileManifestation>] = Signature to file path mapping from the file group that is the basis of the comparison
    # * other_signature_hash [OrderedHash<FileSignature, FileManifestation>] = Signature to file path mapping from the file group that is the being compared to the basis group
    specify 'Moab::FileGroupDifference#tabulate_unchanged_files' do
      basis_group = @v1_content
      other_group = @v3_content
      signatures =  @diff.matching_keys(basis_group.signature_hash, other_group.signature_hash)
      (signatures.collect { |s| s.fixity}).should == [
           {:size=>"39450", :md5=>"82fc107c88446a3119a51a8663d1e955", :sha1=>"d0857baa307a2e9efff42467b5abd4e1cf40fcd5", :sha256=>"235de16df4804858aefb7690baf593fb572d64bb6875ec522a4eea1f4189b5f0"},
           {:size=>"19125", :md5=>"a5099878de7e2e064432d6df44ca8827", :sha1=>"c0ccac433cf02a6cee89c14f9ba6072a184447a2", :sha256=>"7bd120459eff0ecd21df94271e5c14771bfca5137d1dd74117b6a37123dfe271"},
           {:size=>"40873", :md5=>"1a726cd7963bd6d3ceb10a8c353ec166", :sha1=>"583220e0572640abcd3ddd97393d224e8053a6ad", :sha256=>"8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5"}]

      unchanged_subset = @diff.tabulate_unchanged_files(signatures, basis_group.signature_hash, other_group.signature_hash)
      unchanged_subset.should be_instance_of(FileGroupDifferenceSubset)
      unchanged_subset.change.should == 'identical'
      unchanged_subset.files.size.should == 1
      @diff.identical.should == 1
      file0 = unchanged_subset.files[0]
      file0.change.should == 'identical'
      file0.basis_path.should == 'title.jpg'
      file0.other_path.should == 'same'
      file0.signatures[0].fixity.should == {:size=>"40873", :md5=> "1a726cd7963bd6d3ceb10a8c353ec166", :sha1=> "583220e0572640abcd3ddd97393d224e8053a6ad", :sha256=>"8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5"}

      # def tabulate_unchanged_files(signature, basis_paths, other_paths)
      #   unchanged_files = Array.new
      #   matching_signatures.each do |signature|
      #     basis_paths = basis_signature_hash[signature].paths
      #     other_paths = other_signature_hash[signature].paths
      #     matching_paths = basis_paths & other_paths
      #     matching_paths.each do |path|
      #       fid = FileInstanceDifference.new(:change => 'identical')
      #       fid.basis_path = path
      #       fid.other_path = "same"
      #       fid.signatures << signature
      #       unchanged_files << fid
      #     end
      #   end
      #   unchanged_subset = FileGroupDifferenceSubset.new(:change => 'identical')
      #   unchanged_subset.files = unchanged_files
      #   @subsets << unchanged_subset
      #   @identical = unchanged_subset.count
      #   unchanged_subset
      # end
    end
    
    # Unit test for method: {Moab::FileGroupDifference#tabulate_renamed_files}
    # Which returns: [FileGroupDifferenceSubset] Container for reporting the set of file-level differences of type 'renamed'
    # For input parameters:
    # * matching_signatures [Array<FileSignature>] = The file signature of the file manifestations being compared
    # * basis_signature_hash [OrderedHash<FileSignature, FileManifestation>] = Signature to file path mapping from the file group that is the basis of the comparison
    # * other_signature_hash [OrderedHash<FileSignature, FileManifestation>] = Signature to file path mapping from the file group that is the being compared to the basis group
    specify 'Moab::FileGroupDifference#tabulate_renamed_files' do
      basis_group = @v1_content
      other_group = @v3_content
      signatures =  @diff.matching_keys(basis_group.signature_hash, other_group.signature_hash)
      (signatures.collect { |s| s.fixity}).should == [
          {:size=>"39450", :md5=>"82fc107c88446a3119a51a8663d1e955", :sha1=>"d0857baa307a2e9efff42467b5abd4e1cf40fcd5", :sha256=>"235de16df4804858aefb7690baf593fb572d64bb6875ec522a4eea1f4189b5f0"},
          {:size=>"19125", :md5=>"a5099878de7e2e064432d6df44ca8827", :sha1=>"c0ccac433cf02a6cee89c14f9ba6072a184447a2", :sha256=>"7bd120459eff0ecd21df94271e5c14771bfca5137d1dd74117b6a37123dfe271"},
          {:size=>"40873", :md5=>"1a726cd7963bd6d3ceb10a8c353ec166", :sha1=>"583220e0572640abcd3ddd97393d224e8053a6ad", :sha256=>"8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5"}]
      renamed_subset = @diff.tabulate_renamed_files(signatures, basis_group.signature_hash, other_group.signature_hash)
      renamed_subset.should be_instance_of(FileGroupDifferenceSubset)
      renamed_subset.change.should == 'renamed'
      renamed_subset.files.size.should == 2
      @diff.renamed.should == 2
      file0 = renamed_subset.files[0]
      file0.change.should == 'renamed'
      file0.basis_path.should == 'page-2.jpg'
      file0.other_path.should == 'page-3.jpg'
      file0.signatures[0].fixity.should == {:size=>"39450", :md5=>"82fc107c88446a3119a51a8663d1e955", :sha1=>"d0857baa307a2e9efff42467b5abd4e1cf40fcd5", :sha256=>"235de16df4804858aefb7690baf593fb572d64bb6875ec522a4eea1f4189b5f0"}
      file1 = renamed_subset.files[1]
      file1.change.should == 'renamed'
      file1.basis_path.should == 'page-3.jpg'
      file1.other_path.should == 'page-4.jpg'
      file1.signatures[0].fixity.should == {:size=>"19125", :md5=>"a5099878de7e2e064432d6df44ca8827", :sha1=>"c0ccac433cf02a6cee89c14f9ba6072a184447a2", :sha256=>"7bd120459eff0ecd21df94271e5c14771bfca5137d1dd74117b6a37123dfe271"}

      # def tabulate_renamed_files(matching_signatures, basis_signature_hash, other_signature_hash)
      #   renamed_files = Array.new
      #   matching_signatures.each do |signature|
      #     basis_paths = basis_signature_hash[signature].paths
      #     other_paths = other_signature_hash[signature].paths
      #     basis_only_paths = basis_paths - other_paths
      #     other_only_paths = other_paths - basis_paths
      #     maxsize = [basis_only_paths.size,other_only_paths.size].max
      #     (0..maxsize-1).each do |n|
      #       fid = FileInstanceDifference.new(:change => 'renamed')
      #       fid.basis_path = basis_only_paths[n]
      #       fid.other_path = other_only_paths[n]
      #       fid.signatures << signature
      #       renamed_files << fid
      #     end
      #   end
      #   renamed_subset = FileGroupDifferenceSubset.new(:change => 'renamed')
      #   renamed_subset.files = renamed_files
      #   @subsets << renamed_subset
      #   @renamed = renamed_subset.count
      #   renamed_subset
      # end
    end
    
    # Unit test for method: {Moab::FileGroupDifference#tabulate_modified_files}
    # Which returns: [FileGroupDifferenceSubset] Container for reporting the set of file-level differences of type 'modified'
    # For input parameters:
    # * basis_path_hash [OrderedHash<String,FileSignature>] = The file paths and associated signatures for manifestations appearing only in the basis group
    # * other_path_hash [OrderedHash<String,FileSignature>] = The file paths and associated signatures for manifestations appearing only in the other group
    specify 'Moab::FileGroupDifference#tabulate_modified_files' do
      basis_group = @v1_content
      other_group = @v3_content
      (other_path_hash = other_group.path_hash).keys.should ==
          ["page-1.jpg", "page-2.jpg", "page-3.jpg", "page-4.jpg", "title.jpg"]
      signatures =  @diff.basis_only_keys(basis_group.signature_hash, other_group.signature_hash)
      (signatures.collect { |s| s.fixity}).should == [
          {:size=>"41981", :md5=>"915c0305bf50c55143f1506295dc122c", :sha1=>"60448956fbe069979fce6a6e55dba4ce1f915178", :sha256=>"4943c6ffdea7e33b74fd7918de900de60e9073148302b0ad1bf5df0e6cec032a"},
          {:size=>"39850", :md5=>"77f1a4efdcea6a476505df9b9fba82a7", :sha1=>"a49ae3f3771d99ceea13ec825c9c2b73fc1a9915", :sha256=>"3a28718a8867e4329cd0363a84aee1c614d0f11229a82e87c6c5072a6e1b15e7"},
          {:size=>"25153", :md5=>"3dee12fb4f1c28351c7482b76ff76ae4", :sha1=>"906c1314f3ab344563acbbbe2c7930f08429e35b", :sha256=>"41aaf8598c9d8e3ee5d55efb9be11c542099d9f994b5935995d0abea231b8bad"}]
      basis_only_signatures = @diff.basis_only_keys(basis_group.signature_hash, other_group.signature_hash)
      other_only_signatures = @diff.other_only_keys(basis_group.signature_hash, other_group.signature_hash)
      basis_path_hash = basis_group.path_hash_subset(basis_only_signatures)
      other_path_hash = other_group.path_hash_subset(other_only_signatures)
      modified_subset = @diff.tabulate_modified_files(basis_path_hash, other_path_hash)
      modified_subset.should be_instance_of(FileGroupDifferenceSubset)
      modified_subset.change.should == 'modified'
      modified_subset.files.size.should == 1
      @diff.modified.should == 1
      file0 = modified_subset.files[0]
      file0.change.should == 'modified'
      file0.basis_path.should == 'page-1.jpg'
      file0.other_path.should == 'same'
      file0.signatures[0].fixity.should == {:size=>"25153", :md5=>"3dee12fb4f1c28351c7482b76ff76ae4", :sha1=>"906c1314f3ab344563acbbbe2c7930f08429e35b", :sha256=>"41aaf8598c9d8e3ee5d55efb9be11c542099d9f994b5935995d0abea231b8bad"}

      # def tabulate_modified_files(basis_path_hash, other_path_hash)
      #   modified_files = Array.new
      #   matching_keys(basis_path_hash, other_path_hash).each do |path|
      #     fid = FileInstanceDifference.new(:change => 'modified')
      #     fid.basis_path = path
      #     fid.other_path = "same"
      #     fid.signatures << basis_path_hash[path]
      #     fid.signatures << other_path_hash[path]
      #     modified_files << fid
      #   end
      #   modified_subset = FileGroupDifferenceSubset.new(:change => 'modified')
      #   modified_subset.files = modified_files
      #   @subsets << modified_subset
      #   @modified = modified_subset.count
      #   modified_subset
      # end
    end
    
    # Unit test for method: {Moab::FileGroupDifference#tabulate_deleted_files}
    # Which returns: [FileGroupDifferenceSubset] Container for reporting the set of file-level differences of type 'deleted'
    # For input parameters:
    # * basis_path_hash [OrderedHash<String,FileSignature>] = The file paths and associated signatures for manifestations appearing only in the basis group
    # * other_path_hash [OrderedHash<String,FileSignature>] = The file paths and associated signatures for manifestations appearing only in the other group
    specify 'Moab::FileGroupDifference#tabulate_deleted_files' do
      basis_group = @v1_content
      other_group = @v3_content
      (other_path_hash = other_group.path_hash).keys.should ==
          ["page-1.jpg", "page-2.jpg", "page-3.jpg", "page-4.jpg", "title.jpg"]
      signatures =  @diff.basis_only_keys(basis_group.signature_hash, other_group.signature_hash)
      (signatures.collect { |s| s.fixity}).should == [
          {:size=>"41981", :md5=>"915c0305bf50c55143f1506295dc122c", :sha1=>"60448956fbe069979fce6a6e55dba4ce1f915178", :sha256=>"4943c6ffdea7e33b74fd7918de900de60e9073148302b0ad1bf5df0e6cec032a"},
          {:size=>"39850", :md5=>"77f1a4efdcea6a476505df9b9fba82a7", :sha1=>"a49ae3f3771d99ceea13ec825c9c2b73fc1a9915", :sha256=>"3a28718a8867e4329cd0363a84aee1c614d0f11229a82e87c6c5072a6e1b15e7"},
          {:size=>"25153", :md5=>"3dee12fb4f1c28351c7482b76ff76ae4", :sha1=>"906c1314f3ab344563acbbbe2c7930f08429e35b", :sha256=>"41aaf8598c9d8e3ee5d55efb9be11c542099d9f994b5935995d0abea231b8bad"}]
      basis_only_signatures = @diff.basis_only_keys(basis_group.signature_hash, other_group.signature_hash)
      other_only_signatures = @diff.other_only_keys(basis_group.signature_hash, other_group.signature_hash)
      basis_path_hash = basis_group.path_hash_subset(basis_only_signatures)
      other_path_hash = other_group.path_hash_subset(other_only_signatures)
      deleted_subset = @diff.tabulate_deleted_files(basis_path_hash, other_path_hash)
      deleted_subset.should be_instance_of(FileGroupDifferenceSubset)
      deleted_subset.change.should == 'deleted'
      deleted_subset.files.size.should == 2
      @diff.deleted.should == 2
      file0 = deleted_subset.files[0]
      file0.change.should == 'deleted'
      file0.basis_path.should == 'intro-1.jpg'
      file0.other_path.should == ''
      file0.signatures[0].fixity.should == {:size=>"41981", :md5=>"915c0305bf50c55143f1506295dc122c", :sha1=>"60448956fbe069979fce6a6e55dba4ce1f915178", :sha256=>"4943c6ffdea7e33b74fd7918de900de60e9073148302b0ad1bf5df0e6cec032a"}
      file1 = deleted_subset.files[1]
      file1.change.should == 'deleted'
      file1.basis_path.should == 'intro-2.jpg'
      file1.other_path.should == ''
      file1.signatures[0].fixity.should == {:size=>"39850", :md5=>"77f1a4efdcea6a476505df9b9fba82a7", :sha1=>"a49ae3f3771d99ceea13ec825c9c2b73fc1a9915", :sha256=>"3a28718a8867e4329cd0363a84aee1c614d0f11229a82e87c6c5072a6e1b15e7"}

      # def tabulate_deleted_files(basis_path_hash, other_path_hash)
      #   deleted_files = Array.new
      #   basis_only_keys(basis_path_hash, other_path_hash).each do |path|
      #     fid = FileInstanceDifference.new(:change => 'deleted')
      #     fid.basis_path = path
      #     fid.other_path = ""
      #     fid.signatures << basis_path_hash[path]
      #     deleted_files << fid
      #   end
      #   deleted_subset = FileGroupDifferenceSubset.new(:change => 'deleted')
      #   deleted_subset.files = deleted_files
      #   @subsets << deleted_subset
      #   @deleted = deleted_subset.count
      #   deleted_subset
      # end
    end
    
    # Unit test for method: {Moab::FileGroupDifference#tabulate_added_files}
    # Which returns: [FileGroupDifferenceSubset] Container for reporting the set of file-level differences of type 'added'
    # For input parameters:
    # * basis_path_hash [OrderedHash<String,FileSignature>] = The file paths and associated signatures for manifestations appearing only in the basis group
    # * other_path_hash [OrderedHash<String,FileSignature>] = The file paths and associated signatures for manifestations appearing only in the other group
    specify 'Moab::FileGroupDifference#tabulate_added_files' do
      basis_group = @v1_content
      other_group = @v3_content
      signatures =  @diff.other_only_keys(basis_group.signature_hash, other_group.signature_hash)
      (signatures.collect { |s| s.fixity}).should == [
          {:size=>"32915", :md5=>"c1c34634e2f18a354cd3e3e1574c3194", :sha1=>"0616a0bd7927328c364b2ea0b4a79c507ce915ed", :sha256=>"b78cc53b7b8d9ed86d5e3bab3b699c7ed0db958d4a111e56b6936c8397137de0"},
          {:size=>"39539", :md5=>"fe6e3ffa1b02ced189db640f68da0cc2", :sha1=>"43ced73681687bc8e6f483618f0dcff7665e0ba7", :sha256=>"42c0cd1fe06615d8fdb8c2e3400d6fe38461310b4ecc252e1774e0c9e3981afa"}]
      basis_only_signatures = @diff.basis_only_keys(basis_group.signature_hash, other_group.signature_hash)
      other_only_signatures = @diff.other_only_keys(basis_group.signature_hash, other_group.signature_hash)
      basis_path_hash = basis_group.path_hash_subset(basis_only_signatures)
      other_path_hash = other_group.path_hash_subset(other_only_signatures)
      added_subset = @diff.tabulate_added_files(basis_path_hash, other_path_hash)
      added_subset.should be_instance_of(FileGroupDifferenceSubset)
      added_subset.change.should == 'added'
      added_subset.files.size.should == 1
      @diff.added.should == 1
      file0 = added_subset.files[0]
      file0.change.should == 'added'
      file0.basis_path.should == ''
      file0.other_path.should == 'page-2.jpg'
      file0.signatures[0].fixity.should == {:size=>"39539", :md5=>"fe6e3ffa1b02ced189db640f68da0cc2", :sha1=>"43ced73681687bc8e6f483618f0dcff7665e0ba7", :sha256=>"42c0cd1fe06615d8fdb8c2e3400d6fe38461310b4ecc252e1774e0c9e3981afa"}

      # def tabulate_added_files(basis_path_hash, other_path_hash)
      #   added_files = Array.new
      #   other_only_keys(basis_path_hash, other_path_hash).each do |path|
      #     fid = FileInstanceDifference.new(:change => 'added')
      #     fid.basis_path = ""
      #     fid.other_path = path
      #     fid.signatures << other_path_hash[path]
      #     added_files << fid
      #   end
      #   added_subset = FileGroupDifferenceSubset.new(:change => 'added')
      #   added_subset.files = added_files
      #   @subsets << added_subset
      #   @added = added_subset.count
      #   added_subset
      # end
    end
  
  end

end
