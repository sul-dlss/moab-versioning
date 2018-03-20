describe 'Stanford::StorageRepository' do

  let(:storage_repository) { Stanford::StorageRepository.new() }

  context '#storage_branch' do
    it 'Moab::Config.path_method :druid_tree' do
      Moab::Config.configure do
        path_method :druid_tree
      end
      expect(storage_repository.storage_branch(@druid).to_s).to eq('jq/937/jp/0017/jq937jp0017')
    end
    it 'Moab::Config.path_method :druid' do
      Moab::Config.configure do
        path_method :druid
      end
      expect(storage_repository.storage_branch(@druid).to_s).to eq('jq937jp0017')
    end
  end

  context '#druid_tree' do
    it 'has expected value for valid druid' do
      expect(storage_repository.druid_tree(@druid)).to eq("jq/937/jp/0017/jq937jp0017")
    end
    it 'raises exception for invalid druid' do
      exp_msg_regex = /Identifier has invalid suri syntax/
      expect{storage_repository.druid_tree('123cd456nm')}.to raise_exception(RuntimeError, exp_msg_regex)
    end
    it 'has expected value for valid druid that uses forbidden chars (not strictly valid)' do
      exp_msg_regex = /^Identifier has invalid suri syntax: druid:aa111bb2222$/
      expect{storage_repository.druid_tree('druid:aa111bb2222')}.to raise_exception(RuntimeError, exp_msg_regex)
    end
  end
end
