require 'spec_helper'

# Unit tests for class {Moab::FileGroupDifferenceSubset}
describe 'Moab::FileGroupDifferenceSubset' do
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Moab::FileGroupDifferenceSubset#initialize}
    # Which returns an instance of: [Moab::FileGroupDifferenceSubset]
    # For input parameters:
    # * opts [Hash<Symbol,Object>] = a hash containing any number of symbol => value pairs. The symbols should correspond to attributes declared using HappyMapper syntax 
    specify 'Moab::FileGroupDifferenceSubset#initialize' do
       
      # test initialization with required parameters (if any)
      opts = {}
      file_group_difference_subset = FileGroupDifferenceSubset.new(opts)
      file_group_difference_subset.should be_instance_of(FileGroupDifferenceSubset)
       
      # test initialization of arrays and hashes
      file_group_difference_subset.files.should be_kind_of(Array)
      file_group_difference_subset.files.size.should == 0

      # test initialization with options hash
      opts = OrderedHash.new
      opts[:change] = 'Test change'
      opts[:count] = 42
      file_group_difference_subset = FileGroupDifferenceSubset.new(opts)
      file_group_difference_subset.change.should == opts[:change]
      file_group_difference_subset.count.should == opts[:count]

      # def initialize(opts={})
      #   @files = Array.new
      #   super(opts)
      # end
    end
  
  end
  
  describe '=========================== INSTANCE ATTRIBUTES ===========================' do
    
    before(:all) do
      opts = {}
      @file_group_difference_subset = FileGroupDifferenceSubset.new(opts)
    end
    
    # Unit test for attribute: {Moab::FileGroupDifferenceSubset#change}
    # Which stores: [String] \@change = The type of change (identical|renamed|modified|deleted|added)
    specify 'Moab::FileGroupDifferenceSubset#change' do
      value = 'Test change'
      @file_group_difference_subset.change= value
      @file_group_difference_subset.change.should == value
       
      # attribute :change, String, :key => true
    end
    
    # Unit test for attribute: {Moab::FileGroupDifferenceSubset#count}
    # Which stores: [Integer] \@count = How many files were changed
    specify 'Moab::FileGroupDifferenceSubset#count' do
      value = 52
      @file_group_difference_subset.count= value
      @file_group_difference_subset.count.should == value
       
      # attribute :count, Integer, :on_save => Proc.new { |n| n.to_s }
    end
    
    # Unit test for attribute: {Moab::FileGroupDifferenceSubset#files}
    # Which stores: [Array<FileInstanceDifference>] \[<file>] = The set of file instances having this type of change
    specify 'Moab::FileGroupDifferenceSubset#files' do
      @file_group_difference_subset.files.size.should == 0
       
      # has_many :files, FileInstanceDifference
    end
  
  end

end
