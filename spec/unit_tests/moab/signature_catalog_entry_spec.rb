require 'spec_helper'

describe 'Moab::SignatureCatalogEntry' do

  specify '#initialize' do
    opts = {
      version_id: 26,
      group_id: 'Test group_id',
      path: 'Test path',
      signature: double(Moab::FileSignature.name)
    }
    signature_catalog_entry = Moab::SignatureCatalogEntry.new(opts)
    expect(signature_catalog_entry.version_id).to eq(opts[:version_id])
    expect(signature_catalog_entry.group_id).to eq(opts[:group_id])
    expect(signature_catalog_entry.path).to eq(opts[:path])
    expect(signature_catalog_entry.signature).to eq(opts[:signature])
  end

  specify '#signature becomes first value if set to Array' do
    sce = Moab::SignatureCatalogEntry.new()
    value = double(Moab::FileSignature.name)
    sce.signature = [value, 'dummy']
    expect(sce.signature).to eq value
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
