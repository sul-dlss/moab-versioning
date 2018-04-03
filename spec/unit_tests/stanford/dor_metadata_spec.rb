describe Stanford::DorMetadata do

  specify '#initialize' do
    digital_object_id = 'Test digital_object_id'
    version_id = 68
    dor_metadata = described_class.new(digital_object_id, version_id)
    expect(dor_metadata.digital_object_id).to eq digital_object_id
    expect(dor_metadata.version_id).to eq version_id
  end

  specify '#inventory_from_directory' do
    dor_metadata = described_class.new(@obj, 2)
    inventory = dor_metadata.inventory_from_directory(@data.join('v0002/metadata'), 2)
    expect(inventory.type).to eq "version"
    expect(inventory.digital_object_id).to eq "jq937jp0017"
    expect(inventory.version_id).to eq 2
    expect(inventory.groups.size).to eq 2
    expect(inventory.file_count).to eq 9
  end
end
