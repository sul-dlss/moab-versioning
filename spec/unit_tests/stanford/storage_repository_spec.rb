require 'spec_helper'

# Unit tests for class {Stanford::StorageRepository}
describe 'Stanford::StorageRepository' do
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
     specify 'Stanford::StorageRepository#initialize' do
       
      storage_repository = StorageRepository.new()
      storage_repository.should be_instance_of(Stanford::StorageRepository)

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
      @storage_repository.storage_branch(@object_id).to_s.should == 'jq/937/jp/0017/jq937jp0017'

      Moab::Config.configure do
        path_method :druid
      end
      @storage_repository.storage_branch(@object_id).to_s.should == 'jq937jp0017'

    end
    
    specify 'Stanford::StorageRepository#druid_tree' do
      @storage_repository.druid_tree(@object_id).should == "jq/937/jp/0017/jq937jp0017"
      lambda{@storage_repository.druid_tree('123cd456nm')}.should raise_exception
    end
  
  end

end
