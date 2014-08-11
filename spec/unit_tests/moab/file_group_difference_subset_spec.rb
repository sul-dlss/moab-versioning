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
      expect(file_group_difference_subset).to be_instance_of(FileGroupDifferenceSubset)
       
      # test initialization of arrays and hashes
      expect(file_group_difference_subset.files).to be_kind_of(Array)
      expect(file_group_difference_subset.files.size).to eq(0)

      # test initialization with options hash
      opts = Hash.new
      opts[:change] = 'Test change'
      file_group_difference_subset = FileGroupDifferenceSubset.new(opts)
      expect(file_group_difference_subset.change).to eq(opts[:change])
      expect(file_group_difference_subset.count).to eq(0)

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
    # Which stores: [String] The type of change (identical|renamed|modified|deleted|added)
    specify 'Moab::FileGroupDifferenceSubset#change' do
      value = 'Test change'
      @file_group_difference_subset.change= value
      expect(@file_group_difference_subset.change).to eq(value)
       
      # attribute :change, String, :key => true
    end
    
    # Unit test for attribute: {Moab::FileGroupDifferenceSubset#count}
    # Which stores: [Integer] How many files were changed
    specify 'Moab::FileGroupDifferenceSubset#count' do
      value = 52
      @file_group_difference_subset.count= value
      expect(@file_group_difference_subset.count).to eq(0)
       
      # attribute :count, Integer, :on_save => Proc.new { |n| n.to_s }
    end
    
    # Unit test for attribute: {Moab::FileGroupDifferenceSubset#files}
    # Which stores: [Array<FileInstanceDifference>] The set of file instances having this type of change
    specify 'Moab::FileGroupDifferenceSubset#files' do
      expect(@file_group_difference_subset.files.size).to eq(0)
       
      # has_many :files, FileInstanceDifference
    end
  
  end

end
