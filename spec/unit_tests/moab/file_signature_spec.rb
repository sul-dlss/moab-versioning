require 'spec_helper'

# Unit tests for class {Moab::FileSignature}
describe 'Moab::FileSignature' do
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Moab::FileSignature#initialize}
    # Which returns an instance of: [Moab::FileSignature]
    # For input parameters:
    # * opts [Hash<Symbol,Object>] = a hash containing any number of symbol => value pairs. The symbols should correspond to attributes declared using HappyMapper syntax 
    specify 'Moab::FileSignature#initialize' do
       
      # test initialization with required parameters (if any)
      opts = {}
      file_signature = FileSignature.new(opts)
      file_signature.should be_instance_of(FileSignature)
       
      # test initialization with options hash
      opts = OrderedHash.new
      opts[:size] = 75
      opts[:md5] = 'Test md5'
      opts[:sha1] = 'Test sha1'
      file_signature = FileSignature.new(opts)
      file_signature.size.should == opts[:size]
      file_signature.md5.should == opts[:md5]
      file_signature.sha1.should == opts[:sha1]
       
      # def initialize(opts={})
      #   super(opts)
      # end
    end
  
  end
  
  describe '=========================== INSTANCE ATTRIBUTES ===========================' do
    
    before(:all) do
      opts = {}
      @file_signature = FileSignature.new(opts)
    end
    
    # Unit test for attribute: {Moab::FileSignature#size}
    # Which stores: [Integer] \@size = The size of the file in bytes
    specify 'Moab::FileSignature#size' do
      value = 19
      @file_signature.size= value
      @file_signature.size.should == value
       
      # attribute :size, Integer, :on_save => Proc.new { |n| n.to_s }
    end
    
    # Unit test for attribute: {Moab::FileSignature#md5}
    # Which stores: [String] \@md5 = The MD5 checksum value of the file
    specify 'Moab::FileSignature#md5' do
      value = 'Test md5'
      @file_signature.md5= value
      @file_signature.md5.should == value

      # attribute :md5, String
    end
    
    # Unit test for attribute: {Moab::FileSignature#sha1}
    # Which stores: [String] \@sha1 = The SHA1 checksum value of the file
    specify 'Moab::FileSignature#sha1' do
      value = 'Test sha1'
      @file_signature.sha1= value
      @file_signature.sha1.should == value
       
      # attribute :sha1, String
    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do
    
    before(:all) do
      @title_v1_pathname = @fixtures.join('data/jq937jp0017/v1/content/title.jpg')
      @title_v2_pathname = @fixtures.join('data/jq937jp0017/v2/content/title.jpg')
      @page1_v1_pathname = @fixtures.join('data/jq937jp0017/v1/content/page-1.jpg')
      @page1_v2_pathname = @fixtures.join('data/jq937jp0017/v2/content/page-1.jpg')

      @title_v1_signature = FileSignature.new.signature_from_file(@title_v1_pathname)
      @title_v2_signature = FileSignature.new.signature_from_file(@title_v2_pathname)
      @page1_v1_signature = FileSignature.new.signature_from_file(@page1_v1_pathname)
      @page1_v2_signature = FileSignature.new.signature_from_file(@page1_v2_pathname)
    end
    
    # Unit test for method: {Moab::FileSignature#fixity}
    # Which returns: [Array<String>] An array of fixity data to be compared for equality
    # For input parameters: (None)
    specify 'Moab::FileSignature#fixity' do
      @title_v1_signature.fixity().should ==
        ["40873", "1a726cd7963bd6d3ceb10a8c353ec166", "583220e0572640abcd3ddd97393d224e8053a6ad"]

      # def fixity
      #   [@size.to_s, @md5, @sha1]
      # end
    end
    
    # Unit test for method: {Moab::FileSignature#eql?}
    # Which returns: [Boolean] Returns true if self and other have the same fixity data.
    # For input parameters:
    # * other [FileSignature] = The other file signature being compared to this signature 
    specify 'Moab::FileSignature#eql?' do
      @title_v1_signature.eql?(@title_v2_signature).should == true
      @page1_v1_signature.eql?(@page1_v2_signature).should == false
       
      # def eql?(other)
      #   self.fixity == other.fixity
      # end
    end
    
    # Unit test for method: {Moab::FileSignature#==}
    # Which returns: [Boolean] Returns true if self and other have the same fixity data.
    # For input parameters:
    # * other [FileSignature] = The other file signature being compared to this signature 
    specify 'Moab::FileSignature#==' do
      (@title_v1_signature == @title_v2_signature).should == true
      (@page1_v1_signature == @page1_v2_signature).should == false
       
      # def ==(other)
      #   eql?(other)
      # end
    end
    
    # Unit test for method: {Moab::FileSignature#hash}
    # Which returns: [Fixnum] Compute a hash-code for the fixity value array.
    # For input parameters: (None)
    specify 'Moab::FileSignature#hash' do
      (@title_v1_signature.hash == @title_v2_signature.hash).should == true
      (@page1_v1_signature.hash == @page1_v2_signature.hash).should == false
       
      # def hash
      #   fixity.hash
      # end
    end
    
    # Unit test for method: {Moab::FileSignature#signature_from_file}
    # Which returns: [FileSignature] Generate a FileSignature instance containing size and checksums for a physical file
    # For input parameters:
    # * pathname [Pathname] = The location of the file to be digested 
    specify 'Moab::FileSignature#signature_from_file' do
      title_v1_signature = FileSignature.new.signature_from_file(@title_v1_pathname)
      title_v1_signature.size.should == 40873
      title_v1_signature.md5.should == "1a726cd7963bd6d3ceb10a8c353ec166"
      title_v1_signature.sha1.should ==  "583220e0572640abcd3ddd97393d224e8053a6ad"

      # def signature_from_file(pathname)
      #   @size = pathname.size
      #   md5_digest = Digest::MD5.new
      #   sha1_digest = Digest::SHA1.new
      #   pathname.open("r") do |stream|
      #     while buffer = stream.read(8192)
      #       md5_digest.update(buffer)
      #       sha1_digest.update(buffer)
      #     end
      #   end
      #   @md5 = md5_digest.hexdigest
      #   @sha1 = sha1_digest.hexdigest
      #   self
      # end
    end
  
  end

end
