describe Moab::FileManifestation do
  let(:file_manifestation) do
    v1_base_directory = @fixtures.join('data/jq937jp0017/v0001/content')
    title_v1_pathname = @fixtures.join('data/jq937jp0017/v0001/content/title.jpg')
    page1_v1_pathname = @fixtures.join('data/jq937jp0017/v0001/content/page-1.jpg')

    title_v1_signature = Moab::FileSignature.new.signature_from_file(title_v1_pathname)
    title_v1_instance = Moab::FileInstance.new.instance_from_file(title_v1_pathname, v1_base_directory)
    page1_v1_instance = Moab::FileInstance.new.instance_from_file(page1_v1_pathname, v1_base_directory)

    fm = described_class.new
    fm.signature = title_v1_signature
    fm.instances << title_v1_instance
    fm.instances << page1_v1_instance
    fm
  end

  describe '#initialize' do
    specify 'empty options hash' do
      file_manifestation = described_class.new({})
      expect(file_manifestation.instances).to be_instance_of Array
    end
    specify 'options passed in' do
      opts = {
        signature: double(Moab::FileSignature.name),
        instances: double(Moab::FileInstance.name)
      }
      file_manifestation = described_class.new(opts)
      expect(file_manifestation.signature).to eq opts[:signature]
      expect(file_manifestation.instances).to eq opts[:instances]
    end
  end

  describe '#signature' do
    let(:value) { double(Moab::FileSignature.name) }

    specify 'single value' do
      file_manifestation.signature = value
      expect(file_manifestation.signature).to eq value
    end
    specify 'becomes first value if set to Array of values' do
      file_manifestation.signature = [value]
      expect(file_manifestation.signature).to eq value
    end
  end

  specify '#paths' do
    expect(file_manifestation.paths).to eq ["title.jpg", "page-1.jpg"]
  end

  specify '#file_count' do
    expect(file_manifestation.file_count).to eq 2
  end

  specify '#byte_count' do
    expect(file_manifestation.byte_count).to eq 81746
  end

  specify '#block_count' do
    expect(file_manifestation.block_count).to eq 80
  end

  specify '#==' do
    other = file_manifestation
    expect(file_manifestation == other).to eq true
  end
end
