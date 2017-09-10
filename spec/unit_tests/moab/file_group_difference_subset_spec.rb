require 'spec_helper'

describe 'Moab::FileGroupDifferenceSubset' do

  describe '#initialize' do
    specify 'empty options hash' do
      diff_subset = Moab::FileGroupDifferenceSubset.new({})
      expect(diff_subset.files).to be_kind_of Array
      expect(diff_subset.files.size).to eq 0
    end
    specify 'options passed in' do
      opts = { change: 'Test change' }
      diff_subset = Moab::FileGroupDifferenceSubset.new(opts)
      expect(diff_subset.change).to eq opts[:change]
      expect(diff_subset.count).to eq 0
    end
  end

  describe '=========================== INSTANCE ATTRIBUTES ===========================' do

    before(:all) do
      opts = {}
      @file_group_difference_subset = Moab::FileGroupDifferenceSubset.new(opts)
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
    # Which stores: [Array<Moab::FileInstanceDifference>] The set of file instances having this type of change
    specify 'Moab::FileGroupDifferenceSubset#files' do
      expect(@file_group_difference_subset.files.size).to eq(0)

      # has_many :files, Moab::FileInstanceDifference
    end

  end

end
