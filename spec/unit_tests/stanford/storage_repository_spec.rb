require 'spec_helper'

# Unit tests for class {Stanford::StorageRepository}
describe 'Stanford::StorageRepository' do
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
     specify 'Stanford::StorageRepository#initialize' do
       
      storage_repository = StorageRepository.new()
      expect(storage_repository).to be_instance_of(Stanford::StorageRepository)

    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do
    
    before(:each) do
      @storage_repository = StorageRepository.new()
      @object_id = @druid

    end

    
    specify 'Stanford::StorageRepository#storage_branch' do
      Moab::Config.configure do
        path_method :druid_tree
      end
      expect(@storage_repository.storage_branch(@object_id).to_s).to eq('jq/937/jp/0017/jq937jp0017')

      Moab::Config.configure do
        path_method :druid
      end
      expect(@storage_repository.storage_branch(@object_id).to_s).to eq('jq937jp0017')

    end
    
    specify 'Stanford::StorageRepository#druid_tree' do
      expect(@storage_repository.druid_tree(@object_id)).to eq("jq/937/jp/0017/jq937jp0017")
      expect{@storage_repository.druid_tree('123cd456nm')}.to raise_exception
    end
  
  end

end
