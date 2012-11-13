require 'spec_helper'

# Unit tests for class {Moab::SignatureCatalog}
describe 'Moab::SignatureCatalog' do
  
  describe '=========================== CONSTRUCTOR ===========================' do
    
    # Unit test for constructor: {Moab::SignatureCatalog#initialize}
    # Which returns an instance of: [Moab::SignatureCatalog]
    # For input parameters:
    # * opts [Hash<Symbol,Object>] = a hash containing any number of symbol => value pairs. The symbols should correspond to attributes declared using HappyMapper syntax 
    specify 'Moab::SignatureCatalog#initialize' do
       
      # test initialization with required parameters (if any)
      opts = {}
      signature_catalog = SignatureCatalog.new(opts)
      signature_catalog.should be_instance_of(SignatureCatalog)
       
      # test initialization of arrays and hashes
      signature_catalog.entries.should be_kind_of(Array)
      signature_catalog.signature_hash.should be_kind_of(Hash)
       
      # test initialization with options hash
      opts = OrderedHash.new
      opts[:digital_object_id] = 'Test digital_object_id'
      opts[:version_id] = 9
      opts[:catalog_datetime] = "Apr 12 19:36:07 UTC 2012"
      signature_catalog = SignatureCatalog.new(opts)
      signature_catalog.digital_object_id.should == opts[:digital_object_id]
      signature_catalog.version_id.should == opts[:version_id]
      signature_catalog.catalog_datetime.should == "2012-04-12T19:36:07Z"

      signature_catalog.file_count.should == 0

      # def initialize(opts={})
      #   @entries = Array.new
      #   @signature_hash = OrderedHash.new
      #   super(opts)
      # end
    end
  
  end
  
  describe '=========================== INSTANCE ATTRIBUTES ===========================' do
    
    before(:all) do
      @v1_catalog_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/manifests/signatureCatalog.xml')
      @signature_catalog = SignatureCatalog.parse(@v1_catalog_pathname.read)
    end
    
    # Unit test for attribute: {Moab::SignatureCatalog#digital_object_id}
    # Which stores: [String] The object ID (druid)
    specify 'Moab::SignatureCatalog#digital_object_id' do
      @signature_catalog.digital_object_id.should == 'druid:jq937jp0017'
       
      # attribute :digital_object_id, String, :tag => 'objectId'
    end
    
    # Unit test for attribute: {Moab::SignatureCatalog#version_id}
    # Which stores: [Integer] The ordinal version number
    specify 'Moab::SignatureCatalog#version_id' do
      @signature_catalog.version_id.should == 1
       
      # attribute :version_id, Integer, :tag => 'versionId', :key => true, :on_save => Proc.new {|n| n.to_s}
    end
    
    # Unit test for attribute: {Moab::SignatureCatalog#catalog_datetime}
    # Which stores: [Time] The datetime at which the catalog was updated
    specify 'Moab::SignatureCatalog#catalog_datetime' do
      Time.parse(@signature_catalog.catalog_datetime).should be_instance_of(Time)
      @signature_catalog.catalog_datetime= "Apr 12 19:36:07 UTC 2012"
      @signature_catalog.catalog_datetime.should == "2012-04-12T19:36:07Z"

      # attribute :catalog_datetime, Time, :tag => 'catalogDatetime', :on_save => Proc.new {|t| t.to_s}

      # def catalog_datetime=(event_datetime)
      #   @catalog_datetime=Time.input(event_datetime)
      # end
      #
      # def catalog_datetime
      #   Time.output(@catalog_datetime)
      # end

    end
    
    # Unit test for attribute: {Moab::SignatureCatalog#file_count}
    # Which stores: [Integer] The total number of data files (dynamically calculated)
    specify 'Moab::SignatureCatalog#file_count' do
      @signature_catalog.file_count.should == 11
       
      # attribute :file_count, Integer, :tag => 'fileCount', :on_save => Proc.new {|t| t.to_s}
       
      # def file_count
      #   entries.size
      # end
    end
    
    # Unit test for attribute: {Moab::SignatureCatalog#byte_count}
    # Which stores: [Integer] The total size (in bytes) of all data files (dynamically calculated)
    specify 'Moab::SignatureCatalog#byte_count' do
      @signature_catalog.byte_count.should == 217820
       
      # attribute :byte_count, Integer, :tag => 'byteCount', :on_save => Proc.new {|t| t.to_s}
       
      # def byte_count
      #   entries.inject(0) { |sum, entry| sum + entry.signature.size.to_i }
      # end
    end
    
    # Unit test for attribute: {Moab::SignatureCatalog#block_count}
    # Which stores: [Integer] The total disk usage (in 1 kB blocks) of all data files (estimating du -k result) (dynamically calculated)
    specify 'Moab::SignatureCatalog#block_count' do
      @signature_catalog.block_count.should == 216
       
      # attribute :block_count, Integer, :tag => 'blockCount', :on_save => Proc.new {|t| t.to_s}
       
      # def block_count
      #   block_size=1024
      #   entries.inject(0) { |sum, entry| sum + (entry.signature.size.to_i + block_size - 1)/block_size }
      # end
    end
    
    # Unit test for attribute: {Moab::SignatureCatalog#entries}
    # Which stores: [Array<SignatureCatalogEntry>] The set of data groups comprising the version
    specify 'Moab::SignatureCatalog#entries' do
      @signature_catalog.entries.size.should == 11
       
      # def entries=(entry_array)
      #   entry_array.each do |entry|
      #     add_entry(entry)
      #   end
      # end
       
      # has_many :entries, SignatureCatalogEntry, :tag => 'entry'
    end
    
    # Unit test for attribute: {Moab::SignatureCatalog#signature_hash}
    # Which stores: [OrderedHash] An index having {FileSignature} objects as keys and {SignatureCatalogEntry} objects as values
    specify 'Moab::SignatureCatalog#signature_hash' do
      @signature_catalog.signature_hash.size.should == 11
       
      # def signature_hash=(value)
      #   @signature_hash = value
      # end
       
      # def signature_hash
      #   @signature_hash
      # end
    end
  
  end
  
  describe '=========================== INSTANCE METHODS ===========================' do
    
    before(:each) do
      @v1_catalog_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0001/manifests/signatureCatalog.xml')
      @signature_catalog = SignatureCatalog.parse(@v1_catalog_pathname.read)
      @original_entry_count = @signature_catalog.entries.count

      @v2_inventory_pathname = @fixtures.join('derivatives/ingests/jq937jp0017/v0002/manifests/versionInventory.xml')
      @v2_inventory = FileInventory.parse(@v2_inventory_pathname.read)
    end
    
    # Unit test for method: {Moab::SignatureCatalog#add_entry}
    # Which returns: [void] Add a new entry to the catalog and to the {#signature_hash} index
    # For input parameters:
    # * entry [SignatureCatalogEntry] = The new catalog entry 
    specify 'Moab::SignatureCatalog#add_entry' do
      entry = mock(SignatureCatalogEntry.name)
      entry.should_receive(:signature).and_return(mock(FileSignature.name))
      @signature_catalog.add_entry(entry)
      @signature_catalog.entries.count.should == @original_entry_count + 1
       
      # def add_entry(entry)
      #   @signature_hash[entry.signature] = entry
      #   entries << entry
      # end
    end
    
    # Unit test for method: {Moab::SignatureCatalog#catalog_filepath}
    # Which returns: [String] The object-relative path of the file having the specified signature
    # For input parameters:
    # * file_signature [FileSignature] = The signature of the file whose path is sought
    specify 'Moab::SignatureCatalog#catalog_filepath' do
      file_signature = @signature_catalog.entries[0].signature
      filepath = @signature_catalog.catalog_filepath(file_signature)
      filepath.should == 'v0001/data/content/intro-1.jpg'
      file_signature.size = 0
      lambda{@signature_catalog.catalog_filepath(file_signature)}.should raise_exception

      # def catalog_filepath(file_signature)
      #   catalog_entry = @signature_hash[file_signature]
      #   raise "catalog entry not found for #{file_signature.fixity} in #{@digital_object_id} - #{@version_id}" if catalog_entry.nil?
      #   catalog_entry.storage_path
      # end
    end

    # Unit test for method: {Moab::SignatureCatalog#update}
    # Which returns: [void] Compares the {FileSignature} entries in the new versions {FileInventory} against the signatures in this catalog and create new {SignatureCatalogEntry} addtions to the catalog
    # For input parameters:
    # * version_inventory [FileInventory] = The complete inventory of the files comprising a digital object version 
    specify 'Moab::SignatureCatalog#update' do
      @signature_catalog.update(@v2_inventory,@v1_catalog_pathname.parent.parent.join('data'))
      @signature_catalog.entries.count.should == @original_entry_count + 4
       
      # def update(version_inventory)
      #   version_inventory.groups.each do |group|
      #     group.files.each do |file|
      #       unless @signature_hash.has_key?(file.signature)
      #         entry = SignatureCatalogEntry.new
      #         entry.version_id = version_inventory.version_id
      #         entry.group_id = group.group_id
      #         entry.path = file.instances[0].path
      #         entry.signature = file.signature
      #         add_entry(entry)
      #       end
      #     end
      #   end
      #   @version_id = version_inventory.version_id
      #   @catalog_datetime = Time.now
      # end
    end
    
    # Unit test for method: {Moab::SignatureCatalog#version_additions}
    # Which returns: [FileInventory] Retrurns a filtered copy of the input inventory containing only those files that were added in this version
    # For input parameters:
    # * version_inventory [FileInventory] = The complete inventory of the files comprising a digital object version 
    specify 'Moab::SignatureCatalog#version_additions' do
      version_additions = @signature_catalog.version_additions(@v2_inventory)
      version_additions.groups.count.should == 2
      version_additions.file_count.should == 4
      version_additions.byte_count.should == 35181
      version_additions.block_count.should == 37

      # def version_additions(version_inventory)
      #   version_additions = FileInventory.new(:type=>'additions')
      #   version_additions.copy_ids(version_inventory)
      #   version_inventory.groups.each do |group|
      #     group_addtions = FileGroup.new(:group_id => group.group_id)
      #     group.files.each do |file|
      #       unless @signature_hash.has_key?(file.signature)
      #         group_addtions.add_file_instance(file.signature,file.instances[0])
      #       end
      #     end
      #     version_additions.groups << group_addtions if group_addtions.files.size > 0
      #   end
      #   version_additions
      # end
    end
  
  end

end
