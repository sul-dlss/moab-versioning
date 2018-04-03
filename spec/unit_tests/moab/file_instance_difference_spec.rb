describe Moab::FileInstanceDifference do
  describe '#initialize' do
    specify 'empty options hash' do
      diff = described_class.new({})
      expect(diff.signatures).to eq []
    end
    specify 'options passed in' do
      opts = {
        change: 'Test change',
        basis_path: 'Test basis_path',
        other_path: 'Test other_path'
      }
      diff = described_class.new(opts)
      expect(diff.change).to eq opts[:change]
      expect(diff.basis_path).to eq opts[:basis_path]
      expect(diff.other_path).to eq opts[:other_path]
    end
  end
end
