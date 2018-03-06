describe 'Moab::FileInstanceDifference' do

  describe '#initialize' do
    specify 'empty options hash' do
      diff = Moab::FileInstanceDifference.new({})
      expect(diff.signatures).to be_kind_of Array
      expect(diff.signatures.size).to eq 0
    end
    specify 'options passed in' do
      opts = {
        change: 'Test change',
        basis_path: 'Test basis_path',
        other_path: 'Test other_path'
      }
      diff = Moab::FileInstanceDifference.new(opts)
      expect(diff.change).to eq opts[:change]
      expect(diff.basis_path).to eq opts[:basis_path]
      expect(diff.other_path).to eq opts[:other_path]
    end
  end
end
