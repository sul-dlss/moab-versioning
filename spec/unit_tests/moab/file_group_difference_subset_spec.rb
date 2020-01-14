# frozen_string_literal: true

describe Moab::FileGroupDifferenceSubset do
  let(:diff_subset) { described_class.new }

  describe '#initialize' do
    specify 'empty options hash' do
      diff_subset = described_class.new({})
      expect(diff_subset.files).to eq []
    end

    specify 'options passed in' do
      opts = { change: 'Test change' }
      diff_subset = described_class.new(opts)
      expect(diff_subset.change).to eq opts[:change]
      expect(diff_subset.count).to eq 0
    end
  end

  specify '#count is computed, not set' do
    diff_subset.count = 52
    expect(diff_subset.count).to eq 0
  end

  specify '#files is computed, not set' do
    expect(diff_subset.files.size).to eq 0
  end
end
