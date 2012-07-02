require 'spec_helper'

# Unit tests for class {Moab::StorageRepository}
describe 'Moab::StorageRepository' do
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Moab::StorageRepository#initialize}
    # Which returns an instance of: [Moab::StorageRepository]
    # For input parameters:
    # * repository_home [Pathname, String] = The location of the root directory of the repository storage node 
    specify 'Moab::StorageRepository#initialize' do
       
      storage_repository_default = Moab::StorageRepository.new()
      storage_repository_default.should be_instance_of(Moab::StorageRepository)
      storage_repository_default.repository_home.to_s.should =~ /fixtures\/derivatives\/ingest/

    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do
    
    before(:each) do
      @storage_repository = Moab::StorageRepository.new()
      @object_id = @druid

    end
    
    # Unit test for method: {Moab::StorageRepository#repository_home}
    # Which returns: [Pathname] The location of the root directory of the repository storage node
    # For input parameters: (None)
    specify 'Moab::StorageRepository#repository_home' do
      @storage_repository.repository_home.to_s.should =~ /fixtures\/derivatives\/ingest/

      # def repository_home
      #   Pathname.new(Moab::Config.repository_home)
      # end
    end

    # Unit test for method: {Moab::StorageRepository#storage_object}
    # Which returns: [StorageObject] The representation of the desired object storage directory
    # For input parameters:
    # * object_id [String] = The identifier of the digital object whose version is desired 
    specify 'Moab::StorageRepository#storage_object' do
      object_pathname = mock(Pathname)
      @storage_repository.stub(:storage_object_pathname).and_return(object_pathname)
      object_pathname.stub(:exist?).and_return(true)
      StorageObject.should_receive(:new).with(@obj, object_pathname)
      @storage_repository.storage_object(@obj)
      object_pathname.stub(:exist?).and_return(false)
      lambda{@storage_repository.storage_object(@obj)}.should raise_exception(Moab::ObjectNotFoundException)
    end
    
    # Unit test for method: {Moab::StorageRepository#storage_object_pathname}
    # Which returns: [Pathname] The location of the desired object's home directory (default=pairtree)
    # For input parameters:
    # * object_id [String] = The identifier of the digital object whose version is desired 
    specify 'Moab::StorageRepository#storage_object_pathname' do
      pathname = @storage_repository.storage_object_pathname(@obj)
      pathname.to_s.include?('ingests/jq/93/7j/p0/01/7/jq937jp0017').should == true

      # def storage_object_pathname(object_id)
      #   #todo This method should be customized, or overridden in a subclass
      #   # for a more sophisticated pairtree implementation see https://github.com/microservices/pairtree
      #   path_segments = object_id.scan(/..?/) << object_id
      #   object_path = path_segments.join(File::SEPARATOR).gsub(/:/,'_')
      #   repository_home.join(object_path)
      # end
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

    specify "Moab::StorageRepository#verify_version_storage" do
      storage_object = mock(StorageObject)
      storage_object.stub(:current_version_id).and_return(3)
      @storage_repository.should_receive(:storage_object).with(@druid).and_return(storage_object)
      version = mock(StorageObjectVersion)
      StorageObjectVersion.stub(:new).with(storage_object, 3 ).and_return(version)
      version.should_receive(:verify_version_additions).and_return(true)
      version.should_receive(:verify_version_inventory)
      @storage_repository.verify_version_storage(@druid)
    end

  end

end
