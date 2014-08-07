require 'spec_helper'

# Unit tests for class {Moab::FileManifestation}
describe 'Moab::FileManifestation' do
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Moab::FileManifestation#initialize}
    # Which returns an instance of: [Moab::FileManifestation]
    # For input parameters:
    # * opts [Hash<Symbol,Object>] = a hash containing any number of symbol => value pairs. The symbols should correspond to attributes declared using HappyMapper syntax 
    specify 'Moab::FileManifestation#initialize' do
       
      # test initialization with required parameters (if any)
      opts = {}
      file_manifestation = FileManifestation.new(opts)
      expect(file_manifestation).to be_instance_of(FileManifestation)
      expect(file_manifestation.instances).to be_instance_of(Array)
       
      # test initialization with options hash
      opts = OrderedHash.new
      opts[:signature] = double(FileSignature.name)
      opts[:instances] = double(FileInstance.name)
      file_manifestation = FileManifestation.new(opts)
      expect(file_manifestation.signature).to eq(opts[:signature])
      expect(file_manifestation.instances).to eq(opts[:instances])
       
      # def initialize(opts={})
      #   @instances = Array.new
      #   super(opts)
      # end
    end
  
  end
  
  describe '=========================== INSTANCE ATTRIBUTES ===========================' do
    
    before(:all) do
      opts = {}
      @file_manifestation = FileManifestation.new(opts)
    end
    
    # Unit test for attribute: {Moab::FileManifestation#signature}
    # Which stores: [FileSignature] The fixity data of the file instance
    specify 'Moab::FileManifestation#signature' do
      value = double(FileSignature.name)
      @file_manifestation.signature= value
      expect(@file_manifestation.signature).to eq(value)
      @file_manifestation.signature= [value]
      expect(@file_manifestation.signature).to eq(value)

      # def signature=(signature)
      #   @signature = signature.is_a?(Array) ? signature[0] : signature
      # end
       
      # def signature
      #   @signature.is_a?(Array) ? @signature[0] : @signature
      # end
    end
    
    # Unit test for attribute: {Moab::FileManifestation#instances}
    # Which stores: [Array<FileInstance>] The location(s) of the file manifestation's file instances
    specify 'Moab::FileManifestation#instances' do
      value = double(FileInstance.name)
      @file_manifestation.instances= value
      expect(@file_manifestation.instances).to eq(value)
       
      # has_many :instances, FileInstance
    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do
    
    before(:each) do
      @v1_base_directory = @fixtures.join('data/jq937jp0017/v0001/content')
      @title_v1_pathname = @fixtures.join('data/jq937jp0017/v0001/content/title.jpg')
      @page1_v1_pathname = @fixtures.join('data/jq937jp0017/v0001/content/page-1.jpg')

      @title_v1_signature = FileSignature.new.signature_from_file(@title_v1_pathname)

      @title_v1_instance = FileInstance.new.instance_from_file(@title_v1_pathname,@v1_base_directory)
      @page1_v1_instance = FileInstance.new.instance_from_file(@page1_v1_pathname,@v1_base_directory)

      @opts = {}
      @file_manifestation = FileManifestation.new(@opts)

      @file_manifestation.signature = @title_v1_signature
      @file_manifestation.instances << @title_v1_instance
      @file_manifestation.instances << @page1_v1_instance
    end
    
    # Unit test for method: {Moab::FileManifestation#paths}
    # Which returns: [Array<String>] Create an array from all the file paths of the child {FileInstance} objects
    # For input parameters: (None)
    specify 'Moab::FileManifestation#paths' do
      expect(@file_manifestation.paths()).to eq(["title.jpg", "page-1.jpg"])
       
      # def paths
      #   instances.collect { |i| i.path}
      # end
    end
    
    # Unit test for method: {Moab::FileManifestation#file_count}
    # Which returns: [Integer] The total number of {FileInstance} objects in this manifestation. (Number of files that share this manifestation's signature)
    # For input parameters: (None)
    specify 'Moab::FileManifestation#file_count' do
      expect(@file_manifestation.file_count()).to eq(2)
       
      # def file_count
      #   instances.size
      # end
    end
    
    # Unit test for method: {Moab::FileManifestation#byte_count}
    # Which returns: [Integer] The total size (in bytes) of all files that share this manifestation's signature
    # For input parameters: (None)
    specify 'Moab::FileManifestation#byte_count' do
      expect(@file_manifestation.byte_count()).to eq(81746)
       
      # def byte_count
      #   file_count.to_i * signature.size.to_i
      # end
    end
    
    # Unit test for method: {Moab::FileManifestation#block_count}
    # Which returns: [Integer] The total disk usage (in 1 kB blocks) of all files that share this manifestation's signature (estimating du -k result)
    # For input parameters: (None)
    specify 'Moab::FileManifestation#block_count' do
      expect(@file_manifestation.block_count()).to eq(80)
       
      # def block_count
      #   block_size=1024
      #   instance_blocks = (signature.size.to_i + block_size - 1)/block_size
      #   file_count * instance_blocks
      # end
    end

    # Unit test for method: {Moab::FileManifestation#==}
    # Which returns: [Boolean] True if {FileManifestation} objects have same content
    # For input parameters:
    # * other [FileManifestation] = The {FileManifestation} object to compare with self
    specify 'Moab::FileManifestation#==' do
      other = @file_manifestation
      expect(@file_manifestation.==(other)).to eq(true)

      # def ==(other)
      #   (self.signature == other.signature) && (self.instances == other.instances)
      # end
    end
  
  end

end
