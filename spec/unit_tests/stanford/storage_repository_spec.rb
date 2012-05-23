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

    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do
    
    before(:each) do
      @storage_repository = StorageRepository.new()
      @object_id = @druid

    end

    
    # Unit test for method: {Stanford::StorageRepository#storage_object_pathname}
    # Which returns: [Pathname] The location of the desired object's home directory
    # For input parameters:
    # * object_id [String] = The identifier of the digital object whose version is desired 
    specify 'Stanford::StorageRepository#storage_object_pathname' do
      Moab::Config.configure do
        path_method :druid_tree
      end
      @storage_repository.storage_object_pathname(@object_id).to_s.should =~ /ingests\/jq\/937\/jp\/0017\/jq937jp0017/

      Moab::Config.configure do
        path_method :druid
      end
      @storage_repository.storage_object_pathname(@object_id).to_s.should =~ /ingests\/jq937jp0017/

      # def storage_object_pathname(object_id)
      #   case Moab::Config.path_method
      #     when :druid_tree
      #       repository_home.join(druid_tree(object_id))
      #     when :druid
      #       repository_home.join(object_id.split(/:/)[-1])
      # end
      # end
    end
    
    # Unit test for method: {Stanford::StorageRepository#druid_tree}
    # Which returns: [String] the druid tree directory path based on the given object identifier.
    # For input parameters:
    # * object_id [String] = The identifier of the digital object whose path is requested 
    specify 'Stanford::StorageRepository#druid_tree' do
      @storage_repository.druid_tree(@object_id).should == "jq/937/jp/0017/jq937jp0017"
      lambda{@storage_repository.druid_tree('123cd456nm')}.should raise_exception
       
      # def druid_tree(object_id)
      #   syntax_msg = "Identifier has invalid suri syntax: #{object_id}"
      #   raise syntax_msg + "nil or empty" if object_id.to_s.empty?
      #   identifier = object_id.split(':')[-1]
      #   raise syntax_msg if  identifier.to_s.empty?
      #   # The object identifier must be in the SURI format, otherwise an exception is raised:
      #   # e.g. druid:aannnaannnn or aannnaannnn
      #   # where 'a' is an alphabetic character
      #   # where 'n' is a numeric character
      #   if identifier =~ /^([a-z]{2})(\d{3})([a-z]{2})(\d{4})$/
      #     return File.join( $1, $2, $3, $4, identifier)
      #   else
      #     raise syntax_msg
      #   end
      # end
    end
  
  end

end
