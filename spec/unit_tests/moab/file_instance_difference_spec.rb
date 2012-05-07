require 'spec_helper'

# Unit tests for class {Moab::FileInstanceDifference}
describe 'Moab::FileInstanceDifference' do
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Moab::FileInstanceDifference#initialize}
    # Which returns an instance of: [Moab::FileInstanceDifference]
    # For input parameters:
    # * opts [Hash<Symbol,Object>] = a hash containing any number of symbol => value pairs. The symbols should correspond to attributes declared using HappyMapper syntax 
    specify 'Moab::FileInstanceDifference#initialize' do
       
      # test initialization with required parameters (if any)
      opts = {}
      file_instance_difference = FileInstanceDifference.new(opts)
      file_instance_difference.should be_instance_of(FileInstanceDifference)
       
      # test initialization of arrays and hashes
      file_instance_difference.signatures.should be_kind_of(Array)
      file_instance_difference.signatures.size.should == 0

      # test initialization with options hash
      opts = OrderedHash.new
      opts[:change] = 'Test change'
      opts[:basis_path] = 'Test basis_path'
      opts[:other_path] = 'Test other_path'
      file_instance_difference = FileInstanceDifference.new(opts)
      file_instance_difference.change.should == opts[:change]
      file_instance_difference.basis_path.should == opts[:basis_path]
      file_instance_difference.other_path.should == opts[:other_path]

      # def initialize(opts={})
      #   @signatures = Array.new
      #   super(opts)
      # end
    end
  
  end
  
  describe '=========================== INSTANCE ATTRIBUTES ===========================' do
    
    before(:all) do
      opts = {}
      @file_instance_difference = FileInstanceDifference.new(opts)
    end
    
    # Unit test for attribute: {Moab::FileInstanceDifference#change}
    # Which stores: [String] \@change = The type of file change
    specify 'Moab::FileInstanceDifference#change' do
      value = 'Test change'
      @file_instance_difference.change= value
      @file_instance_difference.change.should == value
       
      # attribute :change, String
    end
    
    # Unit test for attribute: {Moab::FileInstanceDifference#basis_path}
    # Which stores: [String] \@basisPath = The file's path in the basis inventory (usually for an old version)
    specify 'Moab::FileInstanceDifference#basis_path' do
      value = 'Test basis_path'
      @file_instance_difference.basis_path= value
      @file_instance_difference.basis_path.should == value
       
      # attribute :basis_path, String, :tag => 'basisPath', :on_save => Proc.new { |s| s.to_s }
    end
    
    # Unit test for attribute: {Moab::FileInstanceDifference#other_path}
    # Which stores: [String] \@otherPath = The file's path in the other inventory (usually for an new version) compared against the basis
    specify 'Moab::FileInstanceDifference#other_path' do
      value = 'Test other_path'
      @file_instance_difference.other_path= value
      @file_instance_difference.other_path.should == value
       
      # attribute :other_path, String, :tag => 'otherPath', :on_save => Proc.new { |s| s.to_s }
    end
    
    # Unit test for attribute: {Moab::FileInstanceDifference#signatures}
    # Which stores: [Array<FileSignature>] \[<fileSignature>] = The fixity data of the file manifestation(s) (plural if change was a content modification)
    specify 'Moab::FileInstanceDifference#signatures' do
      @file_instance_difference.signatures.size.should == 0
       
      # has_many :signatures, FileSignature
    end
  
  end

end
