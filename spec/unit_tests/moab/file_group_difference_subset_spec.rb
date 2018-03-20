describe 'Moab::FileGroupDifferenceSubset' do
  let(:diff_subset) { Moab::FileGroupDifferenceSubset.new }

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

  specify '#count is computed, not set' do
    value = 52
    diff_subset.count = value
    expect(diff_subset.count).to eq 0
  end

  specify '#files is computed, not set' do
    expect(diff_subset.files.size).to eq 0
  end
end
