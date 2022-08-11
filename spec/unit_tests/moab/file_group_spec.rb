# frozen_string_literal: true

def basic_expectations(file_group)
  expect(file_group).to be_instance_of(Moab::FileGroup)
  expect(file_group.files).to be_kind_of(Array)
  expect(file_group.signature_hash).to be_kind_of(Hash)
end

describe Moab::FileGroup do
  let(:base_directory) { fixtures_dir.join("data/#{BARE_TEST_DRUID}/v0001") }
  let(:file_group) { described_class.new.group_from_directory(base_directory, true) }
  let(:file_group_v1_content) { described_class.new.group_from_directory(base_directory.join('content'), true) }
  let(:new_file_group) { described_class.new }
  let(:file_name_list) { %w[intro-1.jpg intro-2.jpg page-1.jpg page-2.jpg page-3.jpg title.jpg] }

  describe '#initialize' do
    context 'without args' do
      it 'instantiates' do
        basic_expectations(described_class.new)
      end
    end

    context 'with empty hash argument' do
      it 'instantiates' do
        basic_expectations(described_class.new({}))
      end
    end

    context 'with populated hash argument' do
      let(:opts) do
        {
          group_id: 'Test group_id',
          data_source: 'Test data_source'
        }
      end
      let(:file_group_from_hash) { described_class.new(opts) }

      it 'instantiates' do
        basic_expectations(file_group_from_hash)
        expect(file_group_from_hash.group_id).to eq(opts[:group_id])
        expect(file_group_from_hash.data_source).to eq(opts[:data_source])
        expect(file_group_from_hash.file_count).to eq(0)
        expect(file_group_from_hash.byte_count).to eq(0)
        expect(file_group_from_hash.block_count).to eq(0)
        expect(file_group_from_hash.files).to eq([])
      end
    end
  end

  describe '#file_count' do
    it 'is correctly generated (dynamically)' do
      expect(file_group.file_count).to eq(11)
    end
  end

  describe '#byte_count' do
    it 'is correctly generated (dynamically)' do
      expect(file_group.byte_count).to eq(217820)
    end
  end

  describe '#block_count' do
    it 'is correctly generated (dynamically)' do
      expect(file_group.block_count).to eq(216)
    end
  end

  describe '#files' do
    it 'are the signature_hash values' do
      expect(file_group.files).to eq(file_group.signature_hash.values)
    end
  end

  describe '#base_directory' do
    it 'can come from .group_from_directory' do
      expect(file_group.base_directory.to_s).to end_with(base_directory.to_s)
    end
  end

  describe '#path_list' do
    it 'is populated from files in base_directory' do
      expect(file_group_v1_content.path_list).to eq(file_name_list)
    end
  end

  describe '#path_hash' do
    it 'keys are same as #file_name_list' do
      expect(file_group_v1_content.path_hash.keys).to eq(file_name_list)
    end
  end

  describe '#path_hash_subset' do
    let(:sigs) { (0..2).map { |i| file_group_v1_content.files[i].signature } }
    let(:subset) { file_group_v1_content.path_hash_subset(sigs) }

    it 'returns files expected from the signatures' do
      expect(subset.size).to eq(3)
      expect(subset.keys).to eq file_name_list[0..2]
    end
  end

  describe '#add_file' do
    it 'adds the file passed in' do
      manifestation = file_group_v1_content.files[0]
      new_file_group.add_file(manifestation)
      expect(new_file_group.files[0]).to eq(manifestation)
    end
  end

  describe '#add_file_instance' do
    let(:manifestation) { file_group_v1_content.files[0] }

    before do
      manifestation.instances.each do |instance|
        new_file_group.add_file_instance(manifestation.signature, instance)
      end
    end

    it 'adds serially' do
      expect(new_file_group.files[0]).to eq(manifestation)
      # add a second file instance to an existing manifestation
      new_file_group.add_file_instance(manifestation.signature, Moab::FileInstance.new(path: '/my/path'))
      expect(new_file_group.files[0].instances.size).to eq(2)
    end
  end

  describe '#remove_file_having_path affects file_count' do
    it 'affects file_count' do
      before_file_count = file_group_v1_content.file_count
      file_group_v1_content.remove_file_having_path('page-1.jpg')
      expect(file_group_v1_content.file_count).to eq(before_file_count - 1)
    end
  end

  describe '#is_descendent_of_base?' do
    before { new_file_group.base_directory = fixtures_dir.join('data') }

    it 'true when condition met' do
      expect(new_file_group).to be_is_descendent_of_base(base_directory)
    end

    it 'raises exception if false' do
      base = fixtures_dir.join('derivatives/manifests')
      exp_msg_regex = /is not a descendent of/
      expect { new_file_group.is_descendent_of_base?(base) }.to raise_exception(Moab::MoabRuntimeError, exp_msg_regex)
    end
  end

  describe '#group_from_bagit_subdir' do
    it 'updates @signatures_from_bag' do
      expect(new_file_group).to receive(:group_from_directory).with('my_directory', false)
      new_file_group.group_from_bagit_subdir('my_directory', 'my_digests', false)
      expect(new_file_group.instance_variable_get(:@signatures_from_bag)).to eq('my_digests')
    end
  end

  describe '#group_from_directory' do
    let(:directory) { base_directory.join('content') }

    it 'creates expected Moab::FileGroup' do
      expect(new_file_group).to receive(:harvest_directory).with(directory, true)
      group = new_file_group.group_from_directory(directory, true)
      basic_expectations(group)
      expect(group.base_directory).to eq(directory.realpath)
      expect(group.data_source).to eq(directory.realpath.to_s)
    end
  end

  describe '#harvest_directory' do
    context 'when there are' do
      it 'adds files' do
        new_file_group = described_class.new
        new_file_group.base_directory = manifests_dir
        new_file_group.harvest_directory(manifests_dir, true)
        expect(new_file_group.file_count).to eq 9
      end
    end

    context 'when there are nested subdirectories' do
      it 'adds files in top level directories only' do
        path = packages_dir.join('v0001')
        new_file_group.base_directory = path
        new_file_group.harvest_directory(path, false)
        expect(new_file_group.file_count).to eq 10
      end
    end
  end

  describe '#add_physical_file' do
    let(:pathname) { base_directory.join('content/title.jpg') }

    before do
      new_file_group.base_directory = base_directory.join('content')
    end

    it 'adds data for the physical file to the array of files in FileGroup' do
      expect(new_file_group.files.size).to eq(0)
      new_file_group.add_physical_file(pathname)
      expect(new_file_group.files.size).to eq(1)
      expect(new_file_group.files[0].signature).to eq Moab::FileSignature.new(
        size: 40873, md5: '1a726cd7963bd6d3ceb10a8c353ec166', sha1: '583220e0572640abcd3ddd97393d224e8053a6ad'
      )
      expect(new_file_group.files[0].instances[0].path).to eq('title.jpg')
    end

    context 'when adding the same file again' do
      let(:sig1) { double(Moab::FileSignature) }
      let(:sig2) { double(Moab::FileSignature) }
      let(:signature_for_path) { double(Hash) }

      before do
        allow(Moab::FileSignature).to receive(:new).and_return(sig1)
        allow(sig1).to receive(:signature_from_file).with(pathname)
        allow(sig2).to receive(:complete?).and_return(false)
        allow(sig2).to receive(:normalized_signature).with(pathname).and_return(sig2)
      end

      it 'calls add_file_instance' do
        new_file_group.add_physical_file(pathname)
        expect(signature_for_path).to receive(:[]).with(pathname).twice.and_return(sig2)
        expect(new_file_group).to receive(:add_file_instance)
        new_file_group.instance_variable_set(:@signatures_from_bag, signature_for_path)
        new_file_group.add_physical_file(pathname)
      end
    end
  end
end
