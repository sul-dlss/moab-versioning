require 'spec_helper'

# Unit tests for class {Stanford::StorageRepository}
describe 'Stanford::StorageRepository' do
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Stanford::StorageRepository#initialize}
    # Which returns an instance of: [Stanford::StorageRepository]
    # For input parameters:
    # * repository_home [Pathname, String] = The location of the root directory of the repository storage node 
    specify 'Stanford::StorageRepository#initialize' do
       
      storage_repository_default = StorageRepository.new()
      storage_repository_default.should be_instance_of(StorageRepository)
      storage_repository_default.repository_home.to_s.should =~ /fixtures\/derivatives\/ingest/

      # test initialization with required parameters (if any)
      repository_home = Pathname.new('/test/repository_home') 
      storage_repository = StorageRepository.new(repository_home)
      storage_repository.should be_instance_of(StorageRepository)
      storage_repository.repository_home.should == repository_home
       

      # def initialize(repository_home=Moab::Config.repository_home)
      #   @repository_home = Pathname.new(repository_home)
      # end
    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do
    
    before(:each) do
      @repository_home = Pathname.new('/test/repository_home') 
      @storage_repository = StorageRepository.new(@repository_home)
      @object_id = @druid

    end
    
    # Unit test for method: {Stanford::StorageRepository#storage_object_version}
    # Which returns: [StorageObjectVersion] The representation of the desired object version's storage directory
    # For input parameters:
    # * object_id [String] = The identifier of the digital object whose version is desired 
    # * version_id [Integer] = The desired version 
    specify 'Stanford::StorageRepository#storage_object_version' do
      version_id = 2
      version = @storage_repository.storage_object_version(@object_id, version_id)
      version.should be_instance_of(StorageObjectVersion)
      version.version_id.should == version_id
      version.version_pathname.should == Pathname("/test/repository_home/jq937jp0017/v0002")

      # def storage_object_version(object_id, version_id=nil)
      #   storage_object(object_id).storage_object_version(version_id)
      # end
    end
    
    # Unit test for method: {Stanford::StorageRepository#storage_object}
    # Which returns: [StorageObject] The representation of the desired object storage directory
    # For input parameters:
    # * object_id [String] = The identifier of the digital object whose version is desired 
    specify 'Stanford::StorageRepository#storage_object' do
      so = @storage_repository.storage_object(@object_id)
      so.digital_object_id.should == "druid:jq937jp0017"
      so.object_pathname.should == Pathname("/test/repository_home/jq937jp0017")
       
      # def storage_object(object_id)
      #   StorageObject.new(object_id, storage_object_pathname(object_id))
      # end
    end
    
    # Unit test for method: {Stanford::StorageRepository#storage_object_pathname}
    # Which returns: [Pathname] The location of the desired object's home directory
    # For input parameters:
    # * object_id [String] = The identifier of the digital object whose version is desired 
    specify 'Stanford::StorageRepository#storage_object_pathname' do
      @storage_repository.storage_object_pathname(@object_id).should == Pathname("/test/repository_home/jq937jp0017")
       
      # def storage_object_pathname(object_id)
      #   @repository_home.join(druid_tree(object_id))
      # end
    end
    
    # Unit test for method: {Stanford::StorageRepository#druid_tree}
    # Which returns: [String] the druid tree directory path based on the given object identifier.
    # For input parameters:
    # * object_id [String] = The identifier of the digital object whose path is requested 
    specify 'Stanford::StorageRepository#druid_tree' do
      @storage_repository.druid_tree(@object_id).should == "druid/jq/937/jp/0017"
       
      # def druid_tree(object_id)
      #   syntax_msg = "Identifier has invalid suri syntax: #{object_id}"
      #   raise syntax_msg + "nil or empty" if object_id.to_s.empty?
      #   namespace,identifier = object_id.split(':')
      #   raise syntax_msg if (namespace.to_s.empty? || identifier.to_s.empty?)
      #   # The object identifier must be in the SURI format, otherwise an exception is raised:
      #   # e.g. druid:aannnaannnn
      #   # where 'a' is an alphabetic character
      #   # where 'n' is a numeric character
      #   if(identifier =~ /^([a-z]{2})(\d{3})([a-z]{2})(\d{4})$/ )
      #     return File.join(namespace, $1, $2, $3, $4)
      #   else
      #     raise syntax_msg
      #   end
      # end
    end
  
  end

end
