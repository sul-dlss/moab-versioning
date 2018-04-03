describe Stanford::ActiveFedoraObject do
  specify '#initialize' do
    fedora_object = double('FedoraObject')
    active_fedora_object = described_class.new(fedora_object)
    expect(active_fedora_object.fedora_object).to eq(fedora_object)
  end

  specify '#get_datastream_content' do
    fedora_object = double('FedoraObject')
    active_fedora_object = described_class.new(fedora_object)
    ds_id = 'Test ds_id'
    mock_datastream = double('datastream')
    mock_datastreams = double('datastreams')
    expect(active_fedora_object.fedora_object).to receive(:datastreams).and_return(mock_datastreams)
    expect(mock_datastreams).to receive(:[]).with(ds_id).and_return(mock_datastream)
    expect(mock_datastream).to receive(:content)
    active_fedora_object.get_datastream_content(ds_id)
  end
end
