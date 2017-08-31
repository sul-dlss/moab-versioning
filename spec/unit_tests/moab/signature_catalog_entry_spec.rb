require 'spec_helper'

# Unit tests for class {Moab::SignatureCatalogEntry}
describe 'Moab::SignatureCatalogEntry' do

  describe '=========================== CONSTRUCTOR ===========================' do

    # Unit test for constructor: {Moab::SignatureCatalogEntry#initialize}
    # Which returns an instance of: [Moab::SignatureCatalogEntry]
    # For input parameters:
    # * opts [Hash<Symbol,Object>] = a hash containing any number of symbol => value pairs. The symbols should
    #  correspond to attributes declared using HappyMapper syntax
    specify 'Moab::SignatureCatalogEntry#initialize' do

      # test initialization with required parameters (if any)
      opts = {}
      signature_catalog_entry = Moab::SignatureCatalogEntry.new(opts)
      expect(signature_catalog_entry).to be_instance_of(Moab::SignatureCatalogEntry)

      # test initialization with options hash
      opts = Hash.new
      opts[:version_id] = 26
      opts[:group_id] = 'Test group_id'
      opts[:path] = 'Test path'
      opts[:signature] = double(Moab::FileSignature.name)
      signature_catalog_entry = Moab::SignatureCatalogEntry.new(opts)
      expect(signature_catalog_entry.version_id).to eq(opts[:version_id])
      expect(signature_catalog_entry.group_id).to eq(opts[:group_id])
      expect(signature_catalog_entry.path).to eq(opts[:path])
      expect(signature_catalog_entry.signature).to eq(opts[:signature])

      # def initialize(opts={})
      #   super(opts)
      # end
    end

  end

  describe '=========================== INSTANCE ATTRIBUTES ===========================' do

    before(:all) do
      opts = {}
      @signature_catalog_entry = Moab::SignatureCatalogEntry.new(opts)
    end

    # Unit test for attribute: {Moab::SignatureCatalogEntry#version_id}
    # Which stores: [Integer] The ordinal version number
    specify 'Moab::SignatureCatalogEntry#version_id' do
      value = 8
      @signature_catalog_entry.version_id= value
      expect(@signature_catalog_entry.version_id).to eq(value)

      # attribute :version_id, Integer, :tag => 'originalVersion', :key => true, :on_save => Proc.new {|n| n.to_s}
    end

    # Unit test for attribute: {Moab::SignatureCatalogEntry#group_id}
    # Which stores: [String] The name of the file group
    specify 'Moab::SignatureCatalogEntry#group_id' do
      value = 'Test group_id'
      @signature_catalog_entry.group_id= value
      expect(@signature_catalog_entry.group_id).to eq(value)

      # attribute :group_id, String, :tag => 'groupId', :key => true
    end

    # Unit test for attribute: {Moab::SignatureCatalogEntry#path}
    # Which stores: [String] The id is the filename path, relative to the file group's base directory
    specify 'Moab::SignatureCatalogEntry#path' do
      value = 'Test path'
      @signature_catalog_entry.path= value
      expect(@signature_catalog_entry.path).to eq(value)

      # attribute :path, String, :key => true, :tag => 'storagePath'
    end

    # Unit test for attribute: {Moab::SignatureCatalogEntry#signature}
    # Which stores: [Moab::FileSignature] The fixity data of the file instance
    specify 'Moab::SignatureCatalogEntry#signature' do
      value = double(Moab::FileSignature.name)
      @signature_catalog_entry.signature= value
      expect(@signature_catalog_entry.signature).to eq(value)

      @signature_catalog_entry.signature= [value, 'dummy']
      expect(@signature_catalog_entry.signature).to eq(value)

      # def signature=(signature)
      #   @signature = signature.is_a?(Array) ? signature[0] : signature
      # end

      # def signature
      #   # HappyMapper's parser tries to put an array of signatures in the signature field
      #   @signature.is_a?(Array) ? @signature[0] : @signature
      # end
    end

  end

  describe '=========================== INSTANCE METHODS ===========================' do

    before(:each) do
      @opts = {}
      @signature_catalog_entry = Moab::SignatureCatalogEntry.new(@opts)

      @signature_catalog_entry.version_id = 5
      @signature_catalog_entry.group_id = 'content'
      @signature_catalog_entry.path = 'title.jpg'
      @signature_catalog_entry.signature = double(Moab::FileSignature.name)
    end

    # Unit test for method: {Moab::SignatureCatalogEntry#storage_path}
    # Which returns: [String] Returns the storage path to a file, relative to the object storage home directory
    # For input parameters: (None)
    specify 'Moab::SignatureCatalogEntry#storage_path' do
      expect(@signature_catalog_entry.storage_path()).to eq("v0005/data/content/title.jpg")

      # def storage_path
      #   File.join(Moab::StorageObject.version_dirname(version_id),'data', group_id, path)
      # end
    end

  end

end
