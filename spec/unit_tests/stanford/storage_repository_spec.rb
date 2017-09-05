require 'spec_helper'

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
      expect{storage_repository.druid_tree('123cd456nm')}.to raise_exception /Identifier has invalid suri syntax/
    end
  end
end
