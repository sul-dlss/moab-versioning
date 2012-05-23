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

    # Unit test for method: {Moab::StorageRepository#storage_object_version}
    # Which returns: [StorageObjectVersion] The representation of the desired object version's storage directory
    # For input parameters:
    # * object_id [String] = The identifier of the digital object whose version is desired 
    # * version_id [Integer] = The desired version 
    specify 'Moab::StorageRepository#storage_object_version' do
      version_id = 2
      version = @storage_repository.storage_object_version(@obj, version_id)
      version.should be_instance_of(StorageObjectVersion)
      version.version_id.should == version_id
      version.version_pathname.to_s.include?('ingests/jq/93/7j/p0/01/7/jq937jp0017/v0002').should == true

      # def storage_object_version(object_id, version_id=nil)
      #   storage_object(object_id).storage_object_version(version_id)
      # end
    end
    
    # Unit test for method: {Moab::StorageRepository#storage_object}
    # Which returns: [StorageObject] The representation of the desired object storage directory
    # For input parameters:
    # * object_id [String] = The identifier of the digital object whose version is desired 
    specify 'Moab::StorageRepository#storage_object' do
      so = @storage_repository.storage_object(@obj)
      so.digital_object_id.should == "jq937jp0017"
      so.object_pathname.to_s.include?('ingests/jq/93/7j/p0/01/7/jq937jp0017').should == true
       
      # def storage_object(object_id)
      #   StorageObject.new(object_id, storage_object_pathname(object_id))
      # end
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
    

  end

end
