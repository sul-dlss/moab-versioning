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
      file_group_difference = Moab::FileGroupDifference.new(opts)
      expect(file_group_difference).to be_instance_of(Moab::FileGroupDifference)

      # test initialization of arrays and hashes
      expect(file_group_difference.subsets).to be_kind_of(Array)
      expect(file_group_difference.subsets.size).to eq(0)

      # test initialization with options hash
      opts = Hash.new
      opts[:group_id] = 'Test group_id'
      file_group_difference = Moab::FileGroupDifference.new(opts)
      expect(file_group_difference.group_id).to eq(opts[:group_id])

      # def initialize(opts={})
      #   @subsets = Array.new
      #   super(opts)
      # end
    end

  end

  describe '=========================== INSTANCE ATTRIBUTES ===========================' do

    before(:all) do
      @v1_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/manifests/versionInventory.xml')
      @v1_inventory = Moab::FileInventory.parse(@v1_inventory_pathname.read)

      @v3_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0003/manifests/versionInventory.xml')
      @v3_inventory = Moab::FileInventory.parse(@v3_inventory_pathname.read)

      opts = {}
      @file_inventory_difference = Moab::FileInventoryDifference.new(opts)
      @file_inventory_difference.compare(@v1_inventory,@v3_inventory)

      @file_group_difference = @file_inventory_difference.group_differences[0]
      end

    # Unit test for attribute: {Moab::FileGroupDifference#group_id}
    # Which stores: [String] \@groupId = The name of the file group
    specify 'Moab::FileGroupDifference#group_id' do
      expect(@file_group_difference.group_id).to eq("content")

      # attribute :group_id, String, :tag => 'groupId', :key => true
    end

    # Unit test for attribute: {Moab::FileGroupDifference#difference_count}
    # Which stores: [Integer] the total number of differences found between the two inventories that were compared  (dynamically calculated)
    specify 'Moab::FileGroupDifference#difference_count' do
      expect(@file_group_difference.difference_count).to eq(6)

      # attribute :difference_count, Integer, :tag=> 'differenceCount',:on_save => Proc.new {|i| i.to_s}

      # def difference_count
      #   @renamed + @modified + @deleted +@added
      # end
    end

    # Unit test for attribute: {Moab::FileGroupDifference#identical}
    # Which stores: [Integer] How many files were unchanged
    specify 'Moab::FileGroupDifference#identical' do
      expect(@file_group_difference.identical).to eq(1)

      # attribute :identical, Integer, :on_save => Proc.new {|n| n.to_s}
    end

    # Unit test for attribute: {Moab::FileGroupDifference#renamed}
    # Which stores: [Integer] How many files were renamed
    specify 'Moab::FileGroupDifference#renamed' do
      expect(@file_group_difference.renamed).to eq(2)

      # attribute :renamed, Integer, :on_save => Proc.new {|n| n.to_s}
    end

    # Unit test for attribute: {Moab::FileGroupDifference#modified}
    # Which stores: [Integer] How many files were modified
    specify 'Moab::FileGroupDifference#modified' do
      expect(@file_group_difference.modified).to eq(1)

      # attribute :modified, Integer, :on_save => Proc.new {|n| n.to_s}
    end

    # Unit test for attribute: {Moab::FileGroupDifference#deleted}
    # Which stores: [Integer] How many files were deleted
    specify 'Moab::FileGroupDifference#deleted' do
      expect(@file_group_difference.deleted).to eq(2)

      # attribute :deleted, Integer, :on_save => Proc.new {|n| n.to_s}
    end

    # Unit test for attribute: {Moab::FileGroupDifference#added}
    # Which stores: [Integer] How many files were added
    specify 'Moab::FileGroupDifference#added' do
      expect(@file_group_difference.added).to eq(1)

      # attribute :added, Integer, :on_save => Proc.new {|n| n.to_s}
    end

    # Unit test for attribute: {Moab::FileGroupDifference#subsets}
    # Which stores: [Array<Moab::FileGroupDifferenceSubset>] A set of Arrays (one for each change type), each of which contains an collection of file-level differences having that change type.
    specify 'Moab::FileGroupDifference#subsets' do
      expect(@file_group_difference.subsets.size).to be >= 5

      # has_many :subsets, Moab::FileGroupDifferenceSubset
    end

  end

  describe '=========================== INSTANCE METHODS ===========================' do

    before(:all) do
      @v1_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/manifests/versionInventory.xml')
      @v1_inventory = Moab::FileInventory.parse(@v1_inventory_pathname.read)
      @v1_content = @v1_inventory.groups[0]

      @v3_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0003/manifests/versionInventory.xml')
      @v3_inventory = Moab::FileInventory.parse(@v3_inventory_pathname.read)
      @v3_content = @v3_inventory.groups[0]
    end

    before(:each) do
      @diff = Moab::FileGroupDifference.new
    end

    # Unit test for method: {Moab::FileGroupDifference#summary}
    # Which returns: [Moab::FileGroupDifference] Clone just this element for inclusion in a versionMetadata structure
    # For input parameters: (None)
    specify 'Moab::FileGroupDifference#summary' do
      basis_group = @v1_content
      other_group = @v3_content
      @diff.compare_file_groups(basis_group, other_group)
      summary = @diff.summary()
      expect(summary).to be_instance_of(Moab::FileGroupDifference)
      summary.group_id = ''
      summary.difference_count = 1
      summary.identical = 1
      summary.renamed = 1
      summary.modified = 1
      summary.deleted = 1
      summary.added = 1
      expect(summary.subsets.size).to eq(0)


      # def summary()
      #   Moab::FileGroupDifference.new(
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
      expect(basis_hash.keys). to eq(["intro-1.jpg", "intro-2.jpg", "page-1.jpg", "page-2.jpg", "page-3.jpg", "title.jpg"])
      expect(other_hash.keys). to eq(["page-1.jpg", "page-2.jpg", "page-3.jpg", "page-4.jpg", "title.jpg"])
      matching_keys = @diff.matching_keys(basis_hash, other_hash)
      expect(matching_keys.size).to eq(4)
      expect(matching_keys).to eq(["page-1.jpg", "page-2.jpg", "page-3.jpg", "title.jpg"])

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
      expect(basis_hash.keys). to eq(["intro-1.jpg", "intro-2.jpg", "page-1.jpg", "page-2.jpg", "page-3.jpg", "title.jpg"])
      expect(other_hash.keys). to eq(["page-1.jpg", "page-2.jpg", "page-3.jpg", "page-4.jpg", "title.jpg"])
      basis_only_keys = @diff.basis_only_keys(basis_hash, other_hash)
      expect(basis_only_keys.size).to eq(2)
      expect(basis_only_keys).to eq(["intro-1.jpg", "intro-2.jpg"])

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
      expect(basis_hash.keys). to eq(["intro-1.jpg", "intro-2.jpg", "page-1.jpg", "page-2.jpg", "page-3.jpg", "title.jpg"])
      expect(other_hash.keys). to eq(["page-1.jpg", "page-2.jpg", "page-3.jpg", "page-4.jpg", "title.jpg"])
      other_only_keys = @diff.other_only_keys(basis_hash, other_hash)
      expect(other_only_keys.size).to eq(1)
      expect(other_only_keys).to eq(["page-4.jpg"])

      # def other_only_keys(basis_hash, other_hash)
      #   other_hash.keys - basis_hash.keys
      # end
    end

    # Unit test for method: {Moab::FileGroupDifference#compare_file_groups}
    # Which returns: [Moab::FileGroupDifference] Compare two file groups and return a differences report
    # For input parameters:
    # * basis_group [Moab::FileGroup] = The file group that is the basis of the comparison
    # * other_group [Moab::FileGroup] = The file group that is compared against the basis group
    specify 'Moab::FileGroupDifference#compare_file_groups' do
      basis_group = @v1_content
      other_group = @v3_content
      expect(basis_group.group_id).to eq("content")
      expect(basis_group.data_source).to include("data/jq937jp0017/v0001/content")
      expect(other_group.data_source).to include("data/jq937jp0017/v0003/content")
      expect(@diff).to receive(:compare_matching_signatures).with(basis_group, other_group)
      expect(@diff).to receive(:compare_non_matching_signatures).with(basis_group, other_group)
      return_value = @diff.compare_file_groups(basis_group, other_group)
      expect(return_value).to eq(@diff)
      expect(@diff.group_id).to eq(basis_group.group_id)

      # def compare_file_groups(basis_group, other_group)
      #   @group_id = basis_group.group_id
      #   compare_matching_signatures(basis_group, other_group)
      #   compare_non_matching_signatures(basis_group, other_group)
      #   self
      # end
    end

    specify 'Moab::FileGroupDifference#compare_file_groups with empty group' do
      basis_group = @v1_content
      other_group = Moab::FileGroup.new(:group_id => "content")
      diff = @diff.compare_file_groups(basis_group, other_group)
      expect(diff.difference_count).to eq(6)
      expect(diff.deleted).to eq(6)
      #puts JSON.pretty_generate(diff.to_hash)
    end

    specify 'Moab::FileGroupDifference#compare_file_groups copyadded, copydeleted, renamed' do
      basis_group_string = <<-EOF
          <fileGroup groupId="content" dataSource="contentMetadata-all" fileCount="3" byteCount="6368941" blockCount="6222">
            <file>
              <fileSignature size="3182887" md5="ea6726038e370846910b4d103ffc1443" sha1="11b7a71251dbb57288782e0340685a1d5a12918d" sha256=""/>
              <fileInstance path="Original-1" datetime=""/>
              <fileInstance path="Copy-removed" datetime=""/>
            </file>
            <file>
              <fileSignature size="3167" md5="0effae25b53d55c6450d9fdb391488b3" sha1="e3abd068b7ee49a23a4af9e7b7818a41742b2aad" sha256=""/>
              <fileInstance path="Original-2" datetime=""/>
            </file>
            <file>
              <fileSignature size="3167" md5="c6450d9fdb391488b30effae25b53d55" sha1="ee49a23a4af9e7b7818a41742b2aade3abd068b7" sha256=""/>
              <fileInstance path="Original-3" datetime=""/>
            </file>
          </fileGroup>
      EOF
      other_group_string = <<-EOF
          <fileGroup groupId="content" dataSource="contentMetadata-all" fileCount="2" byteCount="3186054" blockCount="3113">
            <file>
              <fileSignature size="3182887" md5="ea6726038e370846910b4d103ffc1443" sha1="11b7a71251dbb57288782e0340685a1d5a12918d" sha256=""/>
              <fileInstance path="Original-1" datetime=""/>
            </file>
            <file>
              <fileSignature size="3167" md5="0effae25b53d55c6450d9fdb391488b3" sha1="e3abd068b7ee49a23a4af9e7b7818a41742b2aad" sha256=""/>
              <fileInstance path="Original-2" datetime=""/>
              <fileInstance path="Copy-added" datetime=""/>
            </file>
            <file>
              <fileSignature size="3167" md5="c6450d9fdb391488b30effae25b53d55" sha1="ee49a23a4af9e7b7818a41742b2aade3abd068b7" sha256=""/>
              <fileInstance path="File-renamed" datetime=""/>
            </file>
          </fileGroup>
      EOF
      basis_group = Moab::FileGroup.parse(basis_group_string)
      other_group = Moab::FileGroup.parse(other_group_string)
      diff = @diff.compare_file_groups(basis_group, other_group)
      #puts diff.to_xml
      expect(diff.difference_count).to eq(3)
      expect(diff.identical).to eq(2)
      expect(diff.copyadded).to eq(1)
      expect(diff.copydeleted).to eq(1)
      expect(diff.renamed).to eq(1)

      xmlObj1 = Nokogiri::XML(diff.subset_hash[:copyadded].to_xml)
      xmlObj2 = Nokogiri::XML(<<-EOF
        <subset change="copyadded" count="1">
          <file change="copyadded" basisPath="Original-2" otherPath="Copy-added">
            <fileSignature size="3167" md5="0effae25b53d55c6450d9fdb391488b3" sha1="e3abd068b7ee49a23a4af9e7b7818a41742b2aad" sha256=""/>
          </file>
        </subset>
      EOF
      )
      same = EquivalentXml.equivalent?(xmlObj1, xmlObj2, opts = { :element_order => false, :normalize_whitespace => true })
      expect(same).to be true

      xmlObj1 = Nokogiri::XML(diff.subset_hash[:copydeleted].to_xml)
      xmlObj2 = Nokogiri::XML(<<-EOF
        <subset change="copydeleted" count="1">
          <file change="copydeleted" basisPath="Copy-removed" otherPath="">
            <fileSignature size="3182887" md5="ea6726038e370846910b4d103ffc1443" sha1="11b7a71251dbb57288782e0340685a1d5a12918d" sha256=""/>
          </file>
        </subset>
      EOF
      )
      same = EquivalentXml.equivalent?(xmlObj1, xmlObj2, opts = { :element_order => false, :normalize_whitespace => true })
      expect(same).to be true

      xmlObj1 = Nokogiri::XML(diff.subset_hash[:renamed].to_xml)
      xmlObj2 = Nokogiri::XML(<<-EOF
        <subset change="renamed" count="1">
          <file change="renamed" basisPath="Original-3" otherPath="File-renamed">
            <fileSignature size="3167" md5="c6450d9fdb391488b30effae25b53d55" sha1="ee49a23a4af9e7b7818a41742b2aade3abd068b7" sha256=""/>
          </file>
        </subset>
      EOF
      )
      same = EquivalentXml.equivalent?(xmlObj1, xmlObj2, opts = { :element_order => false, :normalize_whitespace => true })
      expect(same).to be true
    end

    # Unit test for method: {Moab::FileGroupDifference#compare_matching_signatures}
    # Which returns: [void] For signatures that are present in both groups, report which file instances are identical or renamed
    # For input parameters:
    # * basis_group [Moab::FileGroup] = The file group that is the basis of the comparison
    # * other_group [Moab::FileGroup] = The file group that is compared against the basis group
    specify 'Moab::FileGroupDifference#compare_matching_signatures' do
      basis_group = @v1_content
      other_group = @v3_content
      @diff.compare_matching_signatures(basis_group, other_group)
      expect(@diff.subsets.size).to eq(2)
      expect(@diff.subsets.collect {|s| s.change}).to eq(["identical", "renamed"])
      expect(@diff.subsets.collect {|s| s.files.size}).to eq([1, 2])
      expect(@diff.identical).to eq(1)
      expect(@diff.renamed).to eq(2)

      # def compare_matching_signatures(basis_group,other_group)
      #   matching_signatures = matching_keys(basis_group.signature_hash, other_group.signature_hash)
      #   tabulate_unchanged_files(matching_signatures, basis_group.signature_hash, other_group.signature_hash)
      #   tabulate_renamed_files(matching_signatures, basis_group.signature_hash, other_group.signature_hash)
      # end
    end

    # Unit test for method: {Moab::FileGroupDifference#compare_non_matching_signatures}
    # Which returns: [void] For signatures that are present in only one or the other group, report which file instances are modified, deleted, or added
    # For input parameters:
    # * basis_group [Moab::FileGroup] = The file group that is the basis of the comparison
    # * other_group [Moab::FileGroup] = The file group that is compared against the basis group
    specify 'Moab::FileGroupDifference#compare_non_matching_signatures' do
      basis_group = @v1_content
      other_group = @v3_content
      @diff.compare_non_matching_signatures(basis_group, other_group)
      expect(@diff.subsets.size).to eq(3)
      expect(@diff.subsets.collect {|s| s.change}).to eq(["modified", "added", "deleted"])
      expect(@diff.subsets.collect {|s| s.files.size}).to eq([1, 1, 2])
      expect(@diff.modified).to eq(1)
      expect(@diff.deleted).to eq(2)
      expect(@diff.added).to eq(1)

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
    # Which returns: [Moab::FileGroupDifferenceSubset] Container for reporting the set of file-level differences of type 'identical'
    # For input parameters:
    # * matching_signatures [Array<Moab::FileSignature>] = The file signature of the file manifestations being compared
    # * basis_signature_hash [Hash<Moab::FileSignature, Moab::FileManifestation>] = Moab::Signature to file path mapping from the file group that is the basis of the comparison
    # * other_signature_hash [Hash<Moab::FileSignature, Moab::FileManifestation>] = Moab::Signature to file path mapping from the file group that is the being compared to the basis group
    specify 'Moab::FileGroupDifference#tabulate_unchanged_files' do
      basis_group = @v1_content
      other_group = @v3_content
      signatures =  @diff.matching_keys(basis_group.signature_hash, other_group.signature_hash)
      expect(signatures.collect { |s| s.fixity}).to eq([
           {:size=>"39450", :md5=>"82fc107c88446a3119a51a8663d1e955", :sha1=>"d0857baa307a2e9efff42467b5abd4e1cf40fcd5", :sha256=>"235de16df4804858aefb7690baf593fb572d64bb6875ec522a4eea1f4189b5f0"},
           {:size=>"19125", :md5=>"a5099878de7e2e064432d6df44ca8827", :sha1=>"c0ccac433cf02a6cee89c14f9ba6072a184447a2", :sha256=>"7bd120459eff0ecd21df94271e5c14771bfca5137d1dd74117b6a37123dfe271"},
           {:size=>"40873", :md5=>"1a726cd7963bd6d3ceb10a8c353ec166", :sha1=>"583220e0572640abcd3ddd97393d224e8053a6ad", :sha256=>"8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5"}])

      @diff.tabulate_unchanged_files(signatures, basis_group.signature_hash, other_group.signature_hash)
      unchanged_subset = @diff.subset('identical')
      expect(unchanged_subset).to be_instance_of(Moab::FileGroupDifferenceSubset)
      expect(unchanged_subset.change).to eq('identical')
      expect(unchanged_subset.files.size).to eq(1)
      expect(@diff.identical).to eq(1)
      file0 = unchanged_subset.files[0]
      expect(file0.change).to eq('identical')
      expect(file0.basis_path).to eq('title.jpg')
      expect(file0.other_path).to eq('same')
      expected_sig_fixity = {
        :size=>"40873",
        :md5=> "1a726cd7963bd6d3ceb10a8c353ec166",
        :sha1=> "583220e0572640abcd3ddd97393d224e8053a6ad", :sha256=>"8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5"
      }
      expect(file0.signatures[0].fixity).to eq(expected_sig_fixity)

      # def tabulate_unchanged_files(signature, basis_paths, other_paths)
      #   unchanged_files = Array.new
      #   matching_signatures.each do |signature|
      #     basis_paths = basis_signature_hash[signature].paths
      #     other_paths = other_signature_hash[signature].paths
      #     matching_paths = basis_paths & other_paths
      #     matching_paths.each do |path|
      #       fid = Moab::FileInstanceDifference.new(:change => 'identical')
      #       fid.basis_path = path
      #       fid.other_path = "same"
      #       fid.signatures << signature
      #       unchanged_files << fid
      #     end
      #   end
      #   unchanged_subset = Moab::FileGroupDifferenceSubset.new(:change => 'identical')
      #   unchanged_subset.files = unchanged_files
      #   @subsets << unchanged_subset
      #   @identical = unchanged_subset.count
      #   unchanged_subset
      # end
    end

    # Unit test for method: {Moab::FileGroupDifference#tabulate_renamed_files}
    # Which returns: [Moab::FileGroupDifferenceSubset] Container for reporting the set of file-level differences of type 'renamed'
    # For input parameters:
    # * matching_signatures [Array<Moab::FileSignature>] = The file signature of the file manifestations being compared
    # * basis_signature_hash [Hash<Moab::FileSignature, Moab::FileManifestation>] = Moab::Signature to file path mapping from the file group that is the basis of the comparison
    # * other_signature_hash [Hash<Moab::FileSignature, Moab::FileManifestation>] = Moab::Signature to file path mapping from the file group that is the being compared to the basis group
    specify 'Moab::FileGroupDifference#tabulate_renamed_files' do
      basis_group = @v1_content
      other_group = @v3_content
      signatures =  @diff.matching_keys(basis_group.signature_hash, other_group.signature_hash)
      expect(signatures.collect { |s| s.fixity}).to eq([
          {:size=>"39450", :md5=>"82fc107c88446a3119a51a8663d1e955", :sha1=>"d0857baa307a2e9efff42467b5abd4e1cf40fcd5", :sha256=>"235de16df4804858aefb7690baf593fb572d64bb6875ec522a4eea1f4189b5f0"},
          {:size=>"19125", :md5=>"a5099878de7e2e064432d6df44ca8827", :sha1=>"c0ccac433cf02a6cee89c14f9ba6072a184447a2", :sha256=>"7bd120459eff0ecd21df94271e5c14771bfca5137d1dd74117b6a37123dfe271"},
          {:size=>"40873", :md5=>"1a726cd7963bd6d3ceb10a8c353ec166", :sha1=>"583220e0572640abcd3ddd97393d224e8053a6ad", :sha256=>"8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5"}])
      @diff.tabulate_renamed_files(signatures, basis_group.signature_hash, other_group.signature_hash)
      renamed_subset = @diff.subset('renamed')
      expect(renamed_subset).to be_instance_of(Moab::FileGroupDifferenceSubset)
      expect(renamed_subset.change).to eq('renamed')
      expect(renamed_subset.files.size).to eq(2)
      expect(@diff.renamed).to eq(2)
      file0 = renamed_subset.files[0]
      expect(file0.change).to eq('renamed')
      expect(file0.basis_path).to eq('page-2.jpg')
      expect(file0.other_path).to eq('page-3.jpg')
      expected_sig_fixity = {
        :size=>"39450",
        :md5=>"82fc107c88446a3119a51a8663d1e955",
        :sha1=>"d0857baa307a2e9efff42467b5abd4e1cf40fcd5", :sha256=>"235de16df4804858aefb7690baf593fb572d64bb6875ec522a4eea1f4189b5f0"
      }
      expect(file0.signatures[0].fixity).to eq(expected_sig_fixity)
      file1 = renamed_subset.files[1]
      expect(file1.change).to eq('renamed')
      expect(file1.basis_path).to eq('page-3.jpg')
      expect(file1.other_path).to eq('page-4.jpg')
      expected_sig_fixity = {
        :size=>"19125",
        :md5=>"a5099878de7e2e064432d6df44ca8827",
        :sha1=>"c0ccac433cf02a6cee89c14f9ba6072a184447a2", :sha256=>"7bd120459eff0ecd21df94271e5c14771bfca5137d1dd74117b6a37123dfe271"
      }
      expect(file1.signatures[0].fixity).to eq(expected_sig_fixity)

      # def tabulate_renamed_files(matching_signatures, basis_signature_hash, other_signature_hash)
      #   renamed_files = Array.new
      #   matching_signatures.each do |signature|
      #     basis_paths = basis_signature_hash[signature].paths
      #     other_paths = other_signature_hash[signature].paths
      #     basis_only_paths = basis_paths - other_paths
      #     other_only_paths = other_paths - basis_paths
      #     maxsize = [basis_only_paths.size,other_only_paths.size].max
      #     (0..maxsize-1).each do |n|
      #       fid = Moab::FileInstanceDifference.new(:change => 'renamed')
      #       fid.basis_path = basis_only_paths[n]
      #       fid.other_path = other_only_paths[n]
      #       fid.signatures << signature
      #       renamed_files << fid
      #     end
      #   end
      #   renamed_subset = Moab::FileGroupDifferenceSubset.new(:change => 'renamed')
      #   renamed_subset.files = renamed_files
      #   @subsets << renamed_subset
      #   @renamed = renamed_subset.count
      #   renamed_subset
      # end
    end

    # Unit test for method: {Moab::FileGroupDifference#tabulate_modified_files}
    # Which returns: [Moab::FileGroupDifferenceSubset] Container for reporting the set of file-level differences of type 'modified'
    # For input parameters:
    # * basis_path_hash [Hash<String,Moab::FileSignature>] = The file paths and associated signatures for manifestations appearing only in the basis group
    # * other_path_hash [Hash<String,Moab::FileSignature>] = The file paths and associated signatures for manifestations appearing only in the other group
    specify 'Moab::FileGroupDifference#tabulate_modified_files' do
      basis_group = @v1_content
      other_group = @v3_content
      expect((other_path_hash = other_group.path_hash).keys).to eq(
          ["page-1.jpg", "page-2.jpg", "page-3.jpg", "page-4.jpg", "title.jpg"]
      )
      signatures =  @diff.basis_only_keys(basis_group.signature_hash, other_group.signature_hash)
      expect(signatures.collect { |s| s.fixity}).to eq([
          {:size=>"41981", :md5=>"915c0305bf50c55143f1506295dc122c", :sha1=>"60448956fbe069979fce6a6e55dba4ce1f915178", :sha256=>"4943c6ffdea7e33b74fd7918de900de60e9073148302b0ad1bf5df0e6cec032a"},
          {:size=>"39850", :md5=>"77f1a4efdcea6a476505df9b9fba82a7", :sha1=>"a49ae3f3771d99ceea13ec825c9c2b73fc1a9915", :sha256=>"3a28718a8867e4329cd0363a84aee1c614d0f11229a82e87c6c5072a6e1b15e7"},
          {:size=>"25153", :md5=>"3dee12fb4f1c28351c7482b76ff76ae4", :sha1=>"906c1314f3ab344563acbbbe2c7930f08429e35b", :sha256=>"41aaf8598c9d8e3ee5d55efb9be11c542099d9f994b5935995d0abea231b8bad"}])
      basis_only_signatures = @diff.basis_only_keys(basis_group.signature_hash, other_group.signature_hash)
      other_only_signatures = @diff.other_only_keys(basis_group.signature_hash, other_group.signature_hash)
      basis_path_hash = basis_group.path_hash_subset(basis_only_signatures)
      other_path_hash = other_group.path_hash_subset(other_only_signatures)
      @diff.tabulate_modified_files(basis_path_hash, other_path_hash)
      modified_subset = @diff.subset('modified')
      expect(modified_subset).to be_instance_of(Moab::FileGroupDifferenceSubset)
      expect(modified_subset.change).to eq('modified')
      expect(modified_subset.files.size).to eq(1)
      expect(@diff.modified).to eq(1)
      file0 = modified_subset.files[0]
      expect(file0.change).to eq('modified')
      expect(file0.basis_path).to eq('page-1.jpg')
      expect(file0.other_path).to eq('same')
      expected_sig_fixity = {
        :size=>"25153",
        :md5=>"3dee12fb4f1c28351c7482b76ff76ae4",
        :sha1=>"906c1314f3ab344563acbbbe2c7930f08429e35b", :sha256=>"41aaf8598c9d8e3ee5d55efb9be11c542099d9f994b5935995d0abea231b8bad"
      }
      expect(file0.signatures[0].fixity).to eq(expected_sig_fixity)

      # def tabulate_modified_files(basis_path_hash, other_path_hash)
      #   modified_files = Array.new
      #   matching_keys(basis_path_hash, other_path_hash).each do |path|
      #     fid = Moab::FileInstanceDifference.new(:change => 'modified')
      #     fid.basis_path = path
      #     fid.other_path = "same"
      #     fid.signatures << basis_path_hash[path]
      #     fid.signatures << other_path_hash[path]
      #     modified_files << fid
      #   end
      #   modified_subset = Moab::FileGroupDifferenceSubset.new(:change => 'modified')
      #   modified_subset.files = modified_files
      #   @subsets << modified_subset
      #   @modified = modified_subset.count
      #   modified_subset
      # end
    end

    # Unit test for method: {Moab::FileGroupDifference#tabulate_deleted_files}
    # Which returns: [Moab::FileGroupDifferenceSubset] Container for reporting the set of file-level differences of type 'deleted'
    # For input parameters:
    # * basis_path_hash [Hash<String,Moab::FileSignature>] = The file paths and associated signatures for manifestations appearing only in the basis group
    # * other_path_hash [Hash<String,Moab::FileSignature>] = The file paths and associated signatures for manifestations appearing only in the other group
    specify 'Moab::FileGroupDifference#tabulate_deleted_files' do
      basis_group = @v1_content
      other_group = @v3_content
      expect((other_path_hash = other_group.path_hash).keys).to eq(
          ["page-1.jpg", "page-2.jpg", "page-3.jpg", "page-4.jpg", "title.jpg"]
      )
      signatures =  @diff.basis_only_keys(basis_group.signature_hash, other_group.signature_hash)
      expect(signatures.collect { |s| s.fixity}).to eq([
          {:size=>"41981", :md5=>"915c0305bf50c55143f1506295dc122c", :sha1=>"60448956fbe069979fce6a6e55dba4ce1f915178", :sha256=>"4943c6ffdea7e33b74fd7918de900de60e9073148302b0ad1bf5df0e6cec032a"},
          {:size=>"39850", :md5=>"77f1a4efdcea6a476505df9b9fba82a7", :sha1=>"a49ae3f3771d99ceea13ec825c9c2b73fc1a9915", :sha256=>"3a28718a8867e4329cd0363a84aee1c614d0f11229a82e87c6c5072a6e1b15e7"},
          {:size=>"25153", :md5=>"3dee12fb4f1c28351c7482b76ff76ae4", :sha1=>"906c1314f3ab344563acbbbe2c7930f08429e35b", :sha256=>"41aaf8598c9d8e3ee5d55efb9be11c542099d9f994b5935995d0abea231b8bad"}])
      basis_only_signatures = @diff.basis_only_keys(basis_group.signature_hash, other_group.signature_hash)
      other_only_signatures = @diff.other_only_keys(basis_group.signature_hash, other_group.signature_hash)
      basis_path_hash = basis_group.path_hash_subset(basis_only_signatures)
      other_path_hash = other_group.path_hash_subset(other_only_signatures)
      @diff.tabulate_deleted_files(basis_path_hash, other_path_hash)
      deleted_subset = @diff.subset('deleted')
      expect(deleted_subset).to be_instance_of(Moab::FileGroupDifferenceSubset)
      expect(deleted_subset.change).to eq('deleted')
      expect(deleted_subset.files.size).to eq(2)
      expect(@diff.deleted).to eq(2)
      file0 = deleted_subset.files[0]
      expect(file0.change).to eq('deleted')
      expect(file0.basis_path).to eq('intro-1.jpg')
      expect(file0.other_path).to eq('')
      expected_sig_fixity = {
        :size=>"41981",
        :md5=>"915c0305bf50c55143f1506295dc122c",
        :sha1=>"60448956fbe069979fce6a6e55dba4ce1f915178", :sha256=>"4943c6ffdea7e33b74fd7918de900de60e9073148302b0ad1bf5df0e6cec032a"
      }
      expect(file0.signatures[0].fixity).to eq(expected_sig_fixity)
      file1 = deleted_subset.files[1]
      expect(file1.change).to eq('deleted')
      expect(file1.basis_path).to eq('intro-2.jpg')
      expect(file1.other_path).to eq('')
      expected_sig_fixity = {
        :size=>"39850",
        :md5=>"77f1a4efdcea6a476505df9b9fba82a7",
        :sha1=>"a49ae3f3771d99ceea13ec825c9c2b73fc1a9915", :sha256=>"3a28718a8867e4329cd0363a84aee1c614d0f11229a82e87c6c5072a6e1b15e7"
      }
      expect(file1.signatures[0].fixity).to eq(expected_sig_fixity)

      # def tabulate_deleted_files(basis_path_hash, other_path_hash)
      #   deleted_files = Array.new
      #   basis_only_keys(basis_path_hash, other_path_hash).each do |path|
      #     fid = Moab::FileInstanceDifference.new(:change => 'deleted')
      #     fid.basis_path = path
      #     fid.other_path = ""
      #     fid.signatures << basis_path_hash[path]
      #     deleted_files << fid
      #   end
      #   deleted_subset = Moab::FileGroupDifferenceSubset.new(:change => 'deleted')
      #   deleted_subset.files = deleted_files
      #   @subsets << deleted_subset
      #   @deleted = deleted_subset.count
      #   deleted_subset
      # end
    end

    # Unit test for method: {Moab::FileGroupDifference#tabulate_added_files}
    # Which returns: [Moab::FileGroupDifferenceSubset] Container for reporting the set of file-level differences of type 'added'
    # For input parameters:
    # * basis_path_hash [Hash<String,Moab::FileSignature>] = The file paths and associated signatures for manifestations appearing only in the basis group
    # * other_path_hash [Hash<String,Moab::FileSignature>] = The file paths and associated signatures for manifestations appearing only in the other group
    specify 'Moab::FileGroupDifference#tabulate_added_files' do
      basis_group = @v1_content
      other_group = @v3_content
      signatures =  @diff.other_only_keys(basis_group.signature_hash, other_group.signature_hash)
      expect(signatures.collect { |s| s.fixity}).to eq([
          {:size=>"32915", :md5=>"c1c34634e2f18a354cd3e3e1574c3194", :sha1=>"0616a0bd7927328c364b2ea0b4a79c507ce915ed", :sha256=>"b78cc53b7b8d9ed86d5e3bab3b699c7ed0db958d4a111e56b6936c8397137de0"},
          {:size=>"39539", :md5=>"fe6e3ffa1b02ced189db640f68da0cc2", :sha1=>"43ced73681687bc8e6f483618f0dcff7665e0ba7", :sha256=>"42c0cd1fe06615d8fdb8c2e3400d6fe38461310b4ecc252e1774e0c9e3981afa"}])
      basis_only_signatures = @diff.basis_only_keys(basis_group.signature_hash, other_group.signature_hash)
      other_only_signatures = @diff.other_only_keys(basis_group.signature_hash, other_group.signature_hash)
      basis_path_hash = basis_group.path_hash_subset(basis_only_signatures)
      other_path_hash = other_group.path_hash_subset(other_only_signatures)
      @diff.tabulate_added_files(basis_path_hash, other_path_hash)
      added_subset = @diff.subset('added')
      expect(added_subset).to be_instance_of(Moab::FileGroupDifferenceSubset)
      expect(added_subset.change).to eq('added')
      expect(added_subset.files.size).to eq(1)
      expect(@diff.added).to eq(1)
      file0 = added_subset.files[0]
      expect(file0.change).to eq('added')
      expect(file0.basis_path).to eq('')
      expect(file0.other_path).to eq('page-2.jpg')
      expected_sig_fixity = {
        :size=>"39539", :md5=>"fe6e3ffa1b02ced189db640f68da0cc2",
        :sha1=>"43ced73681687bc8e6f483618f0dcff7665e0ba7", :sha256=>"42c0cd1fe06615d8fdb8c2e3400d6fe38461310b4ecc252e1774e0c9e3981afa"
      }
      expect(file0.signatures[0].fixity).to eq(expected_sig_fixity)

      # def tabulate_added_files(basis_path_hash, other_path_hash)
      #   added_files = Array.new
      #   other_only_keys(basis_path_hash, other_path_hash).each do |path|
      #     fid = Moab::FileInstanceDifference.new(:change => 'added')
      #     fid.basis_path = ""
      #     fid.other_path = path
      #     fid.signatures << other_path_hash[path]
      #     added_files << fid
      #   end
      #   added_subset = Moab::FileGroupDifferenceSubset.new(:change => 'added')
      #   added_subset.files = added_files
      #   @subsets << added_subset
      #   @added = added_subset.count
      #   added_subset
      # end
    end

    specify 'Moab::FileGroupDifference  parse xml' do
      fixture = @ingests.join('jq937jp0017','v0003','manifests','fileInventoryDifference.xml')
      fid = Moab::FileInventoryDifference.parse(IO.read(fixture))
      fgd = fid.group_difference('content')
      expect(fgd.subsets.count).to be >= 5
      expect(fgd.subset('identical').files.count).to eq(2)
      expect(fgd.subset('renamed').files.count).to eq(2)
      expect(fgd.subset('renamed').files[0].basis_path).to eq("page-2.jpg")
      expect(fgd.subset('renamed').files[0].other_path).to eq("page-3.jpg")
      expect(fgd.subset('modified').files.count).to eq(0)
      expect(fgd.subset('deleted').files.count).to eq(0)
      expect(fgd.subset('added').files.count).to eq(1)
      expect(fgd.subset('added').files[0].other_path).to eq("page-2.jpg")
    end

    specify 'Moab::FileGroupDifference#file_deltas' do
      deltas = @diff.file_deltas
      expect(deltas).to eq(
        {
            :identical => [],
             :modified => [],
              :deleted => [],
          :copydeleted => [],
            :copyadded => [],
              :renamed => [],
                :added => []
        }
      )
      basis_group = @v1_content
      other_group = @v3_content
      @diff.compare_file_groups(basis_group, other_group)
      deltas = @diff.file_deltas
      #ap deltas, {:index=>false, :multiline=>false}
      expect(deltas).to eq(
        {
              :identical => [ "title.jpg" ],
               :modified => [ "page-1.jpg" ],
                :deleted => [ "intro-1.jpg", "intro-2.jpg" ],
            :copydeleted => [],
              :copyadded => [],
                :renamed => [ [ "page-2.jpg", "page-3.jpg" ], [ "page-3.jpg", "page-4.jpg" ] ],
                  :added => [ "page-2.jpg" ]
        }
      )
    end

    specify 'Moab::FileGroupDifference#renames_require_temp_files' do
      renamed = [ [ "page-2.jpg", "page-3.jpg" ], [ "page-3.jpg", "page-4.jpg" ] ]
      expect(@diff.rename_require_temp_files(renamed)).to eq(true)
      renamed = [ [ "page-1.jpg", "page-1b.jpg" ], [ "page-2.jpg", "page-2b.jpg" ] ]
      expect(@diff.rename_require_temp_files(renamed)).to eq(false)
    end

    specify 'Moab::FileGroupDifference#renames_require_temp_files' do
      renamed = [ [ "page-2.jpg", "page-3.jpg" ], [ "page-3.jpg", "page-4.jpg" ] ]
      triplets = @diff.rename_tempfile_triplets(renamed)
      #ap result, {:index=>false, :multiline=>false}
      expect(triplets[0][0]).to eq("page-2.jpg")
      expect(triplets[0][1]).to eq("page-3.jpg")
      expect(triplets[0][2]).to match /^page-3.jpg.*-tmp$/
      expect(triplets[1][0]).to eq("page-3.jpg")
      expect(triplets[1][1]).to eq("page-4.jpg")
      expect(triplets[1][2]).to match /^page-4.jpg.*-tmp$/
    end

  end

end
