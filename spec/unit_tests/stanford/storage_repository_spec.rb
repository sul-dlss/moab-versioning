# frozen_string_literal: true

describe Stanford::StorageRepository do
  let(:storage_repository) { described_class.new }

  describe '#storage_branch' do
    it 'Moab::Config.path_method :druid_tree' do
      Moab::Config.configure do
        path_method :druid_tree
      end
      expect(storage_repository.storage_branch(FULL_TEST_DRUID).to_s).to eq('jq/937/jp/0017/jq937jp0017')
    end

    it 'Moab::Config.path_method :druid' do
      Moab::Config.configure do
        path_method :druid
      end
      expect(storage_repository.storage_branch(FULL_TEST_DRUID).to_s).to eq(BARE_TEST_DRUID)
    end
  end

  describe '#druid_tree' do
    it 'has expected value for valid druid' do
      expect(storage_repository.druid_tree(FULL_TEST_DRUID)).to eq('jq/937/jp/0017/jq937jp0017')
    end

    it 'raises InvalidSuriSyntaxError for invalid druid' do
      exp_msg_regex = /Identifier has invalid suri syntax: 123cd456nm/
      expect { storage_repository.druid_tree('123cd456nm') }.to raise_exception(Moab::InvalidSuriSyntaxError, exp_msg_regex)
    end

    it 'raises InvalidSuriSyntaxError for druid that uses forbidden chars (not strictly valid)' do
      exp_regex = /^Identifier has invalid suri syntax: druid:aa111bb2222$/
      expect { storage_repository.druid_tree('druid:aa111bb2222') }.to raise_exception(Moab::InvalidSuriSyntaxError, exp_regex)
    end
  end
end
