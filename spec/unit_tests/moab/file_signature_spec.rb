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
      expect(file_signature).to be_instance_of(FileSignature)
       
      # test initialization with options hash
      opts = Hash.new
      opts[:size] = 75
      opts[:md5] = 'Test md5'
      opts[:sha1] = 'Test sha1'
      file_signature = FileSignature.new(opts)
      expect(file_signature.size).to eq(opts[:size])
      expect(file_signature.md5).to eq(opts[:md5])
      expect(file_signature.sha1).to eq(opts[:sha1])
       
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
    # Which stores: [Integer] The size of the file in bytes
    specify 'Moab::FileSignature#size' do
      value = 19
      @file_signature.size= value
      expect(@file_signature.size).to eq(value)
       
      # attribute :size, Integer, :on_save => Proc.new { |n| n.to_s }
    end
    
    # Unit test for attribute: {Moab::FileSignature#md5}
    # Which stores: [String] The MD5 checksum value of the file
    specify 'Moab::FileSignature#md5' do
      value = 'Test md5'
      @file_signature.md5= value
      expect(@file_signature.md5).to eq(value)

      # attribute :md5, String
    end
    
    # Unit test for attribute: {Moab::FileSignature#sha1}
    # Which stores: [String] The SHA1 checksum value of the file
    specify 'Moab::FileSignature#sha1' do
      value = 'Test sha1'
      @file_signature.sha1= value
      expect(@file_signature.sha1).to eq(value)
       
      # attribute :sha1, String
    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do
    
    before(:all) do
      @title_v1_pathname = @fixtures.join('data/jq937jp0017/v0001/content/title.jpg')
      @title_v2_pathname = @fixtures.join('data/jq937jp0017/v0002/content/title.jpg')
      @page1_v1_pathname = @fixtures.join('data/jq937jp0017/v0001/content/page-1.jpg')
      @page1_v2_pathname = @fixtures.join('data/jq937jp0017/v0002/content/page-1.jpg')

      @title_v1_signature = FileSignature.new.signature_from_file(@title_v1_pathname)
      @title_v2_signature = FileSignature.new.signature_from_file(@title_v2_pathname)
      @page1_v1_signature = FileSignature.new.signature_from_file(@page1_v1_pathname)
      @page1_v2_signature = FileSignature.new.signature_from_file(@page1_v2_pathname)
    end

    specify 'Moab::FileSignature#set_checksum' do
      signature = FileSignature.new
      signature.set_checksum(:md5,'1a726cd7963bd6d3ceb10a8c353ec166')
      signature.set_checksum(:sha1,'583220e0572640abcd3ddd97393d224e8053a6ad')
      signature.set_checksum(:sha256,'8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5')
      expect(signature.checksums()).to eq(
          {:md5=>"1a726cd7963bd6d3ceb10a8c353ec166",
           :sha1=>"583220e0572640abcd3ddd97393d224e8053a6ad",
           :sha256=>"8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5"}
      )
      expect{signature.set_checksum('xyz','dummy')}.to raise_exception(/Unknown checksum type 'xyz'/)
    end

    # Unit test for method: {Moab::FileSignature#fixity}
    # Which returns: [Hash<Symbol,String>] An hash of fixity data of the signature object
    # For input parameters: (None)
    specify 'Moab::FileSignature#fixity' do
      expect(@title_v1_signature.fixity()).to eq(
          {:size=>"40873", :md5=>"1a726cd7963bd6d3ceb10a8c353ec166", :sha1=>"583220e0572640abcd3ddd97393d224e8053a6ad", :sha256=>"8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5"}
      )
      # def fixity
      #   [@size.to_s, @md5, @sha1]
      # end
    end

    # Unit test for method: {Moab::FileSignature#checksums}
    # Which returns: [Hash<Symbol,String>] An hash of checksum data only
    # For input parameters: (None)
    specify 'Moab::FileSignature#checksums' do
      expect(@title_v1_signature.checksums()).to eq(
          {:md5=>"1a726cd7963bd6d3ceb10a8c353ec166", :sha1=>"583220e0572640abcd3ddd97393d224e8053a6ad", :sha256=>"8b0cee693a3cf93cf85220dd67c5dc017a7edcdb59cde8fa7b7f697be162b0c5"}
      )
      # def fixity
      #   [@size.to_s, @md5, @sha1]
      # end
    end

    # Unit test for method: {Moab::FileSignature#eql?}
    # Which returns: [Boolean] Returns true if self and other have the same fixity data.
    # For input parameters:
    # * other [FileSignature] = The other file signature being compared to this signature 
    specify 'Moab::FileSignature#eql?' do
      expect(@title_v1_signature.eql?(@title_v2_signature)).to eq(true)
      expect(@page1_v1_signature.eql?(@page1_v2_signature)).to eq(false)
   end
    
    # Unit test for method: {Moab::FileSignature#==}
    # Which returns: [Boolean] Returns true if self and other have the same fixity data.
    # For input parameters:
    # * other [FileSignature] = The other file signature being compared to this signature 
    specify 'Moab::FileSignature#==' do
      expect(@title_v1_signature == @title_v2_signature).to eq(true)
      expect(@page1_v1_signature == @page1_v2_signature).to eq(false)
       
      # def ==(other)
      #   eql?(other)
      # end
    end
    
    # Unit test for method: {Moab::FileSignature#hash}
    # Which returns: [Fixnum] Compute a hash-code for the fixity value array.
    # For input parameters: (None)
    specify 'Moab::FileSignature#hash' do
      expect(@title_v1_signature.hash == @title_v2_signature.hash).to eq(true)
      expect(@page1_v1_signature.hash == @page1_v2_signature.hash).to eq(false)
    end

    # Unit test for method: {Moab::FileSignature#signature_from_file}
    # Which returns: [FileSignature] Generate a FileSignature instance containing size and checksums for a physical file
    # For input parameters:
    # * pathname [Pathname] = The location of the file to be digested 
    specify 'Moab::FileSignature#signature_from_file' do
      title_v1_signature = FileSignature.new.signature_from_file(@title_v1_pathname)
      expect(title_v1_signature.size).to eq(40873)
      expect(title_v1_signature.md5).to eq("1a726cd7963bd6d3ceb10a8c353ec166")
      expect(title_v1_signature.sha1).to eq("583220e0572640abcd3ddd97393d224e8053a6ad")
    end

    specify 'Moab::FileSignature#normalized_signature' do
      pathname = @packages.join('v0001/data/content/page-2.jpg')
      file_fixity = { :size=>"39450",
          :md5=>"82fc107c88446a3119a51a8663d1e955",
          :sha1=>"d0857baa307a2e9efff42467b5abd4e1cf40fcd5",
          :sha256=>"235de16df4804858aefb7690baf593fb572d64bb6875ec522a4eea1f4189b5f0"}
      source = FileSignature.new(file_fixity)
      signature = source.normalized_signature(pathname)
      expect(signature.fixity).to eq(file_fixity)
      source = FileSignature.new(:size=>"39450", :sha1 => 'd0857baa307a2e9efff42467b5abd4e1cf40fcd5')
      signature = source.normalized_signature(pathname)
      expect(signature.fixity).to eq(file_fixity)
      source = FileSignature.new( :sha1 => 'dummy')
      expect{source.normalized_signature(pathname)}.to raise_exception(/Signature inconsistent between inventory and file/)
    end


    specify 'Moab::FileSignature.checksum_names_for_type' do
      expect(FileSignature.checksum_names_for_type).to eq(
          {:md5=>["MD5"], :sha1=>["SHA-1", "SHA1"],:sha256=>["SHA-256", "SHA256"]}
      )
    end

    specify 'Moab::FileSignature.checksum_type_for_name' do
      expect(FileSignature.checksum_type_for_name).to eq(
          {"MD5"=>:md5, "SHA1"=>:sha1, "SHA-1"=>:sha1, "SHA256"=>:sha256, "SHA-256"=>:sha256}
      )
    end

  end

end
