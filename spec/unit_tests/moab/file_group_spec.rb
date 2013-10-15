require 'spec_helper'
require 'spec_helper'

# Unit tests for class {Moab::FileGroup}
describe 'Moab::FileGroup' do
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Moab::FileGroup#initialize}
    # Which returns an instance of: [Moab::FileGroup]
    # For input parameters:
    # * opts [Hash<Symbol,Object>] = a hash containing any number of symbol => value pairs. The symbols should correspond to attributes declared using HappyMapper syntax 
    specify 'Moab::FileGroup#initialize' do
       
      # test initialization with required parameters (if any)
      opts = {}
      file_group = FileGroup.new(opts)
      file_group.should be_instance_of(FileGroup)
       
      # test initialization of arrays and hashes
      file_group.files.should be_kind_of(Array)
      file_group.signature_hash.should be_kind_of(Hash)
       
      # test initialization with options hash
      opts = OrderedHash.new
      opts[:group_id] = 'Test group_id'
      opts[:data_source] = 'Test data_source'
      file_group = FileGroup.new(opts)
      file_group.group_id.should == opts[:group_id]
      file_group.data_source.should == opts[:data_source]
      file_group.file_count.should == 0
      file_group.byte_count.should == 0
      file_group.block_count.should == 0
      file_group.files.should == []

      # def initialize(opts={})
      #   @signature_hash = OrderedHash.new
      #   @data_source = ""
      #   super(opts)
      # end
    end
  
  end
  
  describe '=========================== INSTANCE ATTRIBUTES ===========================' do
    
    before(:all) do
      @file_group = FileGroup.new.group_from_directory(@fixtures.join('data/jq937jp0017/v0001'),recursive=true)
    end
    
    # Unit test for attribute: {Moab::FileGroup#group_id}
    # Which stores: [String] The name of the file group
    specify 'Moab::FileGroup#group_id' do
      value = 'Test group_id'
      @file_group.group_id= value
      @file_group.group_id.should == value
       
      # attribute :group_id, String, :tag => 'groupId', :key => true
    end
    
    # Unit test for attribute: {Moab::FileGroup#data_source}
    # Which stores: [String] The directory location or other source of this groups file data
    specify 'Moab::FileGroup#data_source' do
      value = 'Test data_source'
      @file_group.data_source= value
      @file_group.data_source.should == value
       
      # attribute :data_source, String, :tag => 'dataSource'
    end
    
    # Unit test for attribute: {Moab::FileGroup#file_count}
    # Which stores: [Integer] The total number of data files (dynamically calculated)
    specify 'Moab::FileGroup#file_count' do
       @file_group.file_count.should == 11
       
      # attribute :file_count, Integer, :tag => 'fileCount', :on_save => Proc.new {|i| i.to_s}
       
      # def file_count
      #   files.inject(0) { |sum, manifestation| sum + manifestation.file_count }
      # end
    end
    
    # Unit test for attribute: {Moab::FileGroup#byte_count}
    # Which stores: [Integer] The total size (in bytes) of all data files (dynamically calculated)
    specify 'Moab::FileGroup#byte_count' do
      @file_group.byte_count.should == 217820
       
      # attribute :byte_count, Integer, :tag => 'byteCount', :on_save => Proc.new {|i| i.to_s}
       
      # def byte_count
      #   files.inject(0) { |sum, manifestation| sum + manifestation.byte_count }
      # end
    end
    
    # Unit test for attribute: {Moab::FileGroup#block_count}
    # Which stores: [Integer] The total disk usage (in 1 kB blocks) of all data files (estimating du -k result) (dynamically calculated)
    specify 'Moab::FileGroup#block_count' do
      @file_group.block_count.should == 216
       
      # attribute :block_count, Integer, :tag => 'blockCount', :on_save => Proc.new {|i| i.to_s}
       
      # def block_count
      #   files.inject(0) { |sum, manifestation| sum + manifestation.block_count }
      # end
    end
    
    # Unit test for attribute: {Moab::FileGroup#files}
    # Which stores: [Array<FileManifestation>] The set of files comprising the group
    specify 'Moab::FileGroup#files' do
      @file_group.files.size.should == 11
       
      # def files=(manifestiation_array)
      #   manifestiation_array.each do |manifestiation|
      #     add_file(manifestiation)
      #  end
      # end
       
      # def files
      #   @signature_hash.values
      # end
    end
    
    # Unit test for attribute: {Moab::FileGroup#signature_hash}
    # Which stores: [OrderedHash<FileSignature, FileManifestation>] The actual in-memory store for the collection of {FileManifestation} objects that are contained in this file group.
    specify 'Moab::FileGroup#signature_hash' do
      @file_group.signature_hash.size.should == 11
       
      # def signature_hash=(value)
      #   @signature_hash = value
      # end
       
      # def signature_hash
      #   @signature_hash
      # end
    end
    
    # Unit test for attribute: {Moab::FileGroup#base_directory}
    # Which stores: [Pathname] The full path used as the basis of the relative paths reported in {FileInstance} objects that are children of the {FileManifestation} objects contained in this file group
    specify 'Moab::FileGroup#base_directory' do
      @file_group.base_directory.to_s.should include('data/jq937jp0017/v0001')
       
      # def base_directory=(basepath)
      #   @base_directory = Pathname.new(basepath).realpath
      # end
       
      # def base_directory
      #   @base_directory
      # end
    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do
    
    before(:each) do
      @v1_file_group = FileGroup.new.group_from_directory(@fixtures.join('data/jq937jp0017/v0001/content'),recursive=true)
      @new_file_group = FileGroup.new
    end
    
    # Unit test for method: {Moab::FileGroup#path_hash}
    # Which returns: [OrderedHash<String,FileSignature>] An index of file paths, used to test for existence of a filename in this file group
    # For input parameters: (None)
    specify 'Moab::FileGroup#path_hash' do
       @v1_file_group.path_hash().keys.should ==
           ["intro-1.jpg", "intro-2.jpg", "page-1.jpg", "page-2.jpg", "page-3.jpg", "title.jpg"]
       
      # def path_hash
      #   path_hash = OrderedHash.new
      #   @signature_hash.each do |signature,manifestation|
      #     manifestation.instances.each do |instance|
      #       path_hash[instance.path] = signature
      #     end
      #   end
      #   path_hash
      # end
    end

    specify 'Moab::FileGroup#path_list' do
      @v1_file_group.path_list.should ==
          ["intro-1.jpg", "intro-2.jpg", "page-1.jpg", "page-2.jpg", "page-3.jpg", "title.jpg"]
    end

    # Unit test for method: {Moab::FileGroup#path_hash_subset}
    # Which returns: [OrderedHash<String,FileSignature>] A pathname,signature hash containing a subset of the filenames in this file group
    # For input parameters:
    # * signature_subset [Array<FileSignature>] = The signatures used to select the entries to return
    specify 'Moab::FileGroup#path_hash_subset' do
      files = @v1_file_group.files
      signature_subset = Array.new
      (0..2).each do |index|
        signature_subset << files[index].signature
      end
      subset = @v1_file_group.path_hash_subset(signature_subset)
      subset.size.should == 3

      # def path_hash_subset(signature_subset)
      #   path_hash = OrderedHash.new
      #   signature_subset.each do |signature|
      #     manifestation = @signature_hash[signature]
      #     manifestation.instances.each do |instance|
      #       path_hash[instance.path] = signature
      #     end
      #   end
      #   path_hash
      # end
    end

    # Unit test for method: {Moab::FileGroup#add_file}
    # Which returns: [void] Add a single {FileManifestation} object to this group
    # For input parameters:
    # * manifestation [FileManifestation] = The file manifestation to be added 
    specify 'Moab::FileGroup#add_file' do
      manifestation = @v1_file_group.files[0] 
      @new_file_group.add_file(manifestation)
      @new_file_group.files[0].should == manifestation
       
      # def add_file(manifestation)
      #   manifestation.instances.each do |instance|
      #     add_file_instance(manifestation.signature, instance)
      #   end
      # end
    end
    
    # Unit test for method: {Moab::FileGroup#add_file_instance}
    # Which returns: [void] Add a single {FileSignature},{FileInstance} key/value pair to this group. Data is actually stored in the {#signature_hash}
    # For input parameters:
    # * signature [FileSignature] = The signature of the file instance to be added 
    # * instance [FileInstance] = The pathname and datetime of the file instance to be added 
    specify 'Moab::FileGroup#add_file_instance' do
      manifestation = @v1_file_group.files[0] 
      manifestation.instances.each do |instance|
        @new_file_group.add_file_instance(manifestation.signature, instance)
      end
      @new_file_group.files[0].should == manifestation

      # add a second file instance to an existing manifestation
      new_instance = FileInstance.new(:path => "/my/path")
      @new_file_group.add_file_instance(manifestation.signature, new_instance)
      @new_file_group.files[0].instances.size.should == 2
             
      # def add_file_instance(signature,instance)
      #   if @signature_hash.has_key?(signature)
      #     manifestation = @signature_hash[signature]
      #   else
      #     manifestation = FileManifestation.new
      #     manifestation.signature = signature
      #     @signature_hash[signature] = manifestation
      #   end
      #   manifestation.instances << instance
      # end
    end
    
    # Unit test for method: {Moab::FileGroup#remove_file_having_path}
    # Which returns: [void] Remove a file from the inventory
    # For input parameters:
    # * path [String] = The path of the file to be removed
    specify 'Moab::FileGroup#remove_file_having_path' do
      file_group = FileGroup.new.group_from_directory(@fixtures.join('data/jq937jp0017/v0001/content'),recursive=true)
      before_file_count = file_group.file_count
      file_group.remove_file_having_path("page-1.jpg")
      after_file_count = file_group.file_count
      after_file_count.should == before_file_count - 1

      #def remove_file_having_path(path)
      #  signature = self.path_hash[path]
      #  @signature_hash.delete(signature)
      #end
    end

    # Unit test for method: {Moab::FileGroup#is_descendent_of_base?}
    # Which returns: [Boolean] Test whether the given path is contained within the {#base_directory}
    # For input parameters:
    # * pathname [Pathname] = The file path to be tested 
    specify 'Moab::FileGroup#is_descendent_of_base?' do
      @new_file_group.base_directory=@fixtures.join('data')
      pathname = @fixtures.join('data/jq937jp0017/v0001')
      @new_file_group.is_descendent_of_base?(pathname).should == true
      pathname = @fixtures.join('derivatives/manifests')
      lambda{@new_file_group.is_descendent_of_base?(pathname)}.should raise_exception
       
      # def is_descendent_of_base?(pathname)
      #   raise("base_directory has not been set") if @base_directory.nil?
      #   is_descendent = false
      #   pathname.realpath.ascend {|ancestor| is_descendent ||= (ancestor == @base_directory)}
      #   raise("#{pathname} is not a descendent of #{@base_directory}") unless is_descendent
      #   is_descendent
      # end
    end
    
    # Unit test for method: {Moab::FileGroup#igroup_from_directory_digests}
    specify 'Moab::FileGroup#group_from_directory_digests' do
      directory = 'my_directory'
      file_digests = 'my_digests'
      recursive = false
      file_group = FileGroup.new
      file_group.should_receive(:group_from_directory).with(directory, recursive)
      file_group.group_from_bagit_subdir(directory, file_digests, recursive)
      file_group.instance_variable_get(:@signatures_from_bag).should == file_digests

      #@param  directory [Pathame,String] The directory whose children are to be added to the file group
      #@param digests [Hash<Pathname,Signature>] The fixity data already calculated for the files
      #@param recursive [Boolean] if true, descend into child directories
      # @return [FileGroup] Harvest a directory (using digest hash for fixity data) and add all files to the file group
      #def group_from_directory_digests(directory, digests, recursive=true)
      #  @file_digests = digests
      #  group_from_directory(directory, recursive)
      #end
    end

    # Unit test for method: {Moab::FileGroup#group_from_directory}
    # Which returns: [FileGroup] Harvest a directory and add all files to the file group
    # For input parameters:
    # * directory [Pathname, String] = The location of the files to harvest 
    # * recursive [Boolean] = if true, descend into child directories
    specify 'Moab::FileGroup#group_from_directory' do
      directory = @fixtures.join('data/jq937jp0017/v0001/content')
      recursive = true
      group = FileGroup.new
      group.should_receive(:harvest_directory).with(directory, recursive)
      group= group.group_from_directory(directory, recursive)
      group.should be_instance_of(FileGroup)
      group.base_directory.should == directory.realpath
      group.data_source.should == directory.realpath.to_s

      # def group_from_directory(directory, recursive=true)
      #   self.base_directory = directory
      #   @data_source = @base_directory.to_s
      #   harvest_directory(directory, recursive)
      #   self
      # end
    end

    # Unit test for method: {Moab::FileGroup#harvest_directory}
    # Which returns: [void] Traverse a directory tree and add all files to the file group Note that unlike Find.find and Dir.glob, Pathname passes through symbolic links
    # For input parameters:
    # * path [Pathname, String] = pathname of the directory to be harvested
    # * recursive [Boolean] = if true, also harvest subdirectories
    # * validated [Boolean] = if true, path is verified to be descendant of (#base_directory)
    specify 'Moab::FileGroup#harvest_directory' do
      path = @fixtures.join('derivatives/manifests')
      file_group = FileGroup.new
      file_group.base_directory=path
      file_group.harvest_directory(path,recursive=true)
      file_group.file_count=0

      path = @fixtures.join('derivatives/packages/v0001')
      second_group = FileGroup.new
      second_group.base_directory=path
      second_group.harvest_directory(path,recursive=false)
      second_group.file_count=0

      # def harvest_directory(path, recursive, validated=nil)
      #   pathname=Pathname.new(path).realpath
      #   validated ||= is_descendent_of_base?(pathname)
      #   pathname.children.each do |child|
      #     if child.basename.to_s == ".DS_Store"
      #       next
      #     elsif child.directory?
      #       harvest_directory(child,recursive, validated) if recursive
      #     else
      #       add_physical_file(child, validated)
      #     end
      #   end
      #   nil
      # end
    end

    # Unit test for method: {Moab::FileGroup#add_physical_file}
    # Which returns: [void] Add a single physical file's data to the array of files in this group
    # For input parameters:
    # * pathname [Pathname, String] = The location of the file to be added 
    # * validated [Boolean] = if true, path is verified to be descendant of (#base_directory)
    specify 'Moab::FileGroup#add_physical_file' do
      pathname = @fixtures.join('data/jq937jp0017/v0001/content/title.jpg')
      group = FileGroup.new
      group.base_directory = @fixtures.join('data/jq937jp0017/v0001/content')
      group.add_physical_file(pathname)
      group.files.size.should == 1
      group.files[0].signature.should == FileSignature.new(
          :size=>40873, :md5=>"1a726cd7963bd6d3ceb10a8c353ec166", :sha1=>"583220e0572640abcd3ddd97393d224e8053a6ad")
      group.files[0].instances[0].path.should == 'title.jpg'

      signature = double(FileSignature)
      FileSignature.stub(:new).and_return(signature)
      signature.should_receive(:signature_from_file).with(pathname)
      group.add_physical_file(pathname)

      signature = double(FileSignature)
      signature_for_path = double(Hash)
      signature_for_path.should_receive(:[]).with(pathname).twice.and_return(signature)
      group.instance_variable_set(:@signatures_from_bag, signature_for_path)
      signature.should_receive(:complete?).and_return(false)
      signature.should_receive(:normalized_signature).with(pathname).and_return(signature)
      group.should_receive(:add_file_instance)
      group.add_physical_file(pathname)

      #def add_physical_file(pathname, validated=nil)
      #  pathname=Pathname.new(pathname).realpath
      #  validated ||= is_descendent_of_base?(pathname)
      #  instance = FileInstance.new.instance_from_file(pathname, @base_directory)
      #  signature = FileSignature.new
      #  if @file_digests && @file_digests[pathname]
      #    signature.signature_from_file_digest(pathname, @file_digests[pathname])
      #  else
      #    signature.signature_from_file(pathname)
      #  end
      #  add_file_instance(signature,instance)
      #end
    end
  
  end

end
