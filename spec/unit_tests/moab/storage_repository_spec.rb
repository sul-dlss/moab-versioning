require 'spec_helper'

# Unit tests for class {Moab::StorageRepository}
describe 'Moab::StorageRepository' do
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
    specify 'Moab::StorageRepository#initialize' do
       
      storage_repository = Moab::StorageRepository.new()
      storage_repository.should be_instance_of(Moab::StorageRepository)
    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do

    before(:each) do
      @storage_repository = Moab::StorageRepository.new()
      @object_id = @druid

    end
    
    specify 'Moab::StorageRepository#storage_roots' do
      @storage_repository.storage_roots[0].should == @fixtures.join('derivatives')
      @storage_repository.storage_roots[1].should == @fixtures.join('newnode')
    end

    specify 'Moab::StorageRepository#storage_trunk' do
      @storage_repository.storage_trunk.should == 'ingests'
    end

    specify 'Moab::StorageRepository#deposit_trunk' do
      @storage_repository.deposit_trunk.should == 'packages'
    end

    specify 'Moab::StorageRepository#storage_branch' do
      @storage_repository.storage_branch('abcdef').should == 'ab/cd/ef/abcdef'
    end

    specify 'Moab::StorageRepository#deposit_branch' do
      @storage_repository.deposit_branch('abcdef').should == 'abcdef'
    end

    specify 'Moab::StorageRepository#find_storage_root' do
      @storage_repository.find_storage_root('abcdef').should  == @fixtures.join('newnode')
      @storage_repository.stub(:storage_branch).and_return('jq937jp0017')
      @storage_repository.find_storage_root('jq937jp0017').should == @derivatives
      @storage_repository.stub(:storage_trunk).and_return('junk')
      lambda{@storage_repository.find_storage_root('abcdef')}.should raise_exception(/Storage area not found/)
    end

    specify 'Moab::StorageRepository#find_storage_object' do
      @storage_repository.stub(:storage_branch).and_return('jq937jp0017')
      so = @storage_repository.find_storage_object('jq937jp0017')
      so.object_pathname.should == @derivatives.join('ingests/jq937jp0017')
      so.deposit_bag_pathname.should == @derivatives.join('packages/jq937jp0017')

    end

    specify 'Moab::StorageRepository#storage_object' do

      mock_so = mock(StorageObject)
      @storage_repository.should_receive(:find_storage_object).twice.and_return(mock_so)
      mock_path = mock(Pathname)
      mock_so.stub(:object_pathname).and_return(mock_path)
      mock_path.stub(:exist?).and_return(false)
      lambda{@storage_repository.storage_object('jq937jp0017')}.should raise_exception(Moab::ObjectNotFoundException)

      mock_path.should_receive(:mkpath)
      @storage_repository.storage_object('jq937jp0017',create=true)

    end
    
    specify "Moab::StorageRepository#store_new_version" do
      bag_pathname = mock("bag_pathname")
      object_pathname = mock("object_pathname")
      storage_object = mock(StorageObject)
      @storage_repository.should_receive(:storage_object).with(@druid,true).and_return(storage_object)
      storage_object.stub(:object_pathname).and_return(object_pathname)
      storage_object.should_receive(:ingest_bag).with(bag_pathname)
      @storage_repository.store_new_object_version(@druid,bag_pathname)
    end

  end

end
