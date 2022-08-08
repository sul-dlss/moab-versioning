# frozen_string_literal: true

describe Moab::SignatureCatalogEntry do
  let(:sce) { described_class.new }

  it '#initialize' do
    opts = {
      version_id: 26,
      group_id: 'Test group_id',
      path: 'Test path',
      signature: double(Moab::FileSignature.name)
    }
    signature_catalog_entry = described_class.new(opts)
    expect(signature_catalog_entry.version_id).to eq(opts[:version_id])
    expect(signature_catalog_entry.group_id).to eq(opts[:group_id])
    expect(signature_catalog_entry.path).to eq(opts[:path])
    expect(signature_catalog_entry.signature).to eq(opts[:signature])
  end

  it '#signature becomes first value if set to Array' do
    value = double(Moab::FileSignature.name)
    sce.signature = [value, 'dummy']
    expect(sce.signature).to eq value
  end

  it '#storage_path' do
    sce.version_id = 5
    sce.group_id = 'content'
    sce.path = 'title.jpg'
    expect(sce.storage_path).to eq('v0005/data/content/title.jpg')
  end
end
