require 'spec_helper'

# Unit tests for class {Moab::StorageRepository}
describe 'Moab::StorageRepository' do
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
    specify 'Moab::StorageRepository#initialize' do
       
      storage_repository = Moab::StorageRepository.new()
      expect(storage_repository).to be_instance_of(Moab::StorageRepository)
    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do

    before(:each) do
      @storage_repository = Moab::StorageRepository.new()
      @object_id = @druid

    end
    
    specify 'Moab::StorageRepository#storage_roots' do
      expect(@storage_repository.storage_roots[0]).to eq(@fixtures.join('derivatives'))
      expect(@storage_repository.storage_roots[1]).to eq(@fixtures.join('newnode'))
    end

    specify 'Moab::StorageRepository#storage_trunk' do
      expect(@storage_repository.storage_trunk).to eq('ingests')
    end

    specify 'Moab::StorageRepository#deposit_trunk' do
      expect(@storage_repository.deposit_trunk).to eq('packages')
    end

    specify 'Moab::StorageRepository#storage_branch' do
      expect(@storage_repository.storage_branch('abcdef')).to eq('ab/cd/ef/abcdef')
    end

    specify 'Moab::StorageRepository#deposit_branch' do
      expect(@storage_repository.deposit_branch('abcdef')).to eq('abcdef')
    end

    specify 'Moab::StorageRepository#find_storage_root' do
      expect(@storage_repository.find_storage_root('abcdef')).to  eq(@fixtures.join('newnode'))
      allow(@storage_repository).to receive(:storage_branch).and_return('jq937jp0017')
      expect(@storage_repository.find_storage_root('jq937jp0017')).to eq(@derivatives)
      allow(@storage_repository).to receive(:storage_trunk).and_return('junk')
      expect{@storage_repository.find_storage_root('abcdef')}.to raise_exception(/Storage area not found/)
    end

    specify 'Moab::StorageRepository#find_storage_object' do
      allow(@storage_repository).to receive(:storage_branch).and_return('jq937jp0017')
      so = @storage_repository.find_storage_object('jq937jp0017')
      expect(so.object_pathname).to eq(@derivatives.join('ingests/jq937jp0017'))
      expect(so.deposit_bag_pathname).to eq(@derivatives.join('packages/jq937jp0017'))

    end

    it 'Moab::StorageRepository#object_size returns the size of a moab object' do
      allow(@storage_repository).to receive(:storage_branch).and_return('jq937jp0017')
      expect(@storage_repository.object_size('jq937jp0017')).to eq(388471)
    end


    specify 'Moab::StorageRepository#storage_object' do
      mock_so = double(Moab::StorageObject)
      expect(@storage_repository).to receive(:find_storage_object).twice.and_return(mock_so)
      mock_path = double(Pathname)
      allow(mock_so).to receive(:object_pathname).and_return(mock_path)
      allow(mock_path).to receive(:exist?).and_return(false)
      expect{@storage_repository.storage_object('jq937jp0017')}.to raise_exception(Moab::ObjectNotFoundException)

      expect(mock_path).to receive(:mkpath)
      @storage_repository.storage_object('jq937jp0017',create=true)
    end
    
    specify "Moab::StorageRepository#store_new_version" do
      bag_pathname = double("bag_pathname")
      object_pathname = double("object_pathname")
      storage_object = double(Moab::StorageObject)
      expect(@storage_repository).to receive(:storage_object).with(@druid,true).and_return(storage_object)
      allow(storage_object).to receive(:object_pathname).and_return(object_pathname)
      expect(storage_object).to receive(:ingest_bag).with(bag_pathname)
      @storage_repository.store_new_object_version(@druid,bag_pathname)
    end

  end

end
